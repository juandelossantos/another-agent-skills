# Caching Strategies

## Cache Layer Decision Matrix

| Scenario | Recommended Layer | TTL Guidance | Invalidation |
|---|---|---|---|
| Static assets (images, CSS, JS) | CDN + Browser | 1 year (fingerprinted) | URL versioning |
| API responses (public) | CDN | 5-60 minutes | Purge by path pattern |
| API responses (user-specific) | Application | 1-5 minutes | Cache tag invalidation |
| Database query results | Application | 30s-5 minutes | Write-through |
| HTML pages (anonymous) | CDN + Browser | 10-60 minutes | Purge on deploy |
| Session data | Distributed cache (Redis) | Session TTL | Write-through |
| Computed aggregations | Application | 1-24 hours | Background recompute |

## Browser Cache

### How to Set

```nginx
# Nginx — static assets with fingerprint
location /assets/ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

```nginx
# Nginx — HTML (no cache)
location / {
    add_header Cache-Control "no-cache, no-store, must-revalidate";
}
```

### What to Cache

- ✅ Fingerprinted assets (CSS, JS with hash in filename): `1y`, `immutable`
- ✅ Images, fonts, media: `1y` (unless frequently changed)
- ❌ HTML pages without fingerprint: `no-cache` (revalidate)
- ❌ API responses with auth: `private` (don't cache in shared caches)

## CDN Cache

### Configuration Pattern

```yaml
# Cloudflare Cache Rules example
- rule: "Static assets"
  match: "*.css *.js *.png *.jpg *.svg *.woff2"
  ttl: 365 days
  
- rule: "API public"
  match: "/api/public/*"
  ttl: 30 minutes
  bypass_on_cookie: false
  
- rule: "API authenticated"
  match: "/api/*"
  ttl: 0  # Do not cache
```

### Cache Hit Ratio Targets

| Tier | Target | Action if Below |
|---|---|---|
| Static assets | > 95% | Check CDN config, cache headers |
| API public | > 70% | Review TTL, check for unique query params |
| HTML | > 80% | Review cache headers, check for cookies |

## Application Cache (Redis/Memcached)

### Cache-Aside Pattern

```python
def get_user(user_id):
    key = f"user:{user_id}"
    # Check cache first
    user = cache.get(key)
    if user:
        return user
    # Miss — load from database
    user = db.query("SELECT * FROM users WHERE id = ?", user_id)
    # Store in cache
    cache.set(key, user, ttl=300)
    return user
```

### Write-Through Pattern

```python
def update_user(user_id, data):
    key = f"user:{user_id}"
    # Update database first
    db.execute("UPDATE users SET ... WHERE id = ?", data, user_id)
    # Update cache
    cache.set(key, data, ttl=300)
```

### When to Use Each

| Pattern | Read Frequency | Write Frequency | Stale Data OK? |
|---|---|---|---|
| Cache-Aside | High | Low | Yes |
| Write-Through | High | High | No |
| Write-Behind | High | High | Yes (risk of loss) |

## Database Cache

### Query Cache (PostgreSQL)

```sql
-- Enable query cache (if available)
ALTER SYSTEM SET enable_seqscan = off;

-- Materialized view for expensive aggregations
CREATE MATERIALIZED VIEW order_summary AS
SELECT date_trunc('day', created_at) AS day, COUNT(*), SUM(total)
FROM orders GROUP BY 1;

-- Refresh periodically
REFRESH MATERIALIZED VIEW CONCURRENTLY order_summary;
```

### Cache Invalidation Anti-Patterns

1. **TTL-only invalidation** — Users see stale data until TTL expires. Use event-driven invalidation for user-facing data.
2. **Cache-all** — Caching every query without considering data freshness needs. Aggressive caching of user-specific data causes staleness.
3. **No cache key normalization** — Same data cached under different keys (e.g., `/api/users/1` and `/api/users?id=1`). Normalize keys.
4. **Silent cache failure** — Cache goes down, application doesn't fall back to database. Always handle cache misses gracefully.
5. **Cascade invalidation** — Invalidating too many cache entries on a single update causes a thundering herd on the database.

## Checklist

- [ ] Cache headers set correctly per content type (immutable vs revalidate)
- [ ] CDN configured with appropriate TTL and purge strategy
- [ ] Application cache uses write-through for critical data
- [ ] Cache key normalization implemented (no duplicate entries)
- [ ] Graceful degradation when cache is unavailable
- [ ] Cache hit ratio monitored and within targets
- [ ] Invalidation strategy documented and tested
