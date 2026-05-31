# Platform-Specific Debugging Patterns

Common error patterns and fixes by platform.

## React / Next.js

```
Component doesn't render:
├── Check props → Are they defined? Correct types?
├── Check state → Is state initialized? Updated correctly?
├── Check effects → Missing dependency array? Infinite loop?
├── Check context → Provider wrapping? Consumer usage?
└── Check hydration → Server/client mismatch? Use useEffect for client-only code.
```

**Common fixes:**
- `useEffect` dependency array missing → Add all referenced variables
- Stale closure → Use functional state update: `setState(prev => prev + 1)`
- Hydration mismatch → Wrap client-only code in `typeof window !== 'undefined'`
- Next.js page not found → Check file-based routing, dynamic routes, catch-all

## Node.js / Express

```
API error:
├── Check request → Body parsing? Correct method? Auth headers?
├── Check middleware → Order matters. Error handler must be last.
├── Check database → Connection? Query syntax? Data integrity?
├── Check async → Missing await? Unhandled promise rejection?
└── Check environment → .env loaded? Variables correct?
```

**Common fixes:**
- "Cannot read property of undefined" → Add null check on request body
- "ECONNREFUSED" → Database or service not running
- "ETIMEOUT" → Network issue or service overloaded
- "Unhandled promise rejection" → Add try/catch or .catch()

## Python / Django / FastAPI

```
Python error:
├── ImportError → Check virtualenv activated, requirements.txt, sys.path
├── ModuleNotFoundError → pip install missing package
├── TypeError → Check function signatures, argument types
├── Database error → Check migrations, connection string, model definitions
└── Import cycle → Restructure to avoid circular imports
```

## Go

```
Go error:
├── Compilation error → Check syntax, types, unused imports
├── Nil pointer dereference → Add nil check before method calls
├── Race condition → Run with -race flag, add synchronization
├── Import cycle → Restructure packages
└── Goroutine leak → Ensure channels are closed, context cancelled
```
