# Puerto Panul Hallazgos – Iteración 1 (Arquitectura y Plan de Implementación)

Este documento define la **primera iteración** solicitada: stack tecnológico, modelo de datos, estructura de carpetas y comandos de arranque en desarrollo.

## 1) Stack confirmado

### Backend
- **Node.js + TypeScript**
- **NestJS** (arquitectura modular y mantenible)
- **Prisma ORM** + migraciones
- **PostgreSQL** (default), con diseño portable a SQL Server/Azure SQL
- **JWT** (access + refresh), **bcrypt** para hashing
- **Nodemailer** para correos SMTP
- Integración con **Azure Speech to Text** para transcripción de audio
- Subida de archivos con `multipart/form-data` (foto/audio) hacia disco local en desarrollo y preparado para Azure Blob en producción

### Frontend móvil
- **React Native + Expo + TypeScript**
- **React Navigation**
- `expo-camera`, `expo-av`, `expo-location` para captura de foto/audio/GPS

### Frontend web
- **Next.js (App Router) + TypeScript**
- **MUI** (Material UI) para interfaz administrativa
- Cliente HTTP con `axios` + manejo de auth JWT

### Infra/DevOps
- Monorepo con workspaces
- Docker Compose para entorno local (postgres + backend + web opcional)
- Preparado para despliegue en Azure (App Service / Container Apps + Azure Database for PostgreSQL + Blob Storage)

---

## 2) Modelo de datos propuesto (implementación base)

> Convención: nombres en inglés para código/tablas y etiquetas en español en UI.

### `users`
- `id` (uuid, PK)
- `first_name` (varchar 100)
- `last_name` (varchar 100)
- `email` (varchar 255, unique)
- `password_hash` (varchar 255)
- `role` (enum: `ADMIN`, `USER`)
- `is_active` (boolean, default true)
- `must_change_password` (boolean, default true)
- `area` (varchar 120, nullable)
- `created_at` (timestamp)
- `updated_at` (timestamp)

### `findings`
- `id` (uuid, PK)
- `code` (varchar 30, unique, ejemplo `PAN-2026-000123`)
- `title` (varchar 180, nullable)
- `description` (text) — texto transcrito editable
- `source` (enum: `SEGURIDAD`, `MANTENIMIENTO`)
- `priority` (enum: `BAJA`, `MEDIA`, `ALTA`)
- `current_status` (enum: `PENDIENTE`, `EN_DESARROLLO`, `RESUELTO`)
- `location_text` (varchar 255)
- `latitude` (decimal(10,7), nullable)
- `longitude` (decimal(10,7), nullable)
- `occurrence_at` (timestamp) — fecha/hora del hallazgo
- `requester_id` (uuid, FK → users.id)
- `assignee_id` (uuid, FK → users.id)
- `created_at` (timestamp)
- `updated_at` (timestamp)

### `finding_photos`
- `id` (uuid, PK)
- `finding_id` (uuid, FK → findings.id)
- `file_url` (text)
- `storage_provider` (enum: `LOCAL`, `AZURE_BLOB`)
- `created_at` (timestamp)

### `finding_audios`
- `id` (uuid, PK)
- `finding_id` (uuid, FK → findings.id)
- `file_url` (text)
- `duration_seconds` (int, nullable)
- `transcription_text` (text, nullable)
- `transcription_provider` (enum: `AZURE_SPEECH`, `NONE`)
- `created_at` (timestamp)

### `finding_status_history`
- `id` (uuid, PK)
- `finding_id` (uuid, FK → findings.id)
- `previous_status` (enum, nullable)
- `new_status` (enum)
- `changed_by_user_id` (uuid, FK → users.id)
- `comment` (varchar 255, nullable)
- `changed_at` (timestamp)

### `finding_assignments_history` (mejora recomendada)
- `id` (uuid, PK)
- `finding_id` (uuid, FK → findings.id)
- `previous_assignee_id` (uuid, FK nullable)
- `new_assignee_id` (uuid, FK)
- `changed_by_user_id` (uuid, FK)
- `changed_at` (timestamp)

### `email_notifications_log` (auditoría operativa)
- `id` (uuid, PK)
- `finding_id` (uuid, FK)
- `type` (enum: `ASSIGNED`, `STATUS_CHANGED`)
- `recipients` (text)
- `subject` (varchar 255)
- `success` (boolean)
- `error_message` (text, nullable)
- `sent_at` (timestamp)

### `refresh_tokens`
- `id` (uuid, PK)
- `user_id` (uuid, FK → users.id)
- `token_hash` (varchar 255)
- `expires_at` (timestamp)
- `revoked_at` (timestamp, nullable)
- `created_at` (timestamp)

### Usuario administrador inicial (seed)
- Nombre: **Claudio**
- Apellido: **Sotomayor**
- Email: `claudio@puertopanul.cl`
- Password inicial: `AdminPanul!2025`
- Rol: `ADMIN`
- `must_change_password = true`

> Nota: en producción esta contraseña debe cambiarse inmediatamente y gestionarse por secreto seguro.

---

## 3) Estructura de carpetas (monorepo)

```text
puerto-panul/
  apps/
    backend/
      prisma/
        schema.prisma
        migrations/
        seed.ts
      src/
        main.ts
        app.module.ts
        common/
          guards/
          interceptors/
          filters/
          decorators/
          dto/
        config/
          env.validation.ts
        modules/
          auth/
          users/
          findings/
          files/
          transcription/
          notifications/
          exports/
          health/
        templates/
          email/
      test/
      uploads/
      package.json
      tsconfig.json
      .env.example

    mobile/
      app/
        (auth)/
        (tabs)/
        findings/
      src/
        api/
        hooks/
        store/
        components/
        utils/
        constants/
        types/
      assets/
      package.json
      app.json
      .env.example

    web/
      src/
        app/
          login/
          dashboard/
          findings/[id]/
          users/
        components/
        lib/
          api/
          auth/
        hooks/
        types/
      public/
      middleware.ts
      package.json
      next.config.ts
      .env.example

  packages/
    shared-types/
    eslint-config/
    tsconfig/

  infra/
    docker/
      docker-compose.yml
    azure/
      bicep/
      pipelines/

  docs/
    architecture.md
    api-contract.md

  package.json
  pnpm-workspace.yaml
  README.md
```

---

## 4) Comandos principales (desarrollo)

> Se propone usar **pnpm** workspaces.

### Requisitos
- Node.js 20+
- pnpm 9+
- Docker Desktop (opcional, recomendado para PostgreSQL)

### 4.1 Instalar dependencias
```bash
pnpm install
```

### 4.2 Levantar base de datos local (docker)
```bash
docker compose -f infra/docker/docker-compose.yml up -d postgres
```

### 4.3 Backend
```bash
pnpm --filter @panul/backend prisma migrate dev
pnpm --filter @panul/backend prisma db seed
pnpm --filter @panul/backend dev
```

### 4.4 Web (Next.js)
```bash
pnpm --filter @panul/web dev
```

### 4.5 Mobile (Expo)
```bash
pnpm --filter @panul/mobile dev
```

### 4.6 Ejecutar todo junto (opcional)
```bash
pnpm dev
```

---

## Decisiones y supuestos de esta iteración
- Se prioriza **NestJS + Prisma** por mantenibilidad y velocidad de construcción.
- El almacenamiento de archivos será abstraído para permitir `LOCAL` (dev) y `AZURE_BLOB` (prod).
- El flujo de transcripción se implementará vía endpoint backend para no exponer secretos de Azure en cliente móvil.
- Exportación incluirá CSV y XLSX desde backend con filtros aplicados.

## Vista previa para usuarios no técnicos (Windows)

Si solo quieres **ver cómo se ve** el aplicativo sin programar:

1. Doble clic en `VER_APP.bat` (abre la maqueta directamente), o
2. Doble clic en `INICIAR_APP_LOCAL.bat` (levanta servidor local y abre navegador), y
3. Para cerrar servidor, usa `DETENER_APP_LOCAL.bat`.

También puedes leer instrucciones simplificadas en `INSTRUCCIONES_PASO_A_PASO.txt`.
