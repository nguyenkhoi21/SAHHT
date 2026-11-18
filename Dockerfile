FROM node:24-slim

WORKDIR /app

COPY server/package.json server/package-lock.json ./server/
RUN cd /app/server && npm ci --omit=dev

COPY admin ./admin
COPY com.kaiqigu.cjyxyn.kvsdk ./com.kaiqigu.cjyxyn.kvsdk
COPY work ./work
COPY server ./server

ENV APP_ENV=local \
    LOCAL_AUTH_MODE=1 \
    VN_RUNTIME_CONTENT=0 \
    OFFLINE_CONTENT_OVERLAY=1 \
    LOCAL_HERO_EXTENSIONS=0 \
    RECOVERED_HERO_BATCHES=0 \
    ADMIN_DEV=0 \
    ALLOW_SYNTHETIC_AUTH=0 \
    PORT=7860 \
    ACCOUNT_DB_PATH=/app/server/data/player.db \
    JOURNAL_PATH=/app/logs/requests.jsonl

RUN mkdir -p /app/server/data /app/logs

EXPOSE 7860
CMD ["node", "/app/server/hf-entry.mjs"]
