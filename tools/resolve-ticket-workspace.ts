import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";

type WorkspaceInfo = {
  repoRoot: string;
  ticket: string;
  ticketDir: string;
  enrichedPath: string;
  implBackendPath: string;
  implFrontendPath: string;
  prPath: string;
  existingFiles: string[];
  branchName: string | null;
};

function fail(message: string): never {
  console.error(`FAIL: ${message}`);
  process.exit(1);
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

function resolveTicket(input: string | undefined, repoRoot: string): { ticket: string; branchName: string | null } {
  const branchName = getCurrentBranch(repoRoot);
  const candidate = input?.trim() || extractTicketFromBranch(branchName);

  if (!candidate) {
    fail("could not resolve ticket key from input or current branch");
  }

  if (!/^[A-Z]+-\d+$/.test(candidate)) {
    fail(`invalid ticket key "${candidate}"`);
  }

  return { ticket: candidate, branchName };
}

function buildWorkspaceInfo(ticket: string, repoRoot: string, branchName: string | null): WorkspaceInfo {
  const ticketDir = path.join(repoRoot, ".ai-specs", "changes", ticket);
  const enrichedPath = path.join(ticketDir, `${ticket}-enriched.md`);
  const implBackendPath = path.join(ticketDir, `${ticket}-impl-backend.md`);
  const implFrontendPath = path.join(ticketDir, `${ticket}-impl-frontend.md`);
  const prPath = path.join(ticketDir, `PR-${ticket}.md`);

  const existingFiles = [
    enrichedPath,
    implBackendPath,
    implFrontendPath,
    prPath,
  ].filter((filePath) => fs.existsSync(filePath));

  return {
    repoRoot,
    ticket,
    ticketDir,
    enrichedPath,
    implBackendPath,
    implFrontendPath,
    prPath,
    existingFiles,
    branchName,
  };
}

function main(): void {
  const input = process.argv[2];
  const repoRoot = getRepoRoot();
  const { ticket, branchName } = resolveTicket(input, repoRoot);
  const workspace = buildWorkspaceInfo(ticket, repoRoot, branchName);

  console.log(JSON.stringify(workspace, null, 2));
}

main();
