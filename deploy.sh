#!/bin/bash
# ─────────────────────────────────────────────────────────────
# Colecheck — Script de Despliegue Rápido
# Ejecutar desde el directorio raíz del proyecto: /opt/colecheck
# ─────────────────────────────────────────────────────────────
set -e

APP_DIR="/opt/colecheck"
WEB_DIR="/var/www/colecheck"
LOG_DIR="/var/log/colecheck"

echo "═══════════════════════════════════════"
echo "  Colecheck — Despliegue de Producción"
echo "═══════════════════════════════════════"
echo ""

# ── 1. Base de datos ─────────────────────────────────────────
echo "▶ [1/6] Verificando base de datos..."
cd "$APP_DIR/database"
docker-compose up -d
sleep 3
docker exec colecheck-postgres pg_isready -U colecheck
echo "✅ Base de datos OK"
echo ""

# ── 2. API — Dependencias ───────────────────────────────────
echo "▶ [2/6] Instalando dependencias de la API..."
cd "$APP_DIR/apps/api"
npm ci --production=false
echo "✅ Dependencias API OK"
echo ""

# ── 3. API — Build ──────────────────────────────────────────
echo "▶ [3/6] Compilando la API..."
npx prisma generate
npm run build
echo "✅ Build API OK"
echo ""

# ── 4. API — PM2 ────────────────────────────────────────────
echo "▶ [4/6] Iniciando/reiniciando la API con PM2..."
sudo mkdir -p "$LOG_DIR"
sudo chown "$USER":"$USER" "$LOG_DIR"
cd "$APP_DIR"
pm2 delete colecheck-api 2>/dev/null || true
pm2 start ecosystem.config.js
pm2 save
echo "✅ API corriendo con PM2"
echo ""

# ── 5. Web — Build ──────────────────────────────────────────
echo "▶ [5/6] Compilando el panel web..."
cd "$APP_DIR/apps/web"
npm ci
npm run build
sudo mkdir -p "$WEB_DIR"
sudo cp -r dist/* "$WEB_DIR/"
sudo chown -R www-data:www-data "$WEB_DIR"
echo "✅ Web compilada y desplegada"
echo ""

# ── 6. Nginx ────────────────────────────────────────────────
echo "▶ [6/6] Recargando Nginx..."
sudo nginx -t && sudo systemctl reload nginx
echo "✅ Nginx recargado"
echo ""

# ── Verificación ────────────────────────────────────────────
echo "═══════════════════════════════════════"
echo "  Verificación Final"
echo "═══════════════════════════════════════"

echo -n "  DB:  "
docker exec colecheck-postgres pg_isready -U colecheck -q && echo "✅" || echo "❌"

echo -n "  API: "
curl -sf http://localhost:3005/api/v1/health > /dev/null && echo "✅" || echo "❌"

echo -n "  Web: "
curl -sf http://localhost > /dev/null && echo "✅" || echo "❌"

echo ""
echo "═══════════════════════════════════════"
echo "  ¡Despliegue completado!"
echo "═══════════════════════════════════════"
