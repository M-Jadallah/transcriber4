# syntax=docker/dockerfile:1
# =============================================================================
# Dockerfile — realtime mini-service (Socket.io + internal /emit HTTP endpoint)
# =============================================================================
# Base: oven/bun:1 (Debian-based, has apt-get)
# Listens on port 3001.
#
# Endpoints:
#   GET  /health          → 200 OK {status:"ok"} (for healthcheck)
#   POST /emit            → internal broadcast (validates x-internal-secret header)
#   socket.io /           → default path /socket.io/ (for browser clients)
# =============================================================================

FROM oven/bun:1

WORKDIR /app

# curl for healthcheck (oven/bun:1 is Debian-based)
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency manifests + install
COPY package.json bun.lock* ./
RUN bun install --frozen-lockfile || bun install

# Copy source
COPY index.ts ./

ENV NODE_ENV=production
ENV PORT=3001

EXPOSE 3001

HEALTHCHECK --interval=15s --timeout=5s --retries=5 --start-period=10s \
  CMD curl -f http://localhost:3001/health || exit 1

CMD ["bun", "index.ts"]
