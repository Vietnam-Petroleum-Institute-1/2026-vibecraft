#!/usr/bin/env node
"use strict";

// Thin launcher for `npx github:<org>/<repo>#<tag>` (and local `node bin/vibecraft.js`).
// Contains NO decision-tree logic of its own — it only locates and execs
// scripts/init.sh with the args/stdio it was given. scripts/init.sh remains
// the single source of truth; see vibecraft-docs/08-INIT-SCRIPT-SPEC.md.

const path = require("path");
const fs = require("fs");
const { spawnSync, spawn } = require("child_process");

const VIBECRAFT_ROOT = path.join(__dirname, "..");
const INIT_SH = path.join(VIBECRAFT_ROOT, "scripts", "init.sh");

function fail(message) {
  process.stderr.write(`\n  ✗ ${message}\n\n`);
  process.exit(1);
}

if (!fs.existsSync(INIT_SH)) {
  fail(
    `Không tìm thấy scripts/init.sh tại ${INIT_SH} — VibeCraft chưa được checkout đúng cách.`
  );
}

// On Windows, `bash` on PATH is ambiguous: cmd.exe/PowerShell often resolve it
// to the WSL launcher stub (C:\Windows\System32\bash.exe / \WindowsApps\bash.exe)
// instead of Git Bash, even when Git Bash is installed — because those shells
// don't inherit Git for Windows' own PATH additions the way a Git Bash session
// does. That stub errors out with a raw WSL relay message when no WSL distro is
// set up. We need the real Git Bash specifically (not WSL — no path translation
// here), so resolve it explicitly rather than trusting a bare `spawn("bash")`.
function isWslStubPath(p) {
  const lower = p.toLowerCase();
  return (
    lower.includes("\\system32\\") ||
    lower.includes("\\syswow64\\") ||
    lower.includes("\\sysnative\\") ||
    lower.includes("\\windowsapps\\")
  );
}

function findGitBashOnWindows() {
  const where = spawnSync("where", ["bash"], { encoding: "utf8" });
  const onPath =
    where.status === 0
      ? where.stdout.split(/\r?\n/).map((l) => l.trim()).filter(Boolean)
      : [];
  const realBashOnPath = onPath.find((p) => !isWslStubPath(p));
  if (realBashOnPath) return realBashOnPath;

  // Nothing usable on PATH — probe common Git-for-Windows install locations.
  const candidates = [
    process.env.ProgramFiles &&
      path.join(process.env.ProgramFiles, "Git", "bin", "bash.exe"),
    process.env["ProgramFiles(x86)"] &&
      path.join(process.env["ProgramFiles(x86)"], "Git", "bin", "bash.exe"),
    process.env.LocalAppData &&
      path.join(process.env.LocalAppData, "Programs", "Git", "bin", "bash.exe"),
  ].filter(Boolean);
  const found = candidates.find((p) => fs.existsSync(p));
  if (found) return found;

  // Last resort: derive it from wherever `git.exe` itself lives (handles
  // non-default install dirs) — .../Git/cmd/git.exe or .../Git/bin/git.exe
  // both sit one level below the Git root that also contains bin/bash.exe.
  const whereGit = spawnSync("where", ["git"], { encoding: "utf8" });
  if (whereGit.status === 0) {
    const gitExe = whereGit.stdout.split(/\r?\n/)[0].trim();
    const gitRoot = path.dirname(path.dirname(gitExe));
    const derived = path.join(gitRoot, "bin", "bash.exe");
    if (fs.existsSync(derived)) return derived;
  }

  return null;
}

let bashPath = "bash";
if (process.platform === "win32") {
  const resolved = findGitBashOnWindows();
  if (!resolved) {
    fail(
      "Không tìm thấy Git Bash (chỉ thấy launcher WSL của Windows, không dùng được cho " +
        "script này). Cài Git for Windows (đi kèm Git Bash): https://git-scm.com/download/win " +
        "— hoặc chạy lại lệnh này trong cửa sổ Git Bash thay vì cmd.exe/PowerShell."
    );
  }
  bashPath = resolved;
} else {
  const bashCheck = spawnSync("bash", ["--version"], { stdio: "ignore" });
  if (bashCheck.error) {
    fail("Cần có Bash để chạy VibeCraft.");
  }
}

const child = spawn(bashPath, [INIT_SH, ...process.argv.slice(2)], {
  stdio: "inherit",
});

child.on("error", (err) => {
  fail(`Không chạy được scripts/init.sh: ${err.message}`);
});

child.on("close", (code, signal) => {
  if (signal) {
    process.kill(process.pid, signal);
    return;
  }
  process.exit(code === null ? 1 : code);
});
