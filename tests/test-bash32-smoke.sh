#!/usr/bin/env bash
# test-bash32-smoke.sh — run the user-facing entrypoints under a real bash 3.2.
#
# The static guard (scripts/check-bash32.sh) catches bash 4 *syntax*; this suite
# catches bash 3.2 *runtime* semantics — chiefly that expanding an empty array
# under `set -u` aborts the script. That is exactly how `aas install --agents
# auto` broke on macOS (`args[@]: unbound variable`), and it is invisible to
# every test that runs on bash 5.
#
# Requires docker; without it the suite SKIPs (exit 0) so local runs stay fast.
# CI runs it inside the required `gates` job, where docker is always present.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE="bash:3.2"

if ! command -v docker >/dev/null 2>&1; then
  echo ""
  echo -e "  ${YELLOW}−${NC} SKIP: docker not installed (bash 3.2 smoke needs a container)"
  exit 0
fi
if ! docker info >/dev/null 2>&1; then
  echo ""
  echo -e "  ${YELLOW}−${NC} SKIP: docker daemon not running"
  exit 0
fi

echo ""
echo "Running the entrypoints under ${IMAGE} (macOS's /bin/bash)..."

if docker run --rm \
  -v "$REPO_ROOT:/src:ro" \
  -w /tmp \
  "$IMAGE" bash /src/tests/bash32-smoke-inner.sh; then
  echo -e "  ${GREEN}✓${NC} bash 3.2 smoke: PASS"
  exit 0
fi

echo -e "  ${RED}✗${NC} bash 3.2 smoke: FAIL (see the output above)"
exit 1
