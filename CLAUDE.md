# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is Kortix/Suna - an open source platform for building, managing, and training AI agents. Suna is the flagship generalist AI worker that demonstrates the platform's capabilities.

## Architecture

The codebase follows a multi-component architecture:

- **Backend** (`backend/`): Python/FastAPI service handling agent orchestration, LLM integration, thread management
- **Frontend** (`frontend/`): Next.js/React dashboard for agent management and chat interfaces  
- **Mobile App** (`apps/mobile/`): React Native/Expo app for mobile access
- **Agent Runtime** (`backend/core/sandbox/`): Docker-based isolated execution environments
- **SDK** (`sdk/`): Python SDK for platform integration

The actual working directory is `suna/` - most development work happens in this subdirectory.

## Development Commands

### Setup & Start
```bash
# Initial setup (guided wizard) - run from suna/ directory
cd suna && python setup.py

# Start the platform - run from suna/ directory  
cd suna && python start.py
```

### Frontend (Next.js)
```bash
cd suna/frontend
npm run dev          # Development server with turbopack
npm run build        # Production build
npm run start        # Production server
npm run lint         # ESLint
npm run format       # Prettier formatting
npm run format:check # Check formatting
```

### Mobile App (Expo/React Native)
```bash
cd suna/apps/mobile
npm install
expo start           # Start development server
expo start --android # Android emulator
expo start --ios     # iOS simulator
expo start --web     # Web version
expo lint           # Linting
```

### Backend (Python)
```bash
cd suna/backend
# Uses pyproject.toml with uv package manager
pytest               # Run tests (configured in pyproject.toml)
uv run api.py        # Start API server manually
uv run dramatiq run_agent_background  # Start background worker manually
uv sync              # Install/update dependencies
```

### Browser API (Docker Sandbox)
```bash
cd suna/backend/core/sandbox/docker
npm start  # Start browser API server (Stagehand)
```

### Docker Commands
```bash
# From suna/ directory (local development)
docker compose up -d        # Start all services
docker compose down         # Stop all services  
docker compose up redis -d  # Start only infrastructure (for manual setup)
docker compose logs -f      # Follow logs
docker compose ps          # Check service status
```

### EasyPanel Deployment
```bash
# Use the complete EasyPanel configuration
docker-compose.easypanel.yml  # Full production setup with PostgreSQL instead of Supabase
.env.easypanel.example       # Complete environment variable reference
validate-installation.sh     # Installation verification script
```

### Testing Commands
```bash
# Backend tests
cd suna/backend && pytest

# Frontend tests (if configured)
cd suna/frontend && npm run test

# Mobile tests (if configured)  
cd suna/apps/mobile && npm run test
```

## Key Technologies

- **Backend**: FastAPI, Redis, Supabase, LiteLLM, Daytona SDK, Dramatiq (background tasks)
- **Frontend**: Next.js 15, TailwindCSS, Radix UI, TanStack Query, TypeScript
- **Mobile**: Expo, React Native, Zustand state management
- **Agent Runtime**: Docker, browser automation (Stagehand), code interpreter
- **Database**: Supabase (PostgreSQL) with real-time subscriptions
- **Package Management**: uv for Python, npm for Node.js
- **Environment**: mise.toml specifies Node 20, Python 3.11.10, uv 0.6.5

## Project Structure Notes

- Agent tools and capabilities are in `suna/backend/core/tools/`
- Core agent logic is in `suna/backend/core/` including agent runs, service layer, and orchestration
- UI components follow Radix UI patterns in `suna/frontend/components/ui/`
- Mobile components are in `suna/apps/mobile/components/` with tool views for different agent capabilities  
- File operations and tool renderers handle various file types (PDF, CSV, Markdown, etc.)
- Configuration files use environment variables and are set up via the setup wizard
- Setup progress is saved in `.setup_progress` file and can be resumed
- Environment files: `backend/.env` and `frontend/.env.local`

## Agent System Architecture

- **Agent Tools**: Individual capabilities in `backend/core/tools/` (browser, files, web search, etc.)
- **Agent Runtime**: Docker-based sandboxed execution in `backend/core/sandbox/`
- **Agent Builder Tools**: Dynamic agent creation and management capabilities
- **Background Workers**: Dramatiq workers for async agent execution
- **Tool System**: Dual schema decorators (OpenAPI + XML) for LLM and API integration
- **MCP Integration**: Model Context Protocol support for extensible tool integration

## Development Workflow

### Local Development
1. **Initial Setup**: Run `python setup.py` from `suna/` directory for guided configuration (Supabase, Redis, LLM providers, etc.)
2. **Start Platform**: Use `python start.py` from `suna/` directory to launch the full platform 
3. **Two Setup Methods**: 
   - Docker (recommended): All services via docker-compose
   - Manual: Individual service startup for development
4. **Frontend and mobile apps** can be developed independently
5. **Agent sandbox environments** are containerized for security and isolation

### Production Deployment (EasyPanel)
1. **Use EasyPanel Config**: `docker-compose.easypanel.yml` includes full production stack
2. **Database**: Self-hosted PostgreSQL 16 with optimized configuration (replaces Supabase)
3. **Services Included**: Backend API, Background Worker, Frontend, Redis, PostgreSQL
4. **Resource Optimization**: Configured memory limits, health checks, and auto-scaling
5. **Complete Environment**: 70+ environment variables for full feature support

## Setup Requirements

### Local Development Setup
The setup wizard will configure:
- **Required**: Supabase project, LLM provider API keys, Daytona account, Tavily API, Firecrawl API
- **Optional**: RapidAPI, Composio integration, MCP configuration
- **Infrastructure**: Redis, webhook configuration, JWT secrets

### EasyPanel Production Setup
- **LLM Providers**: At least one (OpenAI, Anthropic, OpenRouter, Gemini, Groq, XAI, Morph)
- **Search APIs**: Tavily API (required), Firecrawl API (required), RapidAPI (optional)
- **Agent Execution**: Daytona API key (required for sandboxed agent execution)
- **Security Keys**: JWT secret, encryption keys, webhook secrets (auto-generated)
- **Integrations**: Composio, Pipedream, Google OAuth, Zendesk (all optional)
- **Monitoring**: Langfuse, PostHog (optional)
- **Billing**: Stripe (optional)

## Development Guidelines

### Code Quality Standards
- **Type Safety**: Strict TypeScript frontend, comprehensive Python type hints
- **Error Handling**: Structured error responses, proper exception handling  
- **Logging**: Structured logging with context throughout the stack
- **Testing**: Unit tests for core logic, integration tests for APIs
- **Security**: Input validation, authentication, encryption for sensitive data

### Frontend Conventions
- Next.js App Router with TypeScript
- Radix UI components for consistent design system
- TanStack Query for server state management
- Zustand for client state management
- Tailwind CSS with custom design tokens

### Backend Conventions  
- FastAPI with async/await patterns
- Pydantic models for validation and serialization
- Dependency injection for database connections and services
- Structured error responses with proper HTTP status codes
- Redis for caching and session management

### Agent Development
- Tools follow dual schema pattern (OpenAPI + XML decorators)
- Sandboxed execution in Docker containers
- Proper timeout handling and resource limits
- Consistent ToolResult format across all tools
- MCP integration for extensible tool ecosystem

## Troubleshooting

### Local Development
- If setup fails, delete `.setup_progress` to restart from beginning
- For manual setup, ensure Redis is running via `docker compose up redis -d`
- Check service status with `docker compose ps`
- Setup wizard supports resume functionality if interrupted
- Check `.cursor/rules/` directory for component-specific development guidance

### EasyPanel Deployment
- Use `validate-installation.sh` to verify deployment status
- Check service logs: `docker compose -f docker-compose.easypanel.yml logs -f [service]`
- Verify environment variables are set correctly using `.env.easypanel.example` as reference
- Database initialization: `init.sql` creates complete schema with admin user
- Resource issues: Adjust memory limits in docker-compose configuration
- Check EasyPanel documentation for platform-specific deployment issues

## Deployment Configurations

### Local vs Production
- **Local**: Uses `suna/docker-compose.yaml` with Supabase integration
- **EasyPanel**: Uses `docker-compose.easypanel.yml` with self-hosted PostgreSQL
- **Environment**: Local uses `.env` files, EasyPanel uses environment variables
- **Database**: Local connects to Supabase, EasyPanel uses containerized PostgreSQL 16
- **Scale**: Local single-instance, EasyPanel production-ready with resource limits