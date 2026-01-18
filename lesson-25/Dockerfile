FROM node:18-alpine

# Create non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

WORKDIR /app

# Copy files with correct ownership
COPY --chown=appuser:appuser package*.json ./
RUN npm ci --only=production

COPY --chown=appuser:appuser . .

# Switch to non-root user
USER appuser

# Limit exposed ports
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s CMD node healthcheck.js || exit 1

CMD ["node", "server.js"]
