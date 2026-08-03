#!/bin/sh
# =============================================================================
# docker-entrypoint.sh — app container entrypoint
# =============================================================================
# Runs Prisma migrations against the POSTGRES schema, then starts the Next.js
# standalone server (node server.js).
#
# This is the default CMD for the app service. Worker services override
# `command:` in docker-compose.yml and bypass this entrypoint.
# =============================================================================

set -e

echo "[entrypoint] Container starting as $(id -un) (uid=$(id -u))"
echo "[entrypoint] Working directory: $(pwd)"
echo "[entrypoint] DATABASE_URL is set: ${DATABASE_URL:+yes}${DATABASE_URL:-no}"

# ─── Run Prisma migrations ────────────────────────────────────────────────────
# Try `migrate deploy` first (applies checked-in migrations from prisma/migrations/).
# Fall back to `db push` if no migrations folder exists (first deploy / proto schema).
echo "[entrypoint] Running prisma migrate deploy (postgres schema)..."

if npx prisma migrate deploy --schema=prisma/schema.postgres.prisma 2>&1; then
  echo "[entrypoint] ✓ Migrations applied successfully."
else
  migrate_rc=$?
  echo "[entrypoint] ⚠ migrate deploy exited with $migrate_rc — falling back to db push..."
  npx prisma db push \
    --schema=prisma/schema.postgres.prisma \
    --accept-data-loss \
    --skip-generate
  echo "[entrypoint] ✓ db push completed."
fi

# ─── Start Next.js standalone server ──────────────────────────────────────────
echo "[entrypoint] Starting Next.js standalone server (node server.js)..."
echo "[entrypoint]   HOSTNAME=${HOSTNAME:-0.0.0.0}"
echo "[entrypoint]   PORT=${PORT:-3000}"
echo "[entrypoint]   NODE_ENV=${NODE_ENV:-production}"

exec node server.js
