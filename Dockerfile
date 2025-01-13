# syntax=docker/dockerfile:1
ARG NODE_VERSION=22.6.0
ARG PNPM_VERSION=9.12.0

FROM node:${NODE_VERSION}-alpine AS builder
# Install pnpm
RUN --mount=type=cache,target=/root/.npm \
    npm install -g pnpm@${PNPM_VERSION}

WORKDIR /usr/src/app

# Download dependencies
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=pnpm-lock.yaml,target=pnpm-lock.yaml \
    --mount=type=cache,target=/root/.local/share/pnpm/store \
    pnpm install --frozen-lockfile

# Copy source files
COPY . .

# Build the Next.js application
RUN pnpm build

# Production image
FROM node:${NODE_VERSION}-alpine

ENV NODE_ENV production

# Install pnpm
RUN --mount=type=cache,target=/root/.npm \
    npm install -g pnpm@${PNPM_VERSION}

WORKDIR /usr/src/app

# Copy only necessary files from builder
COPY --from=builder /usr/src/app/package.json .
COPY --from=builder /usr/src/app/pnpm-lock.yaml .
COPY --from=builder /usr/src/app/.next ./.next
COPY --from=builder /usr/src/app/public ./public

# Install production dependencies only
RUN --mount=type=cache,target=/root/.local/share/pnpm/store \
    pnpm install --prod --frozen-lockfile

# Run as non-root user
USER node

EXPOSE 3001

CMD pnpm start