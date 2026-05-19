# Despliegue Colecheck en VPS

> Prerequisitos: Docker, Node.js 18+, Nginx, PM2 ya instalados.

---

## 1. Clonar y preparar

```bash
sudo mkdir -p /opt/colecheck && sudo chown $USER:$USER /opt/colecheck
cd /opt/colecheck
git clone https://github.com/Blaydor09/colecheck.git .
```

---

## 2. Base de datos (PostgreSQL + Docker)

```bash
cd /opt/colecheck/database
nano .env
```

```env
POSTGRES_DB=colecheck
POSTGRES_USER=colecheck
POSTGRES_PASSWORD=TU_PASSWORD_SEGURO       # openssl rand -base64 32
POSTGRES_BIND_IP=127.0.0.1
POSTGRES_PORT=5434                         # Cambiar si 5432 está ocupado
TZ=America/La_Paz
PGTZ=America/La_Paz
DATABASE_URL=postgresql://colecheck:TU_PASSWORD_SEGURO@127.0.0.1:5434/colecheck
```

> Si el puerto 5432 ya está ocupado por otro proyecto, usa 5434 u otro libre. Verifica con: `sudo ss -tlnp | grep 543`

```bash
sudo docker-compose up -d
sudo docker exec colecheck-postgres pg_isready -U colecheck   # Verificar
```

> Si no quieres datos demo, elimina `init/002_seed_demo.sql` antes del `docker-compose up`.

---

## 3. API Backend

```bash
cd /opt/colecheck/apps/api
npm install
nano .env
```

```env
DATABASE_URL="postgresql://colecheck:TU_PASSWORD_SEGURO@127.0.0.1:5434/colecheck"
JWT_SECRET="GENERA_CON_openssl_rand_base64_64"
PORT=3005
NODE_ENV=production
```

```bash
npx prisma generate
npm run build
pm2 start dist/index.js --name colecheck-api
pm2 save

# Verificar
curl http://localhost:3005/api/v1/health
```

---

## 4. Panel Web

Antes de compilar, cambiar la URL de la API a ruta relativa (Nginx hará el proxy):

```bash
cd /opt/colecheck/apps/web
sed -i "s|http://localhost:3005/api/v1|/api/v1|" src/services/api.ts
```

```bash
npm install
npm run build
sudo mkdir -p /var/www/colecheck
sudo cp -r dist/* /var/www/colecheck/
sudo chown -R www-data:www-data /var/www/colecheck
```

---

## 5. Nginx

```bash
sudo nano /etc/nginx/sites-available/colecheck
```

```nginx
server {
    listen 80;
    server_name colecheck.tudominio.com;   # o server_name _; si usas IP
    client_max_body_size 10M;

    root /var/www/colecheck;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/v1/ {
        proxy_pass http://127.0.0.1:3005/api/v1/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location ~* \.(js|css|png|jpg|svg|ico|woff2?)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/colecheck /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

### SSL (solo con dominio)

```bash
sudo certbot --nginx -d colecheck.tudominio.com
```

---

## 6. App Móvil (apuntar al servidor)

Editar `apps/mobile_app/lib/services/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'https://colecheck.tudominio.com/api/v1';
  // Sin dominio: 'http://TU_IP_PUBLICA/api/v1'
}
```

```bash
cd apps/mobile_app && flutter build apk --release
```

APK en: `build/app/outputs/flutter-apk/app-release.apk`

---

## 7. Verificación

```bash
docker exec colecheck-postgres pg_isready -U colecheck       # DB
curl http://localhost:3005/api/v1/health                       # API
curl http://localhost/api/v1/health                             # Nginx proxy
curl -X POST http://localhost/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@colecheck.com","password":"ADMIN123"}'   # Login
```

---

## 8. Actualizar después de cambios

```bash
cd /opt/colecheck && git pull
cd apps/api && npm install && npm run build && pm2 restart colecheck-api
cd ../web && npm install && npm run build && sudo cp -r dist/* /var/www/colecheck/
```

---

## 9. Backup (cron diario)

```bash
crontab -e
```
```
0 2 * * * docker exec colecheck-postgres pg_dump -U colecheck colecheck | gzip > /opt/backups/colecheck/backup_$(date +\%Y\%m\%d).sql.gz && find /opt/backups/colecheck -name "*.sql.gz" -mtime +30 -delete
```

### Eliminar todas las conf

# 1. Detener la API
pm2 delete colecheck-api
pm2 save
# 2. Detener y eliminar la base de datos
cd /opt/colecheck/database
sudo docker-compose down -v
sudo docker rm -f colecheck-postgres 2>/dev/null
# 3. Eliminar Nginx config
sudo rm /etc/nginx/sites-enabled/colecheck
sudo rm /etc/nginx/sites-available/colecheck
sudo nginx -t && sudo systemctl reload nginx
# 4. Eliminar archivos web
sudo rm -rf /var/www/colecheck
# 5. Eliminar el proyecto
sudo rm -rf /opt/colecheck
# 6. Verificar que todo fue eliminado
pm2 status
sudo docker ps -a | grep colecheck
ls /var/www/colecheck 2>/dev/null && echo "AUN EXISTE" || echo "ELIMINADO OK"
ls /opt/colecheck 2>/dev/null && echo "AUN EXISTE" || echo "ELIMINADO OK"

