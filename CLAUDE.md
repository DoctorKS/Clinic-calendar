# Clinic-calendar — Claude guardrails

Read this before changing any storage, sync, or data-loading code in
`index.html`. It captures rules the human owner wants enforced across
every session.

## Pure-Supabase data policy (do not touch)

This app uses Supabase as the **only** durable store for app data.
Local-browser persistence is deliberately limited to a single key.

1. **Keep only `sb_session` in `localStorage`. Nothing else.**
   That single key stores the Supabase auth token. App data — clinics,
   shifts, hanging fees, proc/mach/trade lists — lives in the in-memory
   `appMemoryStore` only, and is populated from Supabase via
   `pullFromSupabase()` on load. Never write app data, settings, or
   any other value to `localStorage` (or `sessionStorage`, IndexedDB,
   cookies, Cache API, a service worker).

2. **If a change would make any code touch `localStorage` (other than
   `sb_session`) OR modify a database/storage/sync function, STOP and
   tell the human owner what you intend to do, and wait for the
   go-ahead before doing it.**

   The functions in scope include (non-exhaustive):
   `sbFetch`, `sbUpsert`, `sbSelect`, `sbDelete`,
   `appGetItem` / `appSetItem` / `appRemoveItem`, `appMemoryStore`,
   `clearCurrentUserCache`, `eachAppCacheKey`,
   `pullFromSupabase`, `syncLocalToSupabase`,
   and the per-domain savers: `saveData`, `saveClinics`,
   `saveProcList`, `saveMachList`, `saveTradeToList`, `saveHanging`.

### Why this rule exists

Silent local caching was deliberately removed in commit `ac8472a`
("use Supabase as app data source"). Reintroducing it would:
- Resurface stale data after the user edits on another device.
- Break the **fail-loud** save guarantees the rest of the code depends
  on (a failed Supabase write must be visible to the user, not
  papered over by a local cache that looks "saved").
- Make `restoreFromCloud`, `syncLocalToSupabase`, and the ↻ reload
  button behave unpredictably, since they assume in-memory state is
  the only thing that can diverge from Supabase.

The owner chose "Supabase-only, fail loud" explicitly. Treat that as
a standing decision, not a default to revisit.
