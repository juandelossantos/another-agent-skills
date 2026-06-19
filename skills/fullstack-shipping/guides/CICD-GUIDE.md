# CI/CD Pipeline Design Guide

This guide contains the complete Phase 3 CI/CD Pipeline Design for `fullstack-shipping`.

## Phase 3 — CI/CD Pipeline Design

**Generate 2-3 pipeline strategy options. Never default to GitHub Actions without justification.**

### Option A — Platform-Native CI/CD (Simplest)

**Best for:** Vercel, Netlify, Railway, Fly (platform handles everything)

- **Trigger:** Push to `main` → auto-deploy to production
- **Preview:** Every PR gets a preview URL
- **Tests:** Run in platform build step or GitHub Actions
- **Pros:** Zero config, instant deploys, preview environments
- **Contras:** Vendor lock-in, limited customization, costs at scale
- **Ideal for:** Solo devs, small teams, Jamstack/Serverless apps

### Option B — GitHub Actions + Platform (Balanced)

**Best for:** Teams needing control + platform convenience

- **Trigger:** Push to `main` → GitHub Actions runs tests → deploy to platform
- **PR workflow:** Tests + lint + typecheck on every PR
- **Staging:** Separate branch `staging` → auto-deploy to staging env
- **Production:** `main` deploys to prod only after tests pass
- **Pros:** Full control over pipeline, free CI minutes, auditable
- **Contras:** More YAML to maintain, CI minute limits on free tier
- **Ideal for:** Teams of 2+, need PR gates, want audit trail

### Option C — Full Control (Docker + Self-hosted or Cloud)

**Best for:** Enterprise, regulated, or complex multi-service apps

- **Trigger:** GitHub Actions builds Docker image → push to registry → deploy to Kubernetes/ECS
- **Testing:** Full test matrix (unit, integration, E2E, contract, security scan)
- **Deployment:** Blue-green or canary with automated rollback
- **Secrets:** Vault, Doppler, or sealed secrets
- **Pros:** Maximum control, portable, works anywhere
- **Contras:** Steep learning curve, operational overhead, cost
- **Ideal for:** Enterprise, regulated industries, multi-service architectures

**Critical Challenge:**
- User wants direct deploy to prod from local machine → "Deploying from local skips tests, code review, and audit trails. Use PR → CI → deploy. If speed is critical, use preview deployments for instant feedback."
- User says "I don't need tests in CI, I test locally" → "Local tests pass in your environment, not in a clean one. CI catches 'works on my machine' issues. It's the difference between hoping and knowing."
