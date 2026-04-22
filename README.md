# גינה קהילתית — Community Garden Planner

A mobile-first web app for managing a community garden with 27 rows, built with Vue 3 + TypeScript + Tailwind CSS + Supabase.

## Setup

### 1. Supabase

Create a [Supabase](https://supabase.com) project and run the SQL migrations in order:

```bash
# In Supabase SQL editor, run:
supabase/migrations/001_create_tables.sql
supabase/migrations/002_seed_data.sql
```

### 2. Environment

```bash
cp .env.example .env
# Fill in your Supabase project URL and publishable key
```

### 3. Install & Run

```bash
pnpm install
pnpm dev
```

### 4. Build

```bash
pnpm build
```

## Features

- View all 27 garden rows grouped by section (left / right)
- Tap a row to edit its segments (up to 3 different vegetables per row)
- Searchable vegetable selector with autocomplete
- Track planting dates with days-since-planting badges
- Proportional colored segment bars
- Edit row properties (length, drip spacing, pipe count)
- Aerial photo reference modal with zoom/pan
- Full Hebrew RTL interface
