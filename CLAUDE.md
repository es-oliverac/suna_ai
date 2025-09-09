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

## Development Commands

### Setup & Start
```bash
# Initial setup (guided wizard)
python setup.py

# Start the platform
python start.py
```

### Frontend (Next.js)
```bash
cd frontend
npm run dev          # Development server with turbopack
npm run build        # Production build
npm run lint         # ESLint
npm run format       # Prettier formatting
npm run format:check # Check formatting
```

### Mobile App (Expo/React Native)
```bash
cd apps/mobile
npm install
expo start           # Start development server
expo start --android # Android emulator
expo start --ios     # iOS simulator
expo start --web     # Web version
expo lint           # Linting
```

### Backend (Python)
```bash
cd backend
# Uses pyproject.toml with dependencies
# Backend testing with pytest (configured in pyproject.toml)
pytest
```

### Browser API (Docker Sandbox)
```bash
cd backend/core/sandbox/docker
npm start  # Start browser API server (Stagehand)
```

## Key Technologies

- **Backend**: FastAPI, Redis, Supabase, LiteLLM, Daytona SDK
- **Frontend**: Next.js 15, TailwindCSS, Radix UI, TanStack Query
- **Mobile**: Expo, React Native, Zustand state management
- **Agent Runtime**: Docker, browser automation (Stagehand), code interpreter
- **Database**: Supabase (PostgreSQL) with real-time subscriptions

## Project Structure Notes

- Agent tools and capabilities are in `backend/core/`
- UI components follow Radix UI patterns in `frontend/components/ui/`
- Mobile components are in `apps/mobile/components/` with tool views for different agent capabilities
- File operations and tool renderers handle various file types (PDF, CSV, Markdown, etc.)
- Configuration files use environment variables and are set up via the setup wizard

## Development Workflow

1. Run `python setup.py` for initial configuration (Supabase, Redis, LLM providers, etc.)
2. Use `python start.py` to launch the full platform
3. Frontend and mobile apps can be developed independently
4. Agent sandbox environments are containerized for security and isolation