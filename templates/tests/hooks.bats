#!/usr/bin/env bats
# hooks.bats — Test your pre-commit hook
# Installed by init-agents (another-agent-skills)
#
# Run: bats tests/hooks.bats
# Requires: bats (npm install -g bats)

setup() {
  # Create a temporary git repo for testing
  export TEST_DIR=$(mktemp -d)
  cd "$TEST_DIR"
  git init
  git config user.email "test@test.com"
  git config user.name "Test"
  
  # Copy hook from project
  cp "${BATS_TEST_DIRNAME}/../.git/hooks/pre-commit" "$TEST_DIR/.git/hooks/pre-commit"
  chmod +x "$TEST_DIR/.git/hooks/pre-commit"
  
  # Create STACK_CONFIG.md with test commands
  cat > "$TEST_DIR/STACK_CONFIG.md" << 'EOF'
# Stack Configuration

| Action | Command |
|---|---|
| Test | `echo 'tests pass' && exit 0` |
| Build | `echo 'build ok' && exit 0` |
| Lint | `<configure: what command lints your code?>` |
| Type check | `<configure: what command checks types?>` |
EOF
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "hook passes when tests pass" {
  touch "$TEST_DIR/test.js"
  git add test.js
  run bash .git/hooks/pre-commit
  [ "$status" -eq 0 ]
}

@test "hook blocks when tests fail" {
  # Create a test that fails
  cat > "$TEST_DIR/STACK_CONFIG.md" << 'EOF'
# Stack Configuration

| Action | Command |
|---|---|
| Test | `echo 'FAIL' && exit 1` |
| Build | `echo 'build ok' && exit 0` |
EOF
  touch "$TEST_DIR/test.js"
  git add test.js
  run bash .git/hooks/pre-commit
  [ "$status" -eq 1 ]
}

@test "hook blocks when secrets are detected" {
  echo 'API_KEY="sk-abc123def456ghi789jkl012mno345pqr"' > "$TEST_DIR/config.js"
  git add config.js
  run bash .git/hooks/pre-commit
  [ "$status" -eq 1 ]
}

@test "hook skips tests when SKILLS_DISABLED_HOOKS=tests" {
  cat > "$TEST_DIR/STACK_CONFIG.md" << 'EOF'
# Stack Configuration

| Action | Command |
|---|---|
| Test | `echo 'FAIL' && exit 1` |
| Build | `echo 'build ok' && exit 0` |
EOF
  touch "$TEST_DIR/test.js"
  git add test.js
  SKILLS_DISABLED_HOOKS="tests" run bash .git/hooks/pre-commit
  [ "$status" -eq 0 ]
}

@test "hook respects SKILLS_HOOK_LEVEL=minimal" {
  # minimal level should skip tests and build
  touch "$TEST_DIR/test.js"
  git add test.js
  SKILLS_HOOK_LEVEL="minimal" run bash .git/hooks/pre-commit
  [ "$status" -eq 0 ]
}
