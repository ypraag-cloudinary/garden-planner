#!/bin/bash
#
# Run Supabase migrations via the Management API.
#
# Prerequisites:
#   1. Create a Personal Access Token at https://supabase.com/dashboard/account/tokens
#   2. Find your project ref — it's the subdomain in your project URL
#      (e.g. for https://abcdefghijk.supabase.co the ref is "abcdefghijk")
#
# Usage:
#   SUPABASE_PAT=sbp_... PROJECT_REF=abcdefghijk ./scripts/setup-db.sh

set -e

if [ -z "$SUPABASE_PAT" ] || [ -z "$PROJECT_REF" ]; then
  echo "Usage: SUPABASE_PAT=<token> PROJECT_REF=<ref> $0"
  echo ""
  echo "  SUPABASE_PAT   — Personal Access Token from https://supabase.com/dashboard/account/tokens"
  echo "  PROJECT_REF    — Project ref (subdomain of your .supabase.co URL)"
  exit 1
fi

API="https://api.supabase.com/v1/projects/${PROJECT_REF}/database/query"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

run_sql() {
  local file="$1"
  local name="$(basename "$file")"
  echo "Running ${name}..."

  local response
  response=$(curl -s -w "\n%{http_code}" -X POST "$API" \
    -H "Authorization: Bearer ${SUPABASE_PAT}" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg q "$(cat "$file")" '{query: $q}')")

  local http_code=$(echo "$response" | tail -1)
  local body=$(echo "$response" | sed '$d')

  if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
    echo "  ✓ ${name} succeeded"
  else
    echo "  ✗ ${name} failed (HTTP ${http_code})"
    echo "  ${body}"
    exit 1
  fi
}

echo "Setting up database for project: ${PROJECT_REF}"
echo ""

run_sql "${SCRIPT_DIR}/supabase/migrations/001_create_tables.sql"
run_sql "${SCRIPT_DIR}/supabase/migrations/002_seed_data.sql"

echo ""
echo "✓ Database setup complete!"
