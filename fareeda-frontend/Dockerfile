
# =========================
# Stage 1: Builder
# =========================

FROM node:20-bookworm-slim AS builder

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ARG BRANCH
ARG GIT_TOKEN

# Clone source code
RUN git clone \
    --depth 1 \
    --single-branch \
    --branch "${BRANCH}" \
    "https://${GIT_TOKEN}@github.com/svaan-client-projects/fareeda-admin.git" .

# Install dependencies
RUN npm ci

# Force patched dependency versions
RUN npm install \
    --save-exact \
    cross-spawn@7.0.5 \
    glob@10.5.0 \
    minimatch@9.0.7 \
    tar@7.5.11

# Verify dependencies
RUN npm ls cross-spawn glob minimatch tar

# Build Next.js application
RUN npm run build


# =========================
# Stage 2: Production
# =========================

FROM node:20-bookworm-slim AS runtime

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME=0.0.0.0

# Create non-root user
RUN groupadd -r appuser && \
    useradd -r -g appuser appuser

# Copy package files
COPY --from=builder /app/package*.json ./

# Install production dependencies
RUN npm ci --omit=dev && \
    npm cache clean --force

# Copy production build
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# Set permissions
RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 3000

CMD ["npm", "start"]
