# Shipping — Launch Checklist

## Pre-Launch (48h before)

- [ ] All tests pass (unit, integration, e2e)
- [ ] Build succeeds with no warnings
- [ ] Lint and type checking pass
- [ ] Staging deployment green (if applicable)
- [ ] Database migrations tested on staging
- [ ] Rollback plan documented and reviewed
- [ ] Monitoring dashboards configured and accessible
- [ ] Alerts configured for critical metrics
- [ ] Runbook updated for known failure modes
- [ ] Stakeholders notified of release window

## Launch Day

- [ ] Final staging sanity check passed
- [ ] Backup database before migration
- [ ] Deploy to canary/percentage (if available)
- [ ] Monitor error rates for 15 minutes
- [ ] Gradual rollout (25% → 50% → 100%)
- [ ] Verify key user flows in production
- [ ] Check error logs for unexpected issues
- [ ] Confirm monitoring dashboards show expected data

## Post-Launch (24h)

- [ ] Error rates stable (no spike)
- [ ] Performance metrics within baseline (LCP, FID, CLS)
- [ ] No critical user-reported issues
- [ ] Rollback not triggered (stayed deployed)
- [ ] Post-mortem scheduled if rollback or incident occurred
