# AGENTS.md

> Context file for AI coding agents (Cursor, Codex, Claude Code).
> **Read this file first. Do NOT re-explore the codebase on every chat — everything you need is here.**

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
├── pages/           # Route-level views
│   ├── HomePage.vue     # Main dashboard — lists all rows, garden mini-map, aerial view, export, nursery order, pipe map
│   ├── RowPage.vue      # Single-row detail view (props: { id: string })
│   └── LoginPage.vue    # Email+password login
├── components/      # Reusable UI components (see Component Inventory below)
├── composables/     # Shared state & logic (see Composable API below)
├── lib/
│   └── supabase.ts  # Supabase client init (reads VITE_SUPABASE_URL & VITE_SUPABASE_PUBLISHABLE_KEY)
├── router/
│   └── index.ts     # 3 routes: / (home), /row/:id, /login — beforeEach auth guard
├── types/
│   └── database.ts  # TS interfaces for all DB tables
├── App.vue          # Root component — wraps <RouterView> in AppLayout
├── main.ts          # App entry point
└── style.css        # Global styles / Tailwind directives
```

## Routes

| Path        | Page          | Auth required | Notes                        |
|-------------|---------------|---------------|------------------------------|
| `/`         | HomePage      | Yes           | Dashboard with row list      |
| `/row/:id`  | RowPage       | Yes           | Row detail + segment editor  |
| `/login`    | LoginPage     | No            | Redirects to `/` if logged in|

## Component Inventory

| Component           | Props                                                      | Purpose                                                   |
|---------------------|------------------------------------------------------------|-----------------------------------------------------------|
| `AppLayout`         | (none, slot)                                               | Navbar + main content wrapper                             |
| `RowList`           | `rows: RowWithSegments[]`                                  | Splits rows into left/right sections, renders RowCards    |
| `RowCard`           | `row: RowWithSegments`                                     | Summary card for a single row (segments bar, badge info)  |
| `RowDetail`         | `rowId: number` → emits `saved`                            | Full row editor on RowPage — manages segments             |
| `SegmentBar`        | `segments: Segment[], rowLength: number` → emits `select`  | Visual bar showing segment proportions with colors        |
| `SegmentEditor`     | `segment, index, rowLength, remainingPct, readonly`        | Single-segment edit form (vegetable, length, dates, etc.) |
| `VegetableSelect`   | `modelValue: string` → emits `update:modelValue`           | Searchable vegetable dropdown (v-model compatible)        |
| `GardenMiniMap`     | `rows: RowWithSegments[], activeRowId?: number`            | Bird's-eye mini-map of all rows with color-coded segments |
| `AerialView`        | `open: boolean` → emits `close`                            | Full-screen aerial/satellite view modal                   |
| `PipeMap`           | `open: boolean` → emits `close`                            | Pipe/irrigation mapping modal                             |
| `GardenExport`      | `open: boolean, rows: RowWithSegments[]`                   | Export garden data modal                                  |
| `NurseryOrder`      | `open: boolean, rows: RowWithSegments[]` → emits `close`   | Nursery order summary modal                               |

## Composable API

All composables use module-scope `ref`s (singleton pattern — no Pinia/Vuex).

| Composable             | Shared state                  | Key functions                                          |
|------------------------|-------------------------------|--------------------------------------------------------|
| `useAuth()`            | `user`, `loading`             | `signIn(email, password)`, `signOut()`                 |
| `useRows()`            | `rows`, `loading`, `error`    | `fetchRows()`, `updateRow(id, updates)`                |
| `useSegments()`        | `saving`                      | `fetchSegments(rowId)`, `deleteSegment(id)`, `saveAllSegments(rowId, segments)` — uses `save_segments` RPC |
| `useVegetables()`      | `vegetables`                  | `fetchVegetables()`, `addVegetable(name)`, `getVegetableColor(name)` |
| `useArchive()`         | `archiving`                   | `archiveRow(rowId)`, `fetchHistory(rowId)`             |
| `usePipeMappings()`    | `pipeMappings`, `loading`, `error` | `fetchPipeMappings()`, `updatePipeMapping(pipeNumber, description)` |
| `usePlantingEstimate`  | (pure function, no state)     | `estimatePlanting(segmentLengthM, dripSpacingCm, spacingCm, lines)` → `PlantingEstimate` |

## Database Schema

Supabase tables (Postgres). RLS enabled — see `20250101000004_auth_rls.sql`.

### `rows`
| Column           | Type                     | Notes                    |
|------------------|--------------------------|--------------------------|
| `id`             | integer (PK)             | Row number (1–27)        |
| `length_m`       | numeric                  | Row length in meters     |
| `drip_spacing_cm`| numeric                  | Drip emitter spacing     |
| `pipes_count`    | integer                  | Number of drip pipes     |
| `section`        | `'left'` or `'right'`    | Garden section           |
| `notes`          | text (nullable)          |                          |
| `has_trellis`    | boolean                  |                          |

### `segments`
| Column       | Type               | Notes                             |
|--------------|--------------------|-----------------------------------|
| `id`         | uuid (PK)          |                                   |
| `row_id`     | integer (FK→rows)  |                                   |
| `position`   | integer            | Order within the row              |
| `vegetable`  | text               | Vegetable name (Hebrew)           |
| `planted_at` | date (nullable)    |                                   |
| `length_m`   | numeric (nullable) |                                   |
| `notes`      | text (nullable)    |                                   |
| `is_planned` | boolean            | Planned vs actually planted       |
| `created_at` | timestamptz        |                                   |
| `updated_at` | timestamptz        |                                   |

### `segment_history`
Same as `segments` but with `archived_at` timestamp instead of `created_at`/`updated_at`. Used for crop rotation tracking.

### `vegetables`
| Column          | Type               | Notes                              |
|-----------------|--------------------|------------------------------------|
| `id`            | uuid (PK)          |                                    |
| `name`          | text (unique)      | Hebrew name                        |
| `icon`          | text (nullable)    | Emoji icon                         |
| `days_to_harvest`| integer (nullable)|                                    |
| `spacing_cm`    | integer (nullable) | Plant spacing for estimates        |
| `lines`         | `'all'`/`'sides'`/`'middle'` (nullable) | Which drip lines to plant on |
| `is_seeded`     | boolean            | Direct-seed vs transplant          |

### `pipe_mappings`
| Column        | Type      | Notes                    |
|---------------|-----------|--------------------------|
| `pipe_number` | integer (PK) | Irrigation pipe number |
| `description` | text      | What the pipe waters     |
| `updated_at`  | timestamptz |                        |

### Notable RPC
- `save_segments(p_row_id, p_segments)` — atomic upsert: deletes old segments for the row, inserts new ones.

## Migrations

Migrations live in `supabase/migrations/`. Applied with `pnpm supabase db push`.

Key migration files:
- `20250101000001_create_tables.sql` — initial tables (rows, segments, vegetables)
- `20250101000002_seed_data.sql` — seed 27 rows and vegetable catalog
- `20250101000003_add_archive_and_trellis.sql` — segment_history table, has_trellis column
- `20250101000004_auth_rls.sql` — RLS policies
- `20250425000001_clean_empty_segments.sql` — cleanup migration
- `20250425000002_save_segments_rpc.sql` — save_segments RPC function
- `20250430000001_pipe_mappings.sql` — pipe_mappings table
- `20250504000001_add_spacing_columns.sql` — spacing_cm, lines, is_seeded on vegetables
- `20250504000002_add_is_planned.sql` — is_planned on segments

## Key Patterns

- **State management:** No Pinia/Vuex. Composables export module-scope `ref`s that act as shared singletons.
- **Auth:** Router `beforeEach` guard polls `loading` ref, then redirects unauthenticated users to `/login`.
- **Supabase:** Remote instance only (no local Docker). Push migrations with `pnpm supabase db push`.
- **Package manager:** `pnpm` exclusively. Never use npm or yarn.
- **Segment saving:** Segments are batch-saved via `save_segments` RPC (atomic replace), not individual upserts.
- **Vegetable colors:** Deterministic hash-based color from a fixed earthy palette (in `useVegetables`).

## Styling

DaisyUI 5 (Tailwind plugin) for UI components (`btn`, `card`, `badge`, `alert`, `modal`, `navbar`, `join`, `menu`, `loading`, etc.). Tailwind utilities for layout, spacing, positioning, and typography (`flex`, `gap-*`, `p-*`, `sticky`, `text-sm`, etc.). Prefer DaisyUI's semantic classes wherever a component exists; fall back to Tailwind utilities for structural concerns only.

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
