# Testing Strategy Guide

This guide contains the complete Phase 6B Testing Strategy for `backend-api-mastery`.

## Phase 6B — Testing Strategy

### Testing Pyramid

| Level | Tool | Coverage |
|---|---|---|
| **Unit** | Vitest/Jest | Service functions, utilities, validation logic |
| **Integration** | Vitest + test DB | API endpoints, database queries, auth flows |
| **Contract** | Zod/OpenAPI | Request/response shape validation |
| **E2E** | Playwright | Critical user flows through the API |

### Test Database

Always use a separate test database or Docker container. Never test against production or development databases.

### Error Response Format

Use structured, consistent error responses:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      { "field": "email", "message": "Invalid email format" }
    ],
    "requestId": "req_12345"
  }
}
```

### HTTP Status Codes (use correctly)

- 200 OK — GET success
- 201 Created — POST success
- 204 No Content — DELETE success
- 400 Bad Request — Client input error
- 401 Unauthorized — Not authenticated
- 403 Forbidden — Authenticated but not authorized
- 404 Not Found — Resource doesn't exist
- 409 Conflict — Business logic conflict
- 422 Unprocessable Entity — Validation failed
- 429 Too Many Requests — Rate limited
- 500 Internal Server Error — Server bug (log, don't expose details)
