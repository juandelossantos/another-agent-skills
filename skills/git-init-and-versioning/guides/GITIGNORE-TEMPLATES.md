# Git Ignore Templates

## Node.js / Next.js / React

```gitignore
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.pnpm-debug.log*

# Build outputs
.next/
dist/
build/
out/

# Environment files (NEVER commit secrets)
.env
.env.local
.env.*.local
.env.development
.env.test
.env.production

# OS files
.DS_Store
Thumbs.db

# IDE
.vscode/settings.json
.idea/
*.swp
*.swo

# Testing
coverage/
.nyc_output/

# Logs
*.log
logs/

# Temporary
tmp/
temp/
*.tmp

# Database
*.sqlite
*.sqlite3

# Misc
*.pem
*.cert
*.key
```

## Python

```gitignore
__pycache__/
*.py[cod]
*$py.class
.venv/
venv/
.env
.env.local
dist/
build/
*.egg-info/
.pytest_cache/
.coverage
```

## Rust

```gitignore
/target/
Cargo.lock
*.rs.bk
.env
```

## Go

```gitignore
/vendor/
*.exe
*.test
*.out
.env
```

## Universal (All Projects)

```gitignore
# Environment
.env
.env.*

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/settings.json
.idea/
*.swp

# Logs
*.log
logs/

# Temporary
tmp/
temp/
*.tmp
```
