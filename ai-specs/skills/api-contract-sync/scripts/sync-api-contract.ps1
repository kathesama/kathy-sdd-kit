[CmdletBinding()]
param(
    [string] $ProjectRoot = (Get-Location).Path,
    [string] $Config = "docs/contracts/api-contract-sync.json",
    [switch] $DryRun
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

function Write-Info {
    param([string] $Message)
    Write-Output "api-contract-sync: $Message"
}

function Get-FullPath {
    param(
        [string] $BasePath,
        [string] $Path
    )

    $expanded = [Environment]::ExpandEnvironmentVariables($Path)
    if ([System.IO.Path]::IsPathRooted($expanded)) {
        return [System.IO.Path]::GetFullPath($expanded)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $BasePath $expanded))
}

function ConvertTo-NormalizedPath {
    param([string] $Path)
    return ([System.IO.Path]::GetFullPath($Path).TrimEnd('\', '/') -replace '\\', '/').ToLowerInvariant()
}

function Test-PathWithin {
    param(
        [string] $ChildPath,
        [string] $ParentPath
    )

    $child = ConvertTo-NormalizedPath $ChildPath
    $parent = ConvertTo-NormalizedPath $ParentPath
    return ($child -eq $parent) -or $child.StartsWith("$parent/")
}

function Get-ConfigValue {
    param(
        [object] $ConfigObject,
        [string] $Name,
        [object] $DefaultValue
    )

    if ($ConfigObject.PSObject.Properties.Name -contains $Name) {
        return $ConfigObject.$Name
    }
    return $DefaultValue
}

function ConvertTo-StringArray {
    param([object] $Value)

    if ($null -eq $Value) {
        return @()
    }
    if ($Value -is [string]) {
        return @($Value)
    }

    $result = @()
    foreach ($item in $Value) {
        if ($null -ne $item -and -not [string]::IsNullOrWhiteSpace([string] $item)) {
            $result += [string] $item
        }
    }
    return $result
}

function ConvertTo-Bool {
    param([object] $Value)

    if ($Value -is [bool]) {
        return [bool] $Value
    }
    if ($Value -is [string]) {
        return $Value.Trim().ToLowerInvariant() -eq "true"
    }
    return $false
}

function Get-RelativePath {
    param(
        [string] $BasePath,
        [string] $Path
    )

    $baseUri = [System.Uri]::new(([System.IO.Path]::GetFullPath($BasePath).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar))
    $pathUri = [System.Uri]::new([System.IO.Path]::GetFullPath($Path))
    return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($pathUri).ToString()).Replace('/', [System.IO.Path]::DirectorySeparatorChar)
}

function Copy-ContractFile {
    param(
        [string] $SourcePath,
        [string] $DestinationPath,
        [string] $SourceRelativePath,
        [string] $SourceRoot,
        [bool] $MarkdownHeaderEnabled,
        [bool] $DryRunMode
    )

    $destinationParent = Split-Path -Parent $DestinationPath
    if ($DryRunMode) {
        Write-Info "would copy $SourceRelativePath -> $DestinationPath"
        return
    }

    if (-not (Test-Path -LiteralPath $destinationParent)) {
        New-Item -ItemType Directory -Force -Path $destinationParent | Out-Null
    }

    if ($MarkdownHeaderEnabled -and [System.IO.Path]::GetExtension($SourcePath).ToLowerInvariant() -eq ".md") {
        $relativeFromRoot = Get-RelativePath -BasePath $SourceRoot -Path $SourcePath
        $header = "<!-- Generated from API source: $relativeFromRoot. Do not edit in target repo. -->`n`n"
        $content = Get-Content -LiteralPath $SourcePath -Raw
        Set-Content -LiteralPath $DestinationPath -Value ($header + $content) -Encoding UTF8
        return
    }

    Copy-Item -LiteralPath $SourcePath -Destination $DestinationPath -Force
}

$projectRootPath = [System.IO.Path]::GetFullPath($ProjectRoot)
$configPath = Get-FullPath -BasePath $projectRootPath -Path $Config

if (-not (Test-Path -LiteralPath $configPath)) {
    Write-Info "config not found; no-op ($configPath)"
    exit 0
}

$configObject = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
$enabled = ConvertTo-Bool (Get-ConfigValue -ConfigObject $configObject -Name "update_api_contract" -DefaultValue $false)
if (-not $enabled) {
    Write-Info "update_api_contract is not true; no-op"
    exit 0
}

$targetRepoRaw = [string] (Get-ConfigValue -ConfigObject $configObject -Name "target_repo_path" -DefaultValue "")
if ([string]::IsNullOrWhiteSpace($targetRepoRaw)) {
    throw "target_repo_path is required when update_api_contract is true"
}

$targetRepoPath = Get-FullPath -BasePath $projectRootPath -Path $targetRepoRaw
if (-not (Test-Path -LiteralPath $targetRepoPath -PathType Container)) {
    throw "target_repo_path does not exist or is not a directory: $targetRepoPath"
}
if ((ConvertTo-NormalizedPath $targetRepoPath) -eq (ConvertTo-NormalizedPath $projectRootPath)) {
    throw "target_repo_path must not be the same as ProjectRoot"
}

$targetBaseRaw = [string] (Get-ConfigValue -ConfigObject $configObject -Name "target_base_path" -DefaultValue ".")
$targetBasePath = Get-FullPath -BasePath $targetRepoPath -Path $targetBaseRaw
if (-not (Test-PathWithin -ChildPath $targetBasePath -ParentPath $targetRepoPath)) {
    throw "target_base_path resolves outside target_repo_path: $targetBasePath"
}

$sourceFiles = @(ConvertTo-StringArray (Get-ConfigValue -ConfigObject $configObject -Name "source_files" -DefaultValue @()))
if ($sourceFiles.Count -eq 0) {
    Write-Info "source_files is empty; no-op"
    exit 0
}

$markers = @(ConvertTo-StringArray (Get-ConfigValue -ConfigObject $configObject -Name "target_required_markers" -DefaultValue @()))
foreach ($marker in $markers) {
    $markerPath = Get-FullPath -BasePath $targetRepoPath -Path $marker
    if (-not (Test-PathWithin -ChildPath $markerPath -ParentPath $targetRepoPath)) {
        throw "target_required_markers entry resolves outside target repo: $marker"
    }
    if (-not (Test-Path -LiteralPath $markerPath)) {
        throw "target repository marker is missing: $marker"
    }
}

$missingPolicy = ([string] (Get-ConfigValue -ConfigObject $configObject -Name "missing_source_policy" -DefaultValue "fail")).Trim().ToLowerInvariant()
if ($missingPolicy -notin @("fail", "warn")) {
    throw "missing_source_policy must be 'fail' or 'warn'"
}

$cleanTargetDirectories = ConvertTo-Bool (Get-ConfigValue -ConfigObject $configObject -Name "clean_target_directories" -DefaultValue $false)
$markdownHeaderEnabled = ConvertTo-Bool (Get-ConfigValue -ConfigObject $configObject -Name "markdown_header_enabled" -DefaultValue $true)
$manifestPathRaw = [string] (Get-ConfigValue -ConfigObject $configObject -Name "manifest_path" -DefaultValue "docs/contracts/api-contract-source.json")

$copiedFiles = @()
$missingSources = @()

foreach ($sourceRelative in $sourceFiles) {
    if ([System.IO.Path]::IsPathRooted($sourceRelative)) {
        throw "source_files entries must be relative to ProjectRoot: $sourceRelative"
    }

    $sourcePath = Get-FullPath -BasePath $projectRootPath -Path $sourceRelative
    if (-not (Test-PathWithin -ChildPath $sourcePath -ParentPath $projectRootPath)) {
        throw "source path resolves outside ProjectRoot: $sourceRelative"
    }

    if (-not (Test-Path -LiteralPath $sourcePath)) {
        $missingSources += $sourceRelative
        $message = "source not found: $sourceRelative"
        if ($missingPolicy -eq "fail") {
            throw $message
        }
        Write-Warning "api-contract-sync: $message"
        continue
    }

    $destinationPath = Get-FullPath -BasePath $targetBasePath -Path $sourceRelative
    if (-not (Test-PathWithin -ChildPath $destinationPath -ParentPath $targetRepoPath)) {
        throw "destination path resolves outside target repo: $destinationPath"
    }

    $sourceItem = Get-Item -LiteralPath $sourcePath
    if ($sourceItem.PSIsContainer) {
        if ($cleanTargetDirectories -and (Test-Path -LiteralPath $destinationPath)) {
            if (-not (Test-PathWithin -ChildPath $destinationPath -ParentPath $targetRepoPath)) {
                throw "refusing to clean unsafe target directory: $destinationPath"
            }
            if ($DryRun) {
                Write-Info "would clean target directory $destinationPath"
            } else {
                Remove-Item -LiteralPath $destinationPath -Recurse -Force
            }
        }

        Get-ChildItem -LiteralPath $sourcePath -Recurse -File | ForEach-Object {
            $relativeInside = Get-RelativePath -BasePath $sourcePath -Path $_.FullName
            $destinationFile = Join-Path $destinationPath $relativeInside
            $sourceRelForLog = Join-Path $sourceRelative $relativeInside
            Copy-ContractFile `
                -SourcePath $_.FullName `
                -DestinationPath $destinationFile `
                -SourceRelativePath $sourceRelForLog `
                -SourceRoot $projectRootPath `
                -MarkdownHeaderEnabled $markdownHeaderEnabled `
                -DryRunMode ([bool] $DryRun)
            $copiedFiles += ($sourceRelForLog -replace '\\', '/')
        }
        continue
    }

    Copy-ContractFile `
        -SourcePath $sourcePath `
        -DestinationPath $destinationPath `
        -SourceRelativePath $sourceRelative `
        -SourceRoot $projectRootPath `
        -MarkdownHeaderEnabled $markdownHeaderEnabled `
        -DryRunMode ([bool] $DryRun)
    $copiedFiles += ($sourceRelative -replace '\\', '/')
}

if (-not [string]::IsNullOrWhiteSpace($manifestPathRaw)) {
    $manifestPath = Get-FullPath -BasePath $targetBasePath -Path $manifestPathRaw
    if (-not (Test-PathWithin -ChildPath $manifestPath -ParentPath $targetRepoPath)) {
        throw "manifest_path resolves outside target repo: $manifestPath"
    }

    $manifest = [ordered] @{
        schema_version = 1
        generated_by = "api-contract-sync"
        source_root = $projectRootPath
        target_repo_path = $targetRepoPath
        source_files = $sourceFiles
        copied_files = $copiedFiles
        missing_sources = $missingSources
    }

    if ($DryRun) {
        Write-Info "would write manifest $manifestPath"
    } else {
        $manifestParent = Split-Path -Parent $manifestPath
        if (-not (Test-Path -LiteralPath $manifestParent)) {
            New-Item -ItemType Directory -Force -Path $manifestParent | Out-Null
        }
        $manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
    }
}

Write-Info "completed; copied=$($copiedFiles.Count) missing=$($missingSources.Count) dry_run=$([bool] $DryRun)"
