#!/bin/bash

# 🔍 Script de Validación para Suna EasyPanel
# Este script verifica que todos los archivos y configuraciones estén correctos

echo "🔍 Validando instalación de Suna para EasyPanel..."
echo "================================================"

ERRORS=0
WARNINGS=0

# Función para mostrar errores
show_error() {
    echo "❌ ERROR: $1"
    ERRORS=$((ERRORS + 1))
}

# Función para mostrar advertencias
show_warning() {
    echo "⚠️  WARNING: $1"
    WARNINGS=$((WARNINGS + 1))
}

# Función para mostrar éxito
show_success() {
    echo "✅ $1"
}

echo ""
echo "📁 Verificando archivos requeridos..."
echo "-------------------------------------"

# Verificar archivos esenciales
if [ -f "docker-compose.easypanel.yml" ]; then
    show_success "docker-compose.easypanel.yml encontrado"
else
    show_error "docker-compose.easypanel.yml no encontrado"
fi

if [ -f "init.sql" ]; then
    show_success "init.sql encontrado"
    # Verificar que el archivo tenga contenido suficiente
    LINES=$(wc -l < init.sql)
    if [ $LINES -gt 400 ]; then
        show_success "init.sql tiene $LINES líneas (esquema completo)"
    else
        show_warning "init.sql tiene solo $LINES líneas (podría estar incompleto)"
    fi
else
    show_error "init.sql no encontrado"
fi

if [ -f ".env" ]; then
    show_success ".env encontrado"
else
    if [ -f ".env.easypanel.example" ]; then
        show_warning ".env no encontrado, pero .env.easypanel.example está disponible"
        echo "💡 Ejecuta: cp .env.easypanel.example .env"
    else
        show_error ".env y .env.easypanel.example no encontrados"
    fi
fi

if [ -f "postgres.conf" ]; then
    show_success "postgres.conf encontrado"
else
    show_warning "postgres.conf no encontrado (usará configuración por defecto)"
fi

echo ""
echo "⚙️ Verificando configuración .env..."
echo "-----------------------------------"

if [ -f ".env" ]; then
    # Verificar variables críticas
    if grep -q "WEBHOOK_BASE_URL=https://your-domain.com" .env; then
        show_error "WEBHOOK_BASE_URL aún tiene el valor por defecto"
    elif grep -q "WEBHOOK_BASE_URL=https://" .env; then
        show_success "WEBHOOK_BASE_URL configurado"
    else
        show_error "WEBHOOK_BASE_URL no encontrado o mal configurado"
    fi
    
    if grep -q "POSTGRES_PASSWORD=suna_password_change_me" .env; then
        show_error "POSTGRES_PASSWORD aún tiene el valor por defecto"
    elif grep -q "POSTGRES_PASSWORD=" .env; then
        show_success "POSTGRES_PASSWORD configurado"
    else
        show_error "POSTGRES_PASSWORD no encontrado"
    fi
    
    if grep -q "JWT_SECRET=your_super_secure" .env; then
        show_error "JWT_SECRET aún tiene el valor por defecto"
    elif grep -q "JWT_SECRET=" .env && [ $(grep "JWT_SECRET=" .env | cut -d'=' -f2 | wc -c) -gt 32 ]; then
        show_success "JWT_SECRET configurado (suficientemente largo)"
    else
        show_error "JWT_SECRET no configurado o muy corto (<32 chars)"
    fi
    
    # Verificar APIs de IA
    AI_PROVIDERS=0
    if grep -q "OPENAI_API_KEY=sk-" .env; then
        show_success "OpenAI API Key configurado"
        AI_PROVIDERS=$((AI_PROVIDERS + 1))
    fi
    
    if grep -q "ANTHROPIC_API_KEY=sk-ant-" .env; then
        show_success "Anthropic API Key configurado"
        AI_PROVIDERS=$((AI_PROVIDERS + 1))
    fi
    
    if grep -q "OPENROUTER_API_KEY=sk-or-" .env; then
        show_success "OpenRouter API Key configurado"
        AI_PROVIDERS=$((AI_PROVIDERS + 1))
    fi
    
    if grep -q "GROQ_API_KEY=gsk_" .env; then
        show_success "Groq API Key configurado"
        AI_PROVIDERS=$((AI_PROVIDERS + 1))
    fi
    
    if [ $AI_PROVIDERS -eq 0 ]; then
        show_error "No se encontró ningún proveedor de IA configurado"
    elif [ $AI_PROVIDERS -eq 1 ]; then
        show_success "$AI_PROVIDERS proveedor de IA configurado"
    else
        show_success "$AI_PROVIDERS proveedores de IA configurados"
    fi
    
    # Verificar APIs de búsqueda
    if grep -q "TAVILY_API_KEY=tvly-" .env; then
        show_success "Tavily API Key configurado"
    else
        show_error "TAVILY_API_KEY no configurado"
    fi
    
    if grep -q "FIRECRAWL_API_KEY=fc-" .env; then
        show_success "Firecrawl API Key configurado"
    else
        show_error "FIRECRAWL_API_KEY no configurado"
    fi
    
    # Verificar Daytona
    if grep -q "DAYTONA_API_KEY=" .env && ! grep -q "DAYTONA_API_KEY=$" .env; then
        show_success "Daytona API Key configurado"
    else
        show_error "DAYTONA_API_KEY no configurado"
    fi
    
else
    show_error "No se puede verificar .env (archivo no existe)"
fi

echo ""
echo "🐳 Verificando Docker..."
echo "-----------------------"

if command -v docker >/dev/null 2>&1; then
    show_success "Docker instalado"
    if docker info >/dev/null 2>&1; then
        show_success "Docker daemon corriendo"
    else
        show_error "Docker daemon no está corriendo"
    fi
else
    show_error "Docker no instalado"
fi

if command -v docker-compose >/dev/null 2>&1; then
    show_success "Docker Compose instalado"
    # Verificar sintaxis del compose file
    if [ -f "docker-compose.easypanel.yml" ]; then
        if docker-compose -f docker-compose.easypanel.yml config >/dev/null 2>&1; then
            show_success "docker-compose.easypanel.yml sintaxis correcta"
        else
            show_error "docker-compose.easypanel.yml tiene errores de sintaxis"
        fi
    fi
else
    show_error "Docker Compose no instalado"
fi

echo ""
echo "💾 Verificando espacio en disco..."
echo "---------------------------------"

AVAILABLE_GB=$(df . | tail -1 | awk '{print int($4/1024/1024)}')
if [ $AVAILABLE_GB -gt 20 ]; then
    show_success "Espacio disponible: ${AVAILABLE_GB}GB (suficiente)"
elif [ $AVAILABLE_GB -gt 10 ]; then
    show_warning "Espacio disponible: ${AVAILABLE_GB}GB (mínimo recomendado: 20GB)"
else
    show_error "Espacio disponible: ${AVAILABLE_GB}GB (insuficiente - se necesitan al menos 10GB)"
fi

echo ""
echo "🌐 Verificando conectividad..."
echo "-----------------------------"

if curl -s --max-time 5 https://api.openai.com >/dev/null; then
    show_success "Conectividad a OpenAI OK"
else
    show_warning "No se puede conectar a OpenAI (podría ser por firewall)"
fi

if curl -s --max-time 5 https://api.anthropic.com >/dev/null; then
    show_success "Conectividad a Anthropic OK"
else
    show_warning "No se puede conectar a Anthropic (podría ser por firewall)"
fi

echo ""
echo "📊 RESUMEN DE VALIDACIÓN"
echo "======================="

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "🎉 ¡TODO PERFECTO! La instalación debería funcionar sin problemas."
elif [ $ERRORS -eq 0 ]; then
    echo "✅ Sin errores críticos encontrados."
    echo "⚠️  $WARNINGS advertencias - revisa las recomendaciones arriba."
    echo ""
    echo "💡 La instalación debería funcionar, pero revisa las advertencias."
else
    echo "❌ $ERRORS errores críticos encontrados."
    echo "⚠️  $WARNINGS advertencias adicionales."
    echo ""
    echo "🚫 DEBES CORREGIR LOS ERRORES ANTES DE INSTALAR"
    echo ""
    echo "📋 Lista de verificación:"
    echo "1. Configura todas las variables en .env"
    echo "2. Cambia los valores por defecto"
    echo "3. Asegúrate de tener Docker funcionando"
    echo "4. Verifica que tengas suficiente espacio en disco"
fi

echo ""
echo "🚀 Para instalar después de corregir errores:"
echo "docker-compose -f docker-compose.easypanel.yml up -d"

exit $ERRORS