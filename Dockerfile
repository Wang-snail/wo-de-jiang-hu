FROM node:20-slim AS build

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
ENV VITE_APP_MODE=cloud
RUN npm run build

FROM node:20-slim

RUN apt-get update && apt-get install -y --no-install-recommends python3 make g++ && rm -rf /var/lib/apt/lists/*
RUN npm install -g @openai/codex @anthropic-ai/claude-code

WORKDIR /app
COPY --from=build /app/out/mcp ./out/mcp
COPY --from=build /app/out/ui ./out/ui

WORKDIR /app/out/mcp
RUN npm install --omit=dev

WORKDIR /app
ENV NODE_ENV=production
ENV QUOROOM_DEPLOYMENT_MODE=cloud
ENV QUOROOM_NO_AUTO_OPEN=1
EXPOSE 3700

CMD ["sh", "-c", "node out/mcp/cli.js serve --port ${PORT:-3700}"]
