FROM node:24-alpine AS build

WORKDIR /app

RUN corepack enable && corepack prepare pnpm@11.1.1 --activate

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/frontend/package.json apps/frontend/package.json

RUN pnpm install --frozen-lockfile

COPY apps/frontend apps/frontend
COPY packages packages

RUN pnpm --filter frontend build

FROM node:24-alpine AS runtime

WORKDIR /app

RUN apk add --no-cache wget

ENV NODE_ENV=production
ENV NUXT_HOST=0.0.0.0
ENV NUXT_PORT=3000

COPY --from=build /app/apps/frontend/.output ./.output

EXPOSE 3000

CMD ["node", ".output/server/index.mjs"]
