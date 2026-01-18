FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js || exit 1
EXPOSE 3000
CMD ["node", "server.js"]
