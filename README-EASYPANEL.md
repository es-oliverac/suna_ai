# 🚀 Kortix/Suna - Instalación Completa en EasyPanel

Esta guía te permitirá instalar **Kortix/Suna completo** en EasyPanel usando Docker Compose con todos los servicios incluidos y optimizados para producción.

## ✨ ¿Qué incluye esta instalación?

### 🗄️ **Infraestructura Completa**
- 🐘 **PostgreSQL 16** - Base de datos principal optimizada (reemplaza Supabase)
- 🔄 **Redis 7** - Cache y manejo de sesiones con persistencia
- 🔒 **Esquema de BD completo** - 15+ tablas con índices y triggers optimizados
- 📊 **Configuraciones de rendimiento** - Tuned para servidores con 4GB+ RAM

### 🚀 **Servicios de Aplicación**
- 🐍 **Backend API** - Python/FastAPI con todas las funcionalidades
- ⚙️ **Background Worker** - Procesamiento de agentes en segundo plano (4 procesos)
- ⚛️ **Frontend** - Interfaz web completa en Next.js con optimizaciones
- 🔐 **Autenticación completa** - Sistema de usuarios, equipos y roles
- 🤖 **Ejecución de agentes** - Sandbox seguro para IA via Daytona
- 📊 **Sistema de créditos** - Control de uso y facturación automática

### 🛠️ **Características Avanzadas**
- 📈 **Monitoreo y logs** - Health checks y logging estructurado
- 🔗 **Integraciones** - MCP, Composio, Google, Webhooks
- 📁 **Gestión de archivos** - Upload, procesamiento y knowledge base
- 🌐 **APIs de búsqueda** - Tavily y Firecrawl integrados
- ⚡ **Optimizado para producción** - Resource limits y auto-scaling

## 🛠️ Requisitos Previos

### 📋 **Requisitos del Sistema**
- **EasyPanel** configurado y funcionando
- **Servidor** con mínimo 4GB RAM y 2 CPU cores
- **Almacenamiento** mínimo 20GB disponible (recomendado 50GB+)
- **Dominio** configurado y apuntando a tu servidor EasyPanel

### 🔑 **APIs Requeridas (Obligatorias)**
- **Al menos 1 proveedor de IA**: OpenAI, Anthropic, OpenRouter, Groq, o Gemini
- **Tavily API** - Para búsquedas web ([obtener aquí](https://app.tavily.com/))
- **Firecrawl API** - Para scraping web ([obtener aquí](https://firecrawl.dev/))
- **Daytona API** - Para sandbox de agentes ([obtener aquí](https://app.daytona.io/))

### 🔧 **APIs Opcionales (Recomendadas)**
- **RapidAPI** - Para herramientas adicionales
- **Composio** - Para integraciones avanzadas
- **Google OAuth** - Para integración con Google Workspace
- **Stripe** - Para facturación (si planeas monetizar)

## 📋 Instalación Paso a Paso

### 1️⃣ **Preparar archivos**

1. **Descarga todos los archivos necesarios** a tu servidor EasyPanel:
   - `docker-compose.easypanel.yml` - Configuración Docker optimizada
   - `init.sql` - Esquema completo de base de datos (440+ líneas)
   - `.env.easypanel.example` - Variables de entorno completas
   - `postgres.conf` - Configuración PostgreSQL optimizada
   - `README-EASYPANEL.md` - Esta guía

2. **Copia y configura el archivo de environment**:
   ```bash
   cp .env.easypanel.example .env
   ```

3. **Verifica que tienes todos los archivos**:
   ```bash
   ls -la
   # Deberías ver: docker-compose.easypanel.yml, init.sql, .env, postgres.conf
   ```

### 2️⃣ **Configurar variables de entorno**

**Edita el archivo `.env`** y configura las siguientes variables **OBLIGATORIAS**:

#### 🔐 **Configuración básica (CRÍTICA)**
```bash
# Cambia esto por tu dominio real de EasyPanel
WEBHOOK_BASE_URL=https://tu-dominio.com

# Base de datos (GENERA CONTRASEÑAS SEGURAS)
POSTGRES_PASSWORD=crea_una_contraseña_muy_segura_minimo_16_chars
JWT_SECRET=$(openssl rand -base64 32)  # Ejecuta este comando para generar

# Claves de seguridad (GENERA TODAS CON OPENSSL)
ENCRYPTION_KEY=$(openssl rand -base64 32)
MCP_CREDENTIAL_ENCRYPTION_KEY=$(openssl rand -base64 32)
TRIGGER_WEBHOOK_SECRET=$(openssl rand -hex 32)
KORTIX_ADMIN_API_KEY=$(openssl rand -hex 32)
SESSION_SECRET=$(openssl rand -base64 32)
```

#### 📝 **Comando rápido para generar todas las claves**:
```bash
echo "JWT_SECRET=$(openssl rand -base64 32)"
echo "ENCRYPTION_KEY=$(openssl rand -base64 32)"  
echo "MCP_CREDENTIAL_ENCRYPTION_KEY=$(openssl rand -base64 32)"
echo "TRIGGER_WEBHOOK_SECRET=$(openssl rand -hex 32)"
echo "KORTIX_ADMIN_API_KEY=$(openssl rand -hex 32)"
echo "SESSION_SECRET=$(openssl rand -base64 32)"
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

### 3️⃣ **Desplegar en EasyPanel**

#### 📁 **Preparación del proyecto**
1. **Crea un nuevo proyecto** en EasyPanel con un nombre descriptivo (ej: "suna-ai")
2. **Sube todos los archivos** al directorio del proyecto:
   - Usa el file manager de EasyPanel o SCP/SFTP
   - Asegúrate de que todos los archivos estén en la raíz del proyecto
3. **Configura el dominio** en EasyPanel:
   - Ve a la configuración del proyecto
   - Agrega tu dominio personalizado
   - Activa HTTPS automático

#### 🚀 **Ejecutar la instalación**
```bash
# Conéctate a tu servidor via SSH
ssh tu-servidor

# Ve al directorio del proyecto
cd /path/to/your/project

# Verifica que todos los archivos estén presentes
ls -la

# Inicia todos los servicios (esto puede tomar 5-10 minutos)
docker-compose -f docker-compose.easypanel.yml up -d

# Verifica que los servicios estén iniciando
docker-compose -f docker-compose.easypanel.yml ps
```

#### ⏳ **Tiempo de inicio esperado**
- **PostgreSQL**: 30-60 segundos
- **Redis**: 10-20 segundos  
- **Backend**: 2-3 minutos (descarga imagen + inicio)
- **Worker**: 1-2 minutos
- **Frontend**: 2-3 minutos (build + inicio)

**Total**: 5-10 minutos para el primer despliegue

### 4️⃣ **Verificar instalación**

#### ✅ **Verificación de servicios**
```bash
# Ver el estado de todos los servicios
docker-compose -f docker-compose.easypanel.yml ps

# Deberías ver algo como:
# postgres    Up (healthy)
# redis       Up (healthy)  
# backend     Up (healthy)
# worker      Up
# frontend    Up (healthy)
```

#### 🔍 **Health Checks automáticos**
Los siguientes endpoints se verifican automáticamente:
- **PostgreSQL**: `pg_isready` cada 15s
- **Redis**: `redis-cli ping` cada 15s
- **Backend**: `GET /health` cada 30s
- **Frontend**: `GET /` cada 30s

#### 📋 **Logs de troubleshooting**
```bash
# Ver logs en tiempo real de todos los servicios
docker-compose -f docker-compose.easypanel.yml logs -f

# Ver logs específicos por servicio
docker-compose -f docker-compose.easypanel.yml logs backend
docker-compose -f docker-compose.easypanel.yml logs worker
docker-compose -f docker-compose.easypanel.yml logs frontend
docker-compose -f docker-compose.easypanel.yml logs postgres
```

#### 🌐 **Acceder a la aplicación**
- **Frontend Principal**: `https://tu-dominio.com`
- **API Health Check**: `https://tu-dominio.com/health`  
- **API Docs**: `https://tu-dominio.com/docs`
- **Admin Login**: `admin@suna.local` / `SunaAdmin123!`

#### 🎯 **Primer acceso**
1. Ve a `https://tu-dominio.com`
2. Haz clic en "Sign In"  
3. Usa las credenciales por defecto:
   - **Email**: `admin@suna.local`
   - **Password**: `SunaAdmin123!`
4. **¡IMPORTANTE!** Cambia la contraseña después del primer login

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

## 📊 **Recursos del Sistema Recomendados**

### 💻 **Configuración de Servidor Recomendada**
- **CPU**: 4 cores mínimo (8 cores recomendado)
- **RAM**: 8GB mínimo (16GB recomendado para uso intensivo)
- **Almacenamiento**: 50GB SSD mínimo (100GB+ recomendado)
- **Ancho de banda**: 100Mbps mínimo

### 📈 **Distribución de recursos por servicio**
```
PostgreSQL:  2GB RAM, 1 CPU core
Redis:       1.5GB RAM, 0.5 CPU core  
Backend:     4GB RAM, 2 CPU cores
Worker:      3GB RAM, 2 CPU cores
Frontend:    2GB RAM, 1 CPU core
```

## 🔄 **Mantenimiento y Actualizaciones**

### 🔄 **Actualizaciones automáticas**
```bash
# Script de actualización automática
#!/bin/bash
cd /ruta/a/tu/proyecto

# Hacer backup de la base de datos
docker exec $(docker-compose -f docker-compose.easypanel.yml ps -q postgres) \
    pg_dump -U suna_user suna > backup_$(date +%Y%m%d_%H%M%S).sql

# Detener servicios
docker-compose -f docker-compose.easypanel.yml down

# Actualizar imágenes
docker-compose -f docker-compose.easypanel.yml pull

# Reiniciar servicios
docker-compose -f docker-compose.easypanel.yml up -d

# Verificar que todo esté funcionando
sleep 60
docker-compose -f docker-compose.easypanel.yml ps
```

### 📋 **Checklist de mantenimiento semanal**
- [ ] Verificar logs de errores
- [ ] Revisar uso de espacio en disco
- [ ] Actualizar contraseñas si es necesario
- [ ] Hacer backup de la base de datos
- [ ] Verificar que todos los health checks pasen
- [ ] Revisar métricas de uso y rendimiento

## 🎯 **Optimizaciones Adicionales**

### ⚡ **Para mejor rendimiento**
1. **Configurar un reverse proxy** (Nginx/Caddy) delante de EasyPanel
2. **Activar compresión gzip** en el reverse proxy
3. **Configurar CDN** para archivos estáticos
4. **Usar Redis Cluster** para alta disponibilidad
5. **Configurar PostgreSQL replica** para lecturas

### 🔒 **Para mejor seguridad**
1. **Configurar fail2ban** para proteger SSH
2. **Usar certificados SSL personalizados** si es necesario
3. **Configurar backup automático** a almacenamiento externo
4. **Monitorear logs** con alertas automáticas
5. **Actualizar regularmente** todas las imágenes Docker

---

## 🎉 **¡Instalación Completa!**

Tu instalación de **Kortix/Suna** está ahora completamente configurada y optimizada para producción. Tienes acceso a:

✅ **Plataforma completa de agentes IA**  
✅ **Sistema de usuarios y equipos**  
✅ **Integración con múltiples proveedores de IA**  
✅ **Herramientas de búsqueda y scraping web**  
✅ **Sandbox seguro para ejecución de código**  
✅ **Sistema de créditos y facturación**  
✅ **APIs completas para integraciones**  

### 🔗 **Enlaces útiles**
- **Documentación oficial**: [GitHub Kortix/Suna](https://github.com/kortix-ai/suna)
- **Comunidad Discord**: [Únete aquí](https://discord.gg/Py6pCBUUPw)
- **Reportar issues**: [GitHub Issues](https://github.com/kortix-ai/suna/issues)

**¡Disfruta de tu instalación completa de Kortix/Suna!** 🚀