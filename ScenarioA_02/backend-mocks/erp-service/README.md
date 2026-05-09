# ERP Mock Service

Mock ERP service for Production Order Consolidation Demo - IBM Cloud Pak for Integration Scenario A.

## Overview

This service simulates an Enterprise Resource Planning (ERP) system providing order management APIs. It's designed to demonstrate integration patterns with IBM App Connect Enterprise and API Connect.

## Features

- ✅ RESTful API for order management
- ✅ OAuth2 Bearer token authentication
- ✅ PostgreSQL database integration
- ✅ Request rate limiting
- ✅ Comprehensive logging with Winston
- ✅ Health and readiness checks
- ✅ Configurable latency simulation
- ✅ Error simulation for testing
- ✅ OpenShift-ready containerization
- ✅ Graceful shutdown handling

## Prerequisites

- Node.js >= 18.0.0
- PostgreSQL >= 13
- npm >= 9.0.0

## Installation

```bash
# Install dependencies
npm install

# Copy environment configuration
cp .env.example .env

# Edit .env with your configuration
nano .env
```

## Configuration

Key environment variables:

```bash
# Server
PORT=3001
NODE_ENV=development

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=production_orders
DB_USER=postgres
DB_PASSWORD=your_password

# Security
JWT_SECRET=your_secret_here
ENABLE_AUTH=true

# Performance Simulation
SIMULATE_LATENCY=true
MIN_LATENCY_MS=50
MAX_LATENCY_MS=200
```

## Running the Service

### Development Mode

```bash
npm run dev
```

### Production Mode

```bash
npm start
```

### Docker

```bash
# Build image
docker build -t erp-service:latest .

# Run container
docker run -p 3001:3001 --env-file .env erp-service:latest
```

## API Endpoints

### Health Checks

- `GET /health` - Service health status
- `GET /ready` - Readiness check (includes DB connection)
- `GET /metrics` - Service metrics

### Orders API

Base path: `/api/v1/orders`

#### Get All Orders

```http
GET /api/v1/orders
Authorization: Bearer <token>

Query Parameters:
- status: CREATED | IN_PROGRESS | COMPLETED | CANCELLED | ON_HOLD
- priority: LOW | NORMAL | HIGH | URGENT
- plantCode: string
- customerId: string
- limit: number (1-100, default: 50)
- offset: number (default: 0)
```

#### Get Order by ID

```http
GET /api/v1/orders/:orderId
Authorization: Bearer <token>
```

#### Get Order Statistics

```http
GET /api/v1/orders/statistics
Authorization: Bearer <token>
```

## Authentication

The service uses OAuth2 Bearer token authentication. Include the token in the Authorization header:

```http
Authorization: Bearer <your-jwt-token>
```

### Generating Test Tokens

For development/testing, you can generate test tokens:

```javascript
const { generateTestToken } = require('./src/middleware/auth');
const token = generateTestToken({ sub: 'test-user', scope: 'read:orders' });
console.log(token);
```

## Database Schema

The service uses the following main table:

```sql
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    order_num VARCHAR(100) NOT NULL,
    customer_id VARCHAR(50) NOT NULL,
    customer_name VARCHAR(200) NOT NULL,
    order_date TIMESTAMP NOT NULL,
    delivery_date TIMESTAMP,
    status VARCHAR(50) NOT NULL,
    total_amount DECIMAL(15,2),
    currency VARCHAR(3) DEFAULT 'EUR',
    plant_code VARCHAR(10),
    plant_name VARCHAR(200),
    priority VARCHAR(20) DEFAULT 'NORMAL',
    -- ... additional fields
);
```

## Response Format

### Success Response

```json
{
  "data": {
    "order_id": "ORD-2026-001",
    "orderNumber": "PO-2026-001234",
    "customerName": "Leonardo S.p.A.",
    "status": "IN_PROGRESS",
    // ... additional fields
  },
  "metadata": {
    "timestamp": "2026-05-08T14:30:00.000Z",
    "responseTime": "45ms",
    "source": "ERP"
  }
}
```

### Error Response

```json
{
  "error": "Not Found",
  "message": "Order with ID ORD-2026-999 not found",
  "timestamp": "2026-05-08T14:30:00.000Z"
}
```

## Deployment on OpenShift

### Build and Push Image

```bash
# Build image
docker build -t registry.example.com/erp-service:1.0.0 .

# Push to registry
docker push registry.example.com/erp-service:1.0.0
```

### Deploy to OpenShift

```bash
# Create deployment
oc new-app registry.example.com/erp-service:1.0.0 \
  --name=erp-service \
  -e DB_HOST=postgresql \
  -e DB_NAME=production_orders \
  -e DB_USER=postgres \
  -e DB_PASSWORD=<password>

# Expose service
oc expose svc/erp-service

# Create route
oc create route edge erp-service \
  --service=erp-service \
  --port=3001
```

## Testing

### Manual Testing

```bash
# Health check
curl http://localhost:3001/health

# Get orders (with auth disabled)
curl http://localhost:3001/api/v1/orders

# Get specific order
curl http://localhost:3001/api/v1/orders/ORD-2026-001
```

### With Authentication

```bash
# Get token (example)
TOKEN="your-jwt-token-here"

# Make authenticated request
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:3001/api/v1/orders/ORD-2026-001
```

## Monitoring

### Logs

Logs are written to:
- Console (stdout/stderr)
- `logs/combined.log` - All logs
- `logs/error.log` - Error logs only

### Metrics

Access metrics at `/metrics` endpoint:

```bash
curl http://localhost:3001/metrics
```

## Performance Tuning

### Database Connection Pool

Adjust in `.env`:

```bash
DB_MAX_CONNECTIONS=20
DB_IDLE_TIMEOUT=30000
DB_CONNECTION_TIMEOUT=2000
```

### Rate Limiting

```bash
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX_REQUESTS=100
```

## Troubleshooting

### Database Connection Issues

```bash
# Check database connectivity
psql -h localhost -U postgres -d production_orders

# Verify environment variables
echo $DB_HOST $DB_PORT $DB_NAME
```

### Authentication Issues

```bash
# Disable auth for testing
ENABLE_AUTH=false npm start

# Check JWT secret configuration
echo $JWT_SECRET
```

## Development

### Project Structure

```
erp-service/
├── src/
│   ├── config/
│   │   └── database.js       # Database configuration
│   ├── controllers/
│   │   └── orderController.js # Business logic
│   ├── middleware/
│   │   └── auth.js           # Authentication middleware
│   ├── routes/
│   │   └── orders.js         # API routes
│   ├── utils/
│   │   └── logger.js         # Logging configuration
│   └── index.js              # Main entry point
├── logs/                     # Log files
├── .env.example              # Environment template
├── Dockerfile                # Container definition
├── package.json              # Dependencies
└── README.md                 # This file
```

### Adding New Endpoints

1. Create controller function in `src/controllers/`
2. Add route in `src/routes/`
3. Add validation middleware
4. Update this README

## License

MIT

## Support

For issues and questions, contact the Integration Team.