# YCulture Backend

Real-time culture quiz game backend built with Node.js, Socket.io, PostgreSQL, and Redis.

## Quick Start

### Prerequisites
- Node.js 20.x+
- Docker & Docker Compose

### Setup

1. **Install dependencies**
```bash
npm install
```

2. **Configure environment**
```bash
cp .env.example .env
# Edit .env with your configuration
```

3. **Start Docker services**
```bash
docker compose up -d
```

4. **Run development server**
```bash
npm run dev
```

## Docker Services

- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379
- **pgAdmin**: http://localhost:5050 (admin@yculture.local / admin)
- **Redis Insight**: http://localhost:8001

## Scripts

- `npm run dev` - Start development server
- `npm run build` - Build TypeScript
- `npm run start` - Start production server
- `npm run docker:up` - Start Docker services
- `npm run docker:down` - Stop Docker services
- `npm run docker:reset` - Reset all Docker data
- `npm run db:shell` - PostgreSQL shell
- `npm run redis:cli` - Redis CLI

## Project Structure

```
backend/
├── src/
│   ├── config/       # Configuration
│   ├── controllers/  # Request handlers
│   ├── middleware/   # Auth, validation
│   ├── models/       # Database models
│   ├── routes/       # API routes
│   ├── services/     # Business logic
│   ├── socket/       # Socket.io handlers
│   ├── types/        # TypeScript types
│   └── utils/        # Helpers
├── database/
│   ├── migrations/   # SQL migrations
│   └── seeds/        # Seed data
├── tests/
└── docs/             # Documentation
```

## Documentation

- [Project Overview](docs/PROJECT.md)
- [Database Schema](docs/DATABASE.md)
- [Technology Stack](docs/TECHNOLOGY.md)
- [Development TODO](docs/TODO.md)

## License

MIT
