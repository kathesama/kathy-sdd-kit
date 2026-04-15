import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";

type SectionName =
  | "Acceptance Criteria"
  | "Implementation Mapping"
  | "Validation Plan"
  | "Completion Evidence";

const SECTION_NAMES: SectionName[] = [
  "Acceptance Criteria",
  "Implementation Mapping",
  "Validation Plan",
  "Completion Evidence",
];

const VALID_STATUSES = new Set(["Covered", "Partial", "Not Covered"]);
const AC_ID_PATTERN = /^AC-\d{2,}$/;

function fail(message: string): never {
  console.error(`FAIL: ${message}`);
  process.exit(1);
}

function info(message: string): void {
  console.log(message);
}

function getRepoRoot(): string {
  return process.cwd();
}

function getCurrentBranch(repoRoot: string): string | null {
  try {
    return execFileSync("git", ["rev-parse", "--abbrev-ref", "HEAD"], {
      cwd: repoRoot,
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    }).trim();
  } catch {
    return null;
  }
}

function extractTicketFromBranch(branchName: string | null): string | null {
  if (!branchName) {
    return null;
  }
  const match = branchName.match(/[A-Z]+-\d+/);
  return match?.[0] ?? null;
}

function readFile(filePath: string): string {
  try {
    return fs.readFileSync(filePath, "utf8");
  } catch (error) {
    fail(`cannot read file: ${filePath}\n${String(error)}`);
  }
}

function getSection(content: string, sectionName: SectionName): string {
  const headingRegex = /^## (.+)$/gm;
  const matches = [...content.matchAll(headingRegex)];
  const currentIndex = matches.findIndex((match) => match[1]?.trim() === sectionName);

  if (currentIndex === -1) {
    fail(`missing required section "${sectionName}"`);
  }

  const start = (matches[currentIndex].index ?? 0) + matches[currentIndex][0].length;
  const end =
    currentIndex + 1 < matches.length
      ? (matches[currentIndex + 1].index ?? content.length)
      : content.length;

  return content.slice(start, end).trim();
}

function getTableRows(sectionContent: string, sectionName: SectionName): string[][] {
  const lines = sectionContent
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.startsWith("|"));

  if (lines.length < 3) {
    fail(`section "${sectionName}" does not contain a valid markdown table`);
  }

  return lines.slice(2).map((line) =>
    line
      .split("|")
      .slice(1, -1)
      .map((cell) => cell.trim()),
  );
}

function getAcIds(rows: string[][], sectionName: SectionName): string[] {
  const ids = rows.map((row) => row[0]).filter(Boolean);
  const invalid = ids.filter((id) => !AC_ID_PATTERN.test(id));
  if (invalid.length > 0) {
    fail(
      `section "${sectionName}" contains invalid AC IDs:\n- ${invalid.join("\n- ")}`,
    );
  }
  return ids;
}

function findDuplicates(values: string[]): string[] {
  const counts = new Map<string, number>();
  for (const value of values) {
    counts.set(value, (counts.get(value) ?? 0) + 1);
  }
  return [...counts.entries()]
    .filter(([, count]) => count > 1)
    .map(([value]) => value);
}

function resolveImplSpecPath(input: string | undefined, repoRoot: string): string {
  const normalized = input?.trim() || extractTicketFromBranch(getCurrentBranch(repoRoot));

  if (!normalized) {
    fail("usage: validate-impl-spec.ts <ticket-key-or-impl-spec-path>");
  }

  const asAbsolute = path.isAbsolute(normalized)
    ? normalized
    : path.resolve(repoRoot, normalized);

  if (fs.existsSync(asAbsolute) && fs.statSync(asAbsolute).isFile()) {
    return asAbsolute;
  }

  if (!/^[A-Z]+-\d+$/.test(normalized)) {
    fail(
      `input "${input}" is neither an existing file nor a ticket key like JAP-418`,
    );
  }

  const ticketDir = path.join(repoRoot, ".ai-specs", "changes", normalized);
  if (!fs.existsSync(ticketDir) || !fs.statSync(ticketDir).isDirectory()) {
    fail(`ticket workspace not found: ${ticketDir}`);
  }

  const matches = fs
    .readdirSync(ticketDir)
    .filter(
      (name) =>
        name === `${normalized}-impl-backend.md` ||
        name === `${normalized}-impl-frontend.md`,
    );

  if (matches.length === 0) {
    fail(
      `no implementation spec found in ${ticketDir}. Expected ${normalized}-impl-backend.md or ${normalized}-impl-frontend.md`,
    );
  }

  if (matches.length > 1) {
    fail(
      `multiple implementation specs found for ${normalized}. Pass the exact file path instead:\n- ${matches.join("\n- ")}`,
    );
  }

  return path.join(ticketDir, matches[0]);
}

function validateCompletionStatuses(rows: string[][]): void {
  const invalid = rows
    .map((row) => ({ acId: row[0], status: row[1] }))
    .filter(({ status }) => !VALID_STATUSES.has(status));

  if (invalid.length > 0) {
    const details = invalid
      .map(({ acId, status }) => `${acId}: ${status || "<empty>"}`)
      .join("\n- ");
    fail(`invalid Completion Evidence statuses:\n- ${details}`);
  }
}

function compareCoverage(
  canonicalIds: string[],
  otherIds: string[],
  sectionName: Exclude<SectionName, "Acceptance Criteria">,
): void {
  const missing = canonicalIds.filter((id) => !otherIds.includes(id));
  if (missing.length > 0) {
    fail(`missing acceptance criteria in ${sectionName}:\n- ${missing.join("\n- ")}`);
  }
}

function main(): void {
  const input = process.argv[2];

  const repoRoot = getRepoRoot();
  const filePath = resolveImplSpecPath(input, repoRoot);
  const content = readFile(filePath);

  const sections = Object.fromEntries(
    SECTION_NAMES.map((name) => [name, getSection(content, name)]),
  ) as Record<SectionName, string>;

  const acceptanceRows = getTableRows(sections["Acceptance Criteria"], "Acceptance Criteria");
  const mappingRows = getTableRows(
    sections["Implementation Mapping"],
    "Implementation Mapping",
  );
  const validationRows = getTableRows(sections["Validation Plan"], "Validation Plan");
  const completionRows = getTableRows(
    sections["Completion Evidence"],
    "Completion Evidence",
  );

  const acceptanceIds = getAcIds(acceptanceRows, "Acceptance Criteria");
  const mappingIds = getAcIds(mappingRows, "Implementation Mapping");
  const validationIds = getAcIds(validationRows, "Validation Plan");
  const completionIds = getAcIds(completionRows, "Completion Evidence");

  const duplicates = findDuplicates(acceptanceIds);
  if (duplicates.length > 0) {
    fail(`duplicate acceptance criteria IDs found:\n- ${duplicates.join("\n- ")}`);
  }

  validateCompletionStatuses(completionRows);
  compareCoverage(acceptanceIds, mappingIds, "Implementation Mapping");
  compareCoverage(acceptanceIds, validationIds, "Validation Plan");
  compareCoverage(acceptanceIds, completionIds, "Completion Evidence");

  info(`OK: implementation spec is structurally complete`);
  info(`File: ${filePath}`);
  info(`Acceptance criteria checked: ${acceptanceIds.length}`);
}

main();
