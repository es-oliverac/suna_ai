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
# From suna/ directory
docker compose up -d        # Start all services
docker compose down         # Stop all services  
docker compose up redis -d  # Start only infrastructure (for manual setup)
docker compose logs -f      # Follow logs
docker compose ps          # Check service status
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

- Agent tools and capabilities are in `suna/backend/core/`
- UI components follow Radix UI patterns in `suna/frontend/components/ui/`
- Mobile components are in `suna/apps/mobile/components/` with tool views for different agent capabilities
- File operations and tool renderers handle various file types (PDF, CSV, Markdown, etc.)
- Configuration files use environment variables and are set up via the setup wizard
- Setup progress is saved in `.setup_progress` file and can be resumed
- Environment files: `backend/.env` and `frontend/.env.local`

## Development Workflow

1. **Initial Setup**: Run `python setup.py` from `suna/` directory for guided configuration (Supabase, Redis, LLM providers, etc.)
2. **Start Platform**: Use `python start.py` from `suna/` directory to launch the full platform 
3. **Two Setup Methods**: 
   - Docker (recommended): All services via docker-compose
   - Manual: Individual service startup for development
4. **Frontend and mobile apps** can be developed independently
5. **Agent sandbox environments** are containerized for security and isolation

## Setup Requirements

The setup wizard will configure:
- **Required**: Supabase project, LLM provider API keys, Daytona account, Tavily API, Firecrawl API
- **Optional**: RapidAPI, Composio integration, MCP configuration
- **Infrastructure**: Redis, webhook configuration, JWT secrets

## Troubleshooting

- If setup fails, delete `.setup_progress` to restart from beginning
- For manual setup, ensure Redis is running via `docker compose up redis -d`
- Check service status with `docker compose ps`
- Setup wizard supports resume functionality if interrupted