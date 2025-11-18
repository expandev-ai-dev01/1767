# BookNest Backend API

Backend API for BookNest - Personal library management and virtual book club platform.

## Features

- RESTful API architecture
- TypeScript for type safety
- Express.js framework
- SQL Server database
- Multi-tenancy support
- Automatic database migrations
- Comprehensive error handling
- Security middleware (Helmet, CORS)
- Request compression
- Logging with Morgan

## Prerequisites

- Node.js >= 18.0.0
- npm >= 9.0.0
- SQL Server database

## Installation

```bash
npm install
```

## Configuration

1. Copy `.env.example` to `.env`
2. Configure environment variables:
   - Database connection settings
   - Server port and API version
   - CORS origins
   - Security settings

## Development

```bash
# Start development server with hot reload
npm run dev

# Run tests
npm test

# Run tests in watch mode
npm run test:watch

# Generate test coverage report
npm run test:coverage

# Lint code
npm run lint

# Fix linting issues
npm run lint:fix
```

## Production

```bash
# Build for production
npm run build

# Start production server
npm start
```

## Database Migrations

Migrations run automatically on server startup. To run manually:

```bash
npm run migrate
```

## API Documentation

API is available at:
- Development: `http://localhost:3000/api/v1`
- Production: `https://api.yourdomain.com/api/v1`

### Health Check

```
GET /health
```

Returns server health status.

## Project Structure

```
backend/
├── src/
│   ├── api/              # API controllers
│   ├── routes/           # Route definitions
│   ├── middleware/       # Express middleware
│   ├── services/         # Business logic
│   ├── utils/            # Utility functions
│   ├── constants/        # Application constants
│   ├── instances/        # Service instances
│   ├── migrations/       # Database migration runner
│   ├── tests/            # Global test utilities
│   └── server.ts         # Application entry point
├── database/             # SQL migration files
├── migrations/           # Consolidated migrations
└── dist/                 # Compiled output
```

## License

MIT
