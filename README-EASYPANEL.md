# 🚀 Kortix/Suna - Instalación en EasyPanel

Esta guía te permitirá instalar Kortix/Suna completo en EasyPanel usando Docker Compose con todos los servicios incluidos.

## ✨ ¿Qué incluye esta instalación?

- 🐘 **PostgreSQL** - Base de datos principal (reemplaza Supabase)
- 🔄 **Redis** - Cache y manejo de sesiones
- 🐍 **Backend API** - Python/FastAPI con todas las funcionalidades
- ⚙️ **Background Worker** - Procesamiento de agentes en segundo plano
- ⚛️ **Frontend** - Interfaz web completa en Next.js
- 🔐 **Autenticación completa** - Sistema de usuarios y equipos
- 🤖 **Ejecución de agentes** - Sandbox seguro para IA
- 📊 **Sistema de créditos** - Control de uso y facturación

## 🛠️ Requisitos Previos

1. **EasyPanel** configurado y funcionando
2. **Dominio** apuntando a tu servidor
3. **APIs de IA** - Al menos una clave API (OpenAI, Anthropic, etc.)
4. **APIs de búsqueda** - Tavily y Firecrawl
5. **Daytona API** - Para ejecución de agentes

## 📋 Instalación Paso a Paso

### 1. Preparar archivos

1. Descarga estos archivos a tu servidor:
   - `docker-compose.easypanel.yml`
   - `init.sql`
   - `.env.easypanel.example`

2. Copia el archivo de environment:
   ```bash
   cp .env.easypanel.example .env
   ```

### 2. Configurar variables de entorno

Edita el archivo `.env` y configura las siguientes variables **OBLIGATORIAS**:

#### 🔐 Configuración básica
```bash
# Cambia esto por tu dominio real
WEBHOOK_BASE_URL=https://tu-dominio.com

# Base de datos (cambia las contraseñas)
POSTGRES_PASSWORD=contraseña_super_segura
JWT_SECRET=clave_jwt_muy_segura_minimo_32_caracteres
```

#### 🤖 APIs de IA (al menos una obligatoria)
```bash
# OpenAI
OPENAI_API_KEY=sk-...

# Anthropic
ANTHROPIC_API_KEY=sk-ant-...

# OpenRouter (alternativa)
OPENROUTER_API_KEY=sk-or-...
```

#### 🔍 APIs de búsqueda (obligatorias)
```bash
# Tavily (https://app.tavily.com/)
TAVILY_API_KEY=tvly-...

# Firecrawl (https://firecrawl.dev/)
FIRECRAWL_API_KEY=fc-...
```

#### 🏗️ Daytona Sandbox (obligatorio)
```bash
# Daytona (https://app.daytona.io/)
DAYTONA_API_KEY=tu-clave-daytona
```

#### 🔑 Claves de seguridad (genera estas claves)
```bash
# Genera con: openssl rand -base64 32
ENCRYPTION_KEY=...
MCP_CREDENTIAL_ENCRYPTION_KEY=...

# Genera con: openssl rand -hex 32
TRIGGER_WEBHOOK_SECRET=...
KORTIX_ADMIN_API_KEY=...
```

### 3. Crear en EasyPanel

1. **Crea un nuevo proyecto** en EasyPanel
2. **Sube los archivos** al directorio del proyecto
3. **Configura el dominio** en EasyPanel
4. **Ejecuta el docker-compose**:

```bash
docker-compose -f docker-compose.easypanel.yml up -d
```

### 4. Verificar instalación

1. **Verifica que todos los servicios estén corriendo**:
   ```bash
   docker-compose -f docker-compose.easypanel.yml ps
   ```

2. **Revisa los logs** si hay problemas:
   ```bash
   docker-compose -f docker-compose.easypanel.yml logs backend
   ```

3. **Accede a la aplicación**:
   - Frontend: `https://tu-dominio.com`
   - API: `https://tu-dominio.com/api`

## 🔧 Configuración de Daytona

**⚠️ IMPORTANTE**: Después de instalar, debes crear un snapshot en Daytona:

1. Ve a [Daytona Snapshots](https://app.daytona.io/dashboard/snapshots)
2. Crea un nuevo snapshot con estos datos exactos:
   - **Name**: `kortix/suna:0.1.3.13`
   - **Snapshot name**: `kortix/suna:0.1.3.13`
   - **Entrypoint**: `/usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf`

## 🔒 Configuración de Seguridad

### Generar claves seguras

```bash
# JWT Secret (mínimo 32 caracteres)
openssl rand -base64 32

# Encryption Keys
openssl rand -base64 32

# Webhook Secret
openssl rand -hex 32

# Admin API Key
openssl rand -hex 32
```

### Usuario administrador

El sistema crea automáticamente un usuario admin:
- **Email**: `admin@suna.local`
- **Contraseña**: Configura en `init.sql` (línea con `encrypted_password`)

## 📊 Monitoreo

### Verificar servicios
```bash
# Estado de todos los servicios
docker-compose -f docker-compose.easypanel.yml ps

# Logs del backend
docker-compose -f docker-compose.easypanel.yml logs -f backend

# Logs del worker
docker-compose -f docker-compose.easypanel.yml logs -f worker

# Logs del frontend
docker-compose -f docker-compose.easypanel.yml logs -f frontend
```

### Healthchecks
- Backend: `https://tu-dominio.com/api/health`
- Frontend: `https://tu-dominio.com`

## 🔄 Actualizaciones

Para actualizar a una nueva versión:

```bash
# Detener servicios
docker-compose -f docker-compose.easypanel.yml down

# Actualizar imágenes
docker-compose -f docker-compose.easypanel.yml pull

# Reiniciar servicios
docker-compose -f docker-compose.easypanel.yml up -d
```

## 🗄️ Backup y Restauración

### Backup de la base de datos
```bash
docker exec postgres_container_name pg_dump -U suna_user suna > backup.sql
```

### Restaurar base de datos
```bash
docker exec -i postgres_container_name psql -U suna_user suna < backup.sql
```

## 🛠️ Solución de Problemas

### Problemas comunes

1. **Backend no arranca**:
   ```bash
   docker-compose -f docker-compose.easypanel.yml logs backend
   ```
   - Verifica variables de entorno
   - Comprueba conexión a PostgreSQL

2. **Worker no procesa tareas**:
   ```bash
   docker-compose -f docker-compose.easypanel.yml logs worker
   ```
   - Verifica conexión a Redis
   - Comprueba configuración de Daytona

3. **Frontend no carga**:
   ```bash
   docker-compose -f docker-compose.easypanel.yml logs frontend
   ```
   - Verifica variables NEXT_PUBLIC_*
   - Comprueba conexión al backend

### Reiniciar servicios específicos

```bash
# Solo backend
docker-compose -f docker-compose.easypanel.yml restart backend

# Solo worker
docker-compose -f docker-compose.easypanel.yml restart worker

# Solo frontend
docker-compose -f docker-compose.easypanel.yml restart frontend
```

## 🌟 Características Incluidas

- ✅ **Gestión de agentes IA** completa
- ✅ **Chat en tiempo real** con agentes
- ✅ **Ejecución de código** en sandbox seguro
- ✅ **Navegación web** automatizada
- ✅ **Gestión de archivos** y knowledge base
- ✅ **Sistema de equipos** y colaboración
- ✅ **API REST** completa
- ✅ **Autenticación** y autorización
- ✅ **Sistema de créditos** y facturación
- ✅ **Integraciones** con servicios externos

## 🆘 Soporte

Si tienes problemas con la instalación:

1. **Revisa los logs** de todos los servicios
2. **Verifica las variables de entorno** en el archivo `.env`
3. **Comprueba la conectividad** de las APIs externas
4. **Consulta la documentación** original de Suna

## 📝 Notas Importantes

- **Dominio**: Asegúrate de que tu dominio apunte correctamente al servidor
- **HTTPS**: EasyPanel maneja automáticamente los certificados SSL
- **Recursos**: El stack completo requiere al menos 4GB RAM y 2 CPU cores
- **Persistencia**: Todos los datos se guardan en volúmenes Docker persistentes
- **Seguridad**: Cambia todas las contraseñas y claves por defecto

¡Disfruta de tu instalación completa de Kortix/Suna! 🎉