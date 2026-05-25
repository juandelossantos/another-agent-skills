# Launch Checklist Guide

This guide contains the complete Phase 7 Launch Checklist for `fullstack-shipping`.

## Phase 7 — Launch Checklist (MANDATORY)

**NO LAUNCH WITHOUT THIS CHECKLIST COMPLETE.**

### Pre-Launch

- [ ] All tests pass in CI (unit, integration, E2E)
- [ ] Build succeeds without warnings
- [ ] Staging environment matches production (same versions, same config)
- [ ] Database migrations tested on staging
- [ ] Secrets configured for production
- [ ] Domain + SSL configured and tested
- [ ] Monitoring tools installed and verified (Sentry, UptimeRobot, etc.)
- [ ] Rollback plan documented and tested
- [ ] Documentation updated (README, API docs, runbooks)
- [ ] Team knows how to respond to alerts (on-call rotation or primary contact)

### Launch Day

- [ ] Deploy to production during low-traffic window
- [ ] Monitor error rates for 30 minutes post-deploy
- [ ] Run smoke tests (critical user flows)
- [ ] Announce to team/users if applicable

### Post-Launch (First 48 Hours)

- [ ] Monitor error rates, performance, business metrics
- [ ] Respond to any alerts immediately
- [ ] Collect feedback from early users
- [ ] Document any issues for next iteration
