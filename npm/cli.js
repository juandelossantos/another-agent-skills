#!/usr/bin/env node
"use strict";

// cli.js — npm wrapper for Another Agent Skills (Phase 9 / P9.5).
//
// This package ships NO framework payload. It is a thin, dependency-free
// bootstrap: it downloads the *pinned* release tarball + checksums.txt from
// GitHub Releases, verifies the sha256 with node:crypto, extracts it to a temp
// dir, and delegates to the release's own bootstrap.sh — the single source of
// truth for install logic. It never fetches from a mutable branch.
//
// Usage:
//   npx @juandelossantos/another-agent-skills install [--version vX.Y.Z] [--dry-run]
//   npx -p @juandelossantos/another-agent-skills aas-npm --version
//
// Environment (mirrors scripts/lib/aas.sh; useful for tests / mirrors):
//   AAS_RELEASE_BASE_URL  release base (default: GitHub Releases download URL)
//   AAS_REPO_SLUG         owner/repo (default: juandelossantos/another-agent-skills)
//   AAS_HOME / AAS_BIN_DIR  forwarded to the release bootstrap.sh
//   AAS_LATEST_VERSION    override the pinned version

const { createHash } = require("node:crypto");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const https = require("node:https");
const { execFileSync } = require("node:child_process");

const REPO_SLUG =
  process.env.AAS_REPO_SLUG || "juandelossantos/another-agent-skills";
const RELEASE_BASE = (
  process.env.AAS_RELEASE_BASE_URL ||
  `https://github.com/${REPO_SLUG}/releases/download`
).replace(/\/+$/, "");

const PKG = JSON.parse(fs.readFileSync(path.join(__dirname, "package.json"), "utf8"));
const PINNED_VERSION = PKG.version;

function info(msg) {
  process.stdout.write(`[aas-npm] ${msg}\n`);
}
function warn(msg) {
  process.stderr.write(`[aas-npm][WARN] ${msg}\n`);
}
function fail(msg) {
  process.stderr.write(`[aas-npm][ERROR] ${msg}\n`);
}

function usage() {
  process.stdout.write(
    `Usage: aas-npm <command> [options]

Commands:
  install [--version vX.Y.Z] [--dry-run]   Install the pinned release
  --version, -V                            Print the wrapper/framework version
  --help, -h                               Show this help

Options:
  --version vX.Y.Z   Install a specific pinned release (default: the version
                     pinned in this package, ${PINNED_VERSION})
  --dry-run          Print what would happen without downloading or writing

The wrapper downloads the release tarball + checksums.txt, verifies sha256, and
delegates to the release's own bootstrap.sh. It never fetches from a mutable ref.
`
  );
}

function normalizeVersion(v) {
  return String(v).replace(/^v/, "");
}

function validVersion(v) {
  return /^[0-9]+\.[0-9]+\.[0-9]+$/.test(v);
}

function assetName(version) {
  return `another-agent-skills-v${version}.tar.gz`;
}

function releaseUrl(version, asset) {
  return `${RELEASE_BASE}/v${version}/${asset}`;
}

function checksumsUrl(version) {
  return `${RELEASE_BASE}/v${version}/checksums.txt`;
}

// Distribution is pinned to an immutable release. Refuse mutable refs outright.
function guardUrl(url) {
  if (/(^|\/)(main|master)(\/|$)/.test(url) || url.includes("refs/heads/")) {
    throw new Error(`refusing to fetch from a mutable ref: ${url}`);
  }
}

function isRemote(url) {
  return /^https?:\/\//i.test(url);
}

function httpGet(url, dest) {
  return new Promise((resolve, reject) => {
    const req = https.get(url, { headers: { "user-agent": "aas-npm" } }, (res) => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        res.resume();
        const next = new URL(res.headers.location, url).toString();
        httpGet(next, dest).then(resolve, reject);
        return;
      }
      if (res.statusCode !== 200) {
        res.resume();
        reject(new Error(`GET ${url} failed: HTTP ${res.statusCode}`));
        return;
      }
      const chunks = [];
      res.on("data", (c) => chunks.push(c));
      res.on("end", () => {
        try {
          fs.writeFileSync(dest, Buffer.concat(chunks));
          resolve();
        } catch (e) {
          reject(e);
        }
      });
    });
    req.on("error", reject);
  });
}

async function download(url, dest) {
  guardUrl(url);
  if (isRemote(url)) {
    return httpGet(url, dest);
  }
  // Local path or file:// URL: used by tests and offline mirrors.
  const local = url.startsWith("file://") ? url.slice("file://".length) : url;
  fs.copyFileSync(local, dest);
}

function sha256(file) {
  return createHash("sha256").update(fs.readFileSync(file)).digest("hex");
}

function verifyChecksum(tarball, checksumsFile, asset) {
  const text = fs.readFileSync(checksumsFile, "utf8");
  let expected = null;
  for (const line of text.split(/\r?\n/)) {
    const parts = line.trim().split(/\s+/);
    if (parts.length >= 2 && (parts[1] === asset || parts[1] === `./${asset}`)) {
      expected = parts[0];
      break;
    }
  }
  if (!expected) {
    throw new Error(`checksums.txt has no entry for ${asset} — refusing to install`);
  }
  const actual = sha256(tarball);
  if (expected !== actual) {
    throw new Error(
      `checksum mismatch for ${asset}: expected ${expected}, got ${actual}`
    );
  }
}

function parseArgs(argv) {
  const opts = { version: "", dryRun: false };
  const rest = [];
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--dry-run") {
      opts.dryRun = true;
    } else if (arg === "--version" || arg === "-V") {
      opts.version = argv[++i] || "";
      if (!opts.version) throw new Error("--version requires a value (vX.Y.Z)");
    } else if (arg.startsWith("--version=")) {
      opts.version = arg.slice("--version=".length);
      if (!opts.version) throw new Error("--version requires a value (vX.Y.Z)");
    } else {
      rest.push(arg);
    }
  }
  return { opts, rest };
}

function resolveVersion(requested) {
  const raw =
    requested || process.env.AAS_LATEST_VERSION || PINNED_VERSION;
  const version = normalizeVersion(raw);
  if (!validVersion(version)) {
    throw new Error(
      `invalid version '${raw}' (expected vX.Y.Z or X.Y.Z)`
    );
  }
  return version;
}

async function cmdInstall(argv) {
  let parsed;
  try {
    parsed = parseArgs(argv);
  } catch (e) {
    fail(e.message);
    return 2;
  }
  const { opts } = parsed;

  let version;
  try {
    version = resolveVersion(opts.version);
  } catch (e) {
    fail(e.message);
    return 2;
  }

  const asset = assetName(version);
  const tarballUrl = releaseUrl(version, asset);
  const checksumsUrlStr = checksumsUrl(version);

  if (opts.dryRun) {
    info("aas-npm install (dry-run)");
    info(`version:        ${version}`);
    info(`release base:   ${RELEASE_BASE}`);
    info(`tarball url:    ${tarballUrl}`);
    info(`checksums url:  ${checksumsUrlStr}`);
    info("[dry-run] would download, verify sha256, extract, and run bootstrap.sh");
    info("[dry-run] no changes made");
    return 0;
  }

  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "aas-npm."));
  try {
    const tarball = path.join(tmp, asset);
    const checksumsFile = path.join(tmp, "checksums.txt");

    info(`Downloading v${version}...`);
    await download(tarballUrl, tarball);
    await download(checksumsUrlStr, checksumsFile);

    info("Verifying sha256...");
    verifyChecksum(tarball, checksumsFile, asset);

    const extractDir = path.join(tmp, "src");
    fs.mkdirSync(extractDir);
    execFileSync("tar", ["-xzf", tarball, "-C", extractDir], { stdio: "inherit" });

    const bootstrap = path.join(extractDir, "bootstrap.sh");
    if (!fs.existsSync(bootstrap)) {
      throw new Error("release tarball is missing bootstrap.sh at its root");
    }
    fs.chmodSync(bootstrap, 0o755);

    // Delegate to the release's own bootstrap.sh: one implementation of install.
    info(`Delegating to the release's bootstrap.sh (v${version})...`);
    execFileSync(
      "bash",
      [bootstrap, "--version", version, "--tarball", tarball, "--checksums", checksumsFile],
      { stdio: "inherit", env: process.env }
    );
    info(`Installed v${version}`);
    return 0;
  } finally {
    fs.rmSync(tmp, { recursive: true, force: true });
  }
}

async function main() {
  const cmd = process.argv[2] || "";
  const rest = process.argv.slice(3);

  switch (cmd) {
    case "install":
      return cmdInstall(rest);
    case "--version":
    case "-V":
    case "version":
      process.stdout.write(`${PINNED_VERSION}\n`);
      return 0;
    case "--help":
    case "-h":
    case "help":
    case "":
      usage();
      return 0;
    default:
      fail(`unknown command: ${cmd}`);
      usage();
      return 2;
  }
}

main()
  .then((code) => process.exit(code))
  .catch((e) => {
    fail(e && e.message ? e.message : String(e));
    process.exit(1);
  });
