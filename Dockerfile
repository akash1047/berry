FROM node:23-alpine AS base
RUN apk add --no-cache --update openssl
RUN addgroup -S me && adduser -S berry -G me

WORKDIR /app

FROM base AS deps
COPY package*.json ./
RUN npm ci

FROM base AS build
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

COPY --from=deps --chown=berry:me /app/node_modules ./node_modules/
COPY . .
RUN npm run build

FROM base AS test
COPY --from=build --chown=berry:me /app/node_modules ./node_modules/
COPY --from=build --chown=berry:me /app/package*.json ./

USER berry
RUN npm run test

FROM base AS release
COPY --from=build --chown=berry:me /app/node_modules ./node_modules/
COPY --from=build --chown=berry:me /app/.next ./.next/
COPY --from=build --chown=berry:me /app/public ./public/
COPY --from=build --chown=berry:me /app/package*.json ./

USER berry

ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

ENTRYPOINT [ "npm", "start" ]
