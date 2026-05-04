# AGENTS.md

> Context file for AI coding agents (Cursor, Codex, Claude Code).

## Project Overview

Community garden planner ("גינה קהילתית") — a mobile-first SPA for managing a 27-row community garden in Israel. The UI is Hebrew RTL.

## Tech Stack

- Vue 3.5 + Vue Router 4
- Tailwind CSS 4 + DaisyUI 5
- Supabase JS (auth + database)
- TypeScript
- Vite 8
- PWA (vite-plugin-pwa)

## Architecture

```
src/
├── pages/          # Route-level views (HomePage, RowPage, LoginPage)
├── components/     # Reusable UI components
├── composables/    # Shared state & logic (useRows, useAuth, useSegments, etc.)
├── lib/            # Supabase client setup
├── router/         # Vue Router config with auth guards
└── types/          # TypeScript type definitions (database types)
```

## Key Patterns

- **State management:** No Pinia/Vuex. Composables export module-scope `ref`s that act as shared singletons.
- **Auth:** Router `beforeEach` guard waits for auth loading, then redirects unauthenticated users to `/login`.
- **Supabase:** Remote instance only (no local Docker). Push migrations with `pnpm supabase db push`.
- **Package manager:** `pnpm` exclusively. Never use npm or yarn.

## Styling

DaisyUI 5 (Tailwind plugin) for UI components (`btn`, `card`, `badge`, `alert`, `modal`, `navbar`, `join`, `menu`, `loading`, etc.). Tailwind utilities for layout, spacing, positioning, and typography (`flex`, `gap-*`, `p-*`, `sticky`, `text-sm`, etc.). Prefer DaisyUI's semantic classes wherever a component exists; fall back to Tailwind utilities for structural concerns only.

## Database

Migrations live in `supabase/migrations/` as timestamped SQL files (e.g. `20250101000001_create_tables.sql`). Apply with `pnpm supabase db push`.

## Environment

Copy `.env.example` to `.env`. Required variables:

- `VITE_SUPABASE_URL` — Supabase project URL
- `VITE_SUPABASE_PUBLISHABLE_KEY` — Supabase anon/publishable key

## Design Constraints

- RTL Hebrew interface
- Mobile-first (primary viewport ~375px)
- Light mode only
- Earthy greens and warm neutrals palette
- No emoji overload — calm, functional aesthetic
- Readable in sunlight, usable with dirty hands
