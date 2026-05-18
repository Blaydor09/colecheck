# Colecheck Database

Base elegida: PostgreSQL dockerizado.

PostgreSQL encaja mejor que SQLite, MongoDB o Firebase para este sistema porque Colecheck necesita relaciones fuertes, historico confiable, reportes por fecha/curso, auditoria, roles, notificaciones y consistencia al registrar asistencia desde QR, biometria o carga manual.

## Estructura

- `init/001_schema.sql`: esquema principal.
- `init/002_seed_demo.sql`: datos de demostracion alineados con los mocks actuales.
- `docker-compose.yml`: servicio PostgreSQL para desarrollo o VPS.
- `.env.example`: variables base.

## Levantar localmente o en VPS

Desde la raiz del repo:

```bash
copy database\.env.example database\.env
docker compose -f database\docker-compose.yml --env-file database\.env up -d
```

En Linux/VPS:

```bash
cp database/.env.example database/.env
docker compose -f database/docker-compose.yml --env-file database/.env up -d
```

Cambia `POSTGRES_PASSWORD` antes de produccion. El puerto queda ligado por defecto a `127.0.0.1`, asi la base no queda expuesta publicamente en la VPS.

## Conectar

```text
postgresql://colecheck:<password>@127.0.0.1:5432/colecheck
```

Cuando creemos la API, esta URL debe vivir en una variable `DATABASE_URL` del backend.

## Datos demo

`002_seed_demo.sql` crea:

- Colegio demo.
- Usuarios para administrador, apoderado y personal.
- Estudiantes y apoderados del mock actual.
- Cursos/secciones.
- Dispositivos y ubicaciones.
- Registros de asistencia e incidencias iniciales.

Para produccion limpia, quita `002_seed_demo.sql` del montaje de inicializacion o muevelo fuera de `database/init` antes de crear el volumen por primera vez.

## Backups basicos

```bash
docker exec colecheck-postgres pg_dump -U colecheck -d colecheck > colecheck_backup.sql
```

Restaurar:

```bash
docker exec -i colecheck-postgres psql -U colecheck -d colecheck < colecheck_backup.sql
```
