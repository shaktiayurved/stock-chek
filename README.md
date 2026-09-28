# NCR QUICK STOCK FINDER

Check and record mobile-phone availability across **Zepto** and **Swiggy Instamart** in **Delhi NCR** — via a Chrome Extension (Manifest V3), a Node.js/TypeScript REST API on **Supabase PostgreSQL**, and a web dashboard.

```
Search once:  Realme P4x 5G 6GB/128GB
See everywhere:
  ✓ Zepto    · Noida — Sector 18      · AVAILABLE   · ₹18,499 · 2m ago  · 🟢 LIVE
  🔴 Zepto    · Delhi — Sarita Vihar   · OUT OF STOCK · ₹18,999 · 25m ago
  ⚪ Zepto    · Gurugram — Sector 29   · UNKNOWN — never checked
```

> **Compliance first.** The system only records information that is visible to the user in the browser page or obtained through authorized APIs. It never bypasses CAPTCHA or authentication, never extracts cookies/tokens, never uses hidden/private endpoints to circumvent platform restrictions, and never sends automated request floods. Every observation is a deliberate user action.

---

## What's in this repo

| Path | What it is |
|---|---|
| `apps/extension/` | Chrome MV3 extension — React + TypeScript + Vite + Tailwind. Popup (capture / search / location queue), options page (auth + prefs + watchlist), content script with floating **CAPTURE STOCK** button, background service worker, modular platform adapters (Zepto, Instamart; Blinkit & BigBasket stubs). |
| `apps/api/` | Node.js + TypeScript + Express REST API. Supabase PostgreSQL in production; a clearly-labelled in-memory **MOCK_MODE** for UI testing (spec §56). |
| `apps/dashboard/` | React + TypeScript + Vite + Tailwind dashboard (`/stock` search, locations, products, price/stock history, watchlist, admin panel, CSV export, map view). |
| `packages/shared/` | Shared types + the exact-variant matching engine, search normalization, freshness rules, Delhi NCR seed data. Unit-tested (`npm test`). |
| `supabase/migrations/` | SQL schema, RLS policies, RPC functions and the Delhi NCR location seed. |
| `scripts/` | Icon generator, SQL seed generator, acceptance smoke test, extension packager. |
| `docs/` | Architecture, deployment, environment variables, acceptance test, adapter guide. |
| `ncr-quick-stock-extension-v1.0.0.zip` | Pre-built, load-ready extension package. |

## Quickstart (local, mock mode)

```bash
npm install

# 1. API in mock mode (clearly-labelled fake data — no Supabase needed)
npm run dev:api              # MOCK_MODE defaults… set MOCK_MODE=true in apps/api/.env, or:
MOCK_MODE=true npm run dev:api

# 2. Dashboard (proxies /api to :8787)
npm run dev:dashboard        # http://localhost:5173  → "Sign in as demo user (MOCK DATA)"

# 3. Run the unit + acceptance tests
npm test                     # exact-variant matching (21 checks)
npm run smoke                # full §58 acceptance scenario against the mock API (19 checks)

# 4. Build everything
npm run build:extension      # → apps/extension/dist  (load unpacked in Chrome)
npm run build:dashboard      # → apps/dashboard/dist
npm run build:api            # → apps/api/dist/server.js
npm run zip:extension        # → ncr-quick-stock-extension-v1.0.0.zip
```

To test the extension's capture flow without visiting a real platform, open the dashboard's dev page **`/dev/mock-store`** — a clearly-labelled fake product page with JSON-LD, price, add-to-cart button and a delivery-address header.

## Deploy the website to Vercel

The repo is Vercel-ready — dashboard **+** API deploy as one project:

1. Push this repo to GitHub.
2. **vercel.com/new** → import the repo → Root Directory: `./` (leave everything else) → **Deploy**.
3. Live at `https://your-project.vercel.app` — login with **"Sign in as demo user (MOCK DATA)"**.

Zero-config deploys run the clearly-labelled mock demo; for permanent data set the
Supabase env vars (full Hinglish guide: **docs/VERCEL.md**). Local pre-check:

```bash
npm run build:vercel && npm run test:vercel   # builds + §58 test on the exact deploy bundle
```

## Production quickstart

1. Create a Supabase project and run `supabase/migrations/0001–0004` (SQL editor or `supabase db push`).
2. Create your user (Authentication → Users), then promote to admin:
   ```sql
   update public.profiles set role = 'admin' where email = 'you@example.com';
   ```
3. Configure `apps/api/.env` (Supabase URL + **service-role key**, CORS allowlist) with `MOCK_MODE=false`, deploy behind HTTPS. See `docs/DEPLOYMENT.md`.
4. Build the dashboard, set `VITE_SUPABASE_URL` / `VITE_SUPABASE_ANON_KEY` / `VITE_API_BASE`, host it (or serve it from the API via `SERVE_STATIC_DIR`).
5. Build the extension with matching `VITE_API_BASE_URL` / Supabase env, load it, and add `chrome-extension://YOUR-EXTENSION-ID` to the API's `ALLOWED_ORIGINS`.

Full details: **docs/DEPLOYMENT.md** · env vars: **docs/ENVIRONMENT.md** · system design: **docs/ARCHITECTURE.md**.

## Core guarantees (spec)

- **Exact variant matching (§11/§46):** `Realme P4x 5G 6GB/128GB` never matches 8/128, 6/256 or the 4G model. Enforced in `packages/shared/src/matching.ts` and covered by tests.
- **One record per (platform × location × variant) (§45/§58):** snapshots are never merged across those dimensions — Zepto+Noida and Zepto+Delhi are separate rows.
- **Never assume stock (§14/§50):** an untracked or unconfirmable combination shows `UNKNOWN — never checked`, never `OUT_OF_STOCK`. `UNKNOWN` is stored as `UNKNOWN`.
- **LIVE vs LAST OBSERVED (§28/§29):** fresh page captures (≤ freshness window) get a 🟢 LIVE badge; everything older is 🟡 LAST OBSERVED with a Fresh/Recent/Old/Stale label. Thresholds are admin-configurable.
- **Sector-level locations (§9):** Delhi is not one location — Noida Sector 18, 62 and 137 are independent service areas.
- **Confidence + confirmation (§43/§44):** every capture carries product/location/availability confidences; below-threshold captures ask the user to confirm before saving.
- **Three-level architecture (§54):** Level 1 current-page capture (shipped), Level 2 user-assisted multi-location queue (shipped), Level 3 true automatic live stock (ready for authorized APIs — swap in a connector, no schema changes needed).

## Scripts

| Command | Description |
|---|---|
| `npm run dev:api` | API dev server (tsx watch) |
| `npm run dev:dashboard` | Dashboard dev server (proxies `/api`) |
| `npm test` | Shared-package unit tests (node:test) |
| `npm run smoke` | §58 acceptance smoke test against a mock-mode API |
| `npm run icons` | Regenerate extension icons |
| `npm run seed:sql` | Regenerate `supabase/migrations/0004_seed.sql` from shared seed data |
| `npm run build:api/dashboard/extension` | Production builds |
| `npm run zip:extension` | Package `apps/extension/dist` → load-ready zip |

## License

MIT.
