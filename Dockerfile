# ---------- Build Stage ----------
  FROM node:18-alpine AS builder
  WORKDIR /app

  # Install dependencies first (leverage Docker layer caching)
  COPY package*.json ./
  RUN npm ci --omit=dev

  # Copy the rest & build
  COPY . .
  # Accept a build-time API URL or fall back to prod value
  ARG VITE_API_URL=https://api.stock-dashboard.com
  ENV VITE_API_URL=$VITE_API_URL
  RUN npm run build           # → dist/

  # ---------- Run Stage ----------
  FROM nginx:1.25-alpine AS runner
  # Copy custom Nginx config (see file below)
  COPY nginx.conf /etc/nginx/conf.d/default.conf
  # Copy build artefacts from previous stage
  COPY --from=builder /app/dist /usr/share/nginx/html

  EXPOSE 80
  STOPSIGNAL SIGTERM
  CMD ["nginx", "-g", "daemon off;"]