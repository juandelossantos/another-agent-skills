#!/usr/bin/env bash
# test-release-idempotent.sh — S4 (Prove-It): the "Publish the GitHub Release"
# step in release.yml must be idempotent. Re-running the release workflow for a
# tag whose release ALREADY exists must NOT fail with "a release with the same
# tag name already exists" — it must upload the assets with --clobber instead.
#
# No network: the step's `run:` script is extracted from the workflow and run
# against a stubbed `gh`.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WF="$REPO_ROOT/.github/workflows/release.yml"

SCRIPT="$(ruby -ryaml -e '
  doc = YAML.load_file(ARGV[0])
  step = (doc.dig("jobs","release","steps") || []).find { |s| s["name"] == "Publish the GitHub Release" }
  print(step && step["run"] ? step["run"] : "")
' "$WF" 2>/dev/null)"

if [ -z "$SCRIPT" ]; then
  echo "  ✗ could not extract the 'Publish the GitHub Release' run: step"
  exit 1
fi

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

# Run the extracted step with a stubbed `gh`; $1 = present|absent.
run_step() {
  local dir; dir="$(mktemp -d)"
  mkdir -p "$dir/dist" "$dir/bin"
  printf 'x\n' > "$dir/dist/another-agent-skills-v1.2.3.tar.gz"
  printf 'x\n' > "$dir/dist/checksums.txt"
  printf 'x\n' > "$dir/dist/bootstrap.sh"
  printf '%s\n' "$1" > "$dir/state"
  cat > "$dir/bin/gh" <<'STUB'
#!/usr/bin/env bash
case "$1 $2" in
  "release view")   [ "$(cat "$STATE")" = "present" ] && exit 0 || exit 1 ;;
  "release create") echo "create" >> "$CALLS"; exit 0 ;;
  "release upload") echo "upload $*" >> "$CALLS"; exit 0 ;;
  *) exit 0 ;;
esac
STUB
  chmod +x "$dir/bin/gh"
  ( cd "$dir" && PATH="$dir/bin:$PATH" STATE="$dir/state" CALLS="$dir/calls" \
      TAG=v1.2.3 bash -c "$SCRIPT" >/dev/null 2>&1 )
  echo "$dir"
}

# ── absent release → create ──
d="$(run_step absent)"
grep -q '^create' "$d/calls" 2>/dev/null; check $? "absent release → gh release create"
! grep -q '^upload' "$d/calls" 2>/dev/null; check $? "absent release → no upload"

# ── existing release → upload --clobber (idempotent), never create ──
d="$(run_step present)"
! grep -q '^create' "$d/calls" 2>/dev/null; check $? "existing release → no create"
grep -q 'upload .*--clobber' "$d/calls" 2>/dev/null; check $? "existing release → upload --clobber"

echo ""
[ "$fail" -gt 0 ] && { echo "  $fail failed"; exit 1; }
echo "  all checks passed"
exit 0
