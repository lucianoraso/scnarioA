require('dotenv').config();
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const compression = require('compression');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const logger = require('./utils/logger');
const { testConnection, closePool } = require('./config/database');
const qualityChecksRoutes = require('./routes/qualityChecks');

// Inizializza Express app
const app = express();
const PORT = process.env.PORT || 3003;

// Middleware di sicurezza
app.use(helmet());

// CORS configuration
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
}));

// Compression middleware
app.use(compression());

// Body parser middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request logging con Morgan
app.use(morgan('combined', { stream: logger.stream }));

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '60000', 10), // 1 minuto
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10), // 100 richieste per finestra
  message: {
    error: 'Too many requests',
    message: 'Rate limit exceeded. Please try again later.',
    retryAfter: '60 seconds'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

app.use('/api/', limiter);

// Request ID middleware
app.use((req, res, next) => {
  req.id = `qms-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  res.setHeader('X-Request-ID', req.id);
  next();
});

// Request timing middleware
app.use((req, res, next) => {
  req.startTime = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - req.startTime;
    logger.http('Request completed', {
      method: req.method,
      path: req.path,
      statusCode: res.statusCode,
      duration: `${duration}ms`,
      requestId: req.id
    });
  });
  next();
});

// Latency simulation middleware (per testing)
app.use((req, res, next) => {
  const simulateLatency = process.env.SIMULATE_LATENCY === 'true';
  if (simulateLatency && !req.path.includes('/health') && !req.path.includes('/ready')) {
    const minLatency = parseInt(process.env.MIN_LATENCY_MS || '50', 10);
    const maxLatency = parseInt(process.env.MAX_LATENCY_MS || '200', 10);
    const latency = Math.floor(Math.random() * (maxLatency - minLatency + 1)) + minLatency;
    
    setTimeout(() => {
      logger.debug(`Simulated latency: ${latency}ms`, { path: req.path });
      next();
    }, latency);
  } else {
    next();
  }
});

// Error simulation middleware (per testing)
app.use((req, res, next) => {
  const simulateErrors = process.env.SIMULATE_ERRORS === 'true';
  if (simulateErrors && !req.path.includes('/health') && !req.path.includes('/ready')) {
    const errorRate = parseFloat(process.env.ERROR_RATE || '0.05'); // 5% default
    if (Math.random() < errorRate) {
      logger.warn('Simulated error triggered', { path: req.path });
      return res.status(500).json({
        error: 'Internal Server Error',
        message: 'Simulated error for testing purposes',
        timestamp: new Date().toISOString()
      });
    }
  }
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    service: 'qms-service',
    version: process.env.SERVICE_VERSION || '1.0.0',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Readiness check endpoint
app.get('/ready', async (req, res) => {
  try {
    const dbConnected = await testConnection();
    
    if (dbConnected) {
      res.status(200).json({
        status: 'ready',
        service: 'qms-service',
        database: 'connected',
        timestamp: new Date().toISOString()
      });
    } else {
      res.status(503).json({
        status: 'not ready',
        service: 'qms-service',
        database: 'disconnected',
        timestamp: new Date().toISOString()
      });
    }
  } catch (error) {
    logger.error('Readiness check failed', { error: error.message });
    res.status(503).json({
      status: 'not ready',
      service: 'qms-service',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Metrics endpoint (basic)
app.get('/metrics', (req, res) => {
  const memoryUsage = process.memoryUsage();
  res.status(200).json({
    service: 'qms-service',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: {
      rss: `${Math.round(memoryUsage.rss / 1024 / 1024)}MB`,
      heapTotal: `${Math.round(memoryUsage.heapTotal / 1024 / 1024)}MB`,
      heapUsed: `${Math.round(memoryUsage.heapUsed / 1024 / 1024)}MB`,
      external: `${Math.round(memoryUsage.external / 1024 / 1024)}MB`
    },
    cpu: process.cpuUsage()
  });
});

// API Routes
app.use('/api/v1/quality-checks', qualityChecksRoutes);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    service: 'QMS Service',
    version: process.env.SERVICE_VERSION || '1.0.0',
    description: 'Quality Management System Mock Service for IBM Cloud Pak for Integration Demo',
    endpoints: {
      health: '/health',
      ready: '/ready',
      metrics: '/metrics',
      api: '/api/v1/quality-checks'
    },
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use((req, res) => {
  logger.warn('Route not found', {
    method: req.method,
    path: req.path,
    ip: req.ip
  });
  
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.method} ${req.path} not found`,
    timestamp: new Date().toISOString()
  });
});

// Global error handler
app.use((err, req, res, next) => {
  logger.error('Unhandled error', {
    error: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method
  });

  res.status(err.status || 500).json({
    error: err.name || 'Internal Server Error',
    message: err.message || 'An unexpected error occurred',
    timestamp: new Date().toISOString(),
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// Graceful shutdown handler
const gracefulShutdown = async (signal) => {
  logger.info(`${signal} received, starting graceful shutdown`);
  
  // Stop accepting new connections
  server.close(async () => {
    logger.info('HTTP server closed');
    
    // Close database pool
    await closePool();
    
    logger.info('Graceful shutdown completed');
    process.exit(0);
  });

  // Force shutdown after 30 seconds
  setTimeout(() => {
    logger.error('Forced shutdown after timeout');
    process.exit(1);
  }, 30000);
};

// Start server
let server;

const startServer = async () => {
  try {
    // Test database connection
    const dbConnected = await testConnection();
    if (!dbConnected) {
      logger.error('Failed to connect to database. Exiting...');
      process.exit(1);
    }

    // Start HTTP server
    server = app.listen(PORT, () => {
      logger.info(`QMS Service started successfully`, {
        port: PORT,
        environment: process.env.NODE_ENV || 'development',
        nodeVersion: process.version,
        authEnabled: process.env.AUTH_ENABLED !== 'false'
      });
    });

    // Register shutdown handlers
    process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
    process.on('SIGINT', () => gracefulShutdown('SIGINT'));

  } catch (error) {
    logger.error('Failed to start server', {
      error: error.message,
      stack: error.stack
    });
    process.exit(1);
  }
};

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception', {
    error: error.message,
    stack: error.stack
  });
  process.exit(1);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection', {
    reason: reason,
    promise: promise
  });
  process.exit(1);
});

// Start the server
startServer();

module.exports = app;

// Made with Bob
