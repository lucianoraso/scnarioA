/**
 * ERP Mock Service - Main Entry Point
 * IBM Cloud Pak for Integration - Scenario A Demo
 */

require('dotenv').config();
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const morgan = require('morgan');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const logger = require('./utils/logger');
const db = require('./config/database');
const orderRoutes = require('./routes/orders');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3001;
const API_PREFIX = process.env.API_PREFIX || '/api';
const API_VERSION = process.env.API_VERSION || 'v1';

// ============================================================================
// Middleware Configuration
// ============================================================================

// Security headers
app.use(helmet());

// CORS configuration
const corsOptions = {
  origin: process.env.CORS_ORIGIN || '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-ID'],
  exposedHeaders: ['X-Total-Count', 'X-Response-Time'],
  credentials: true,
  maxAge: 86400, // 24 hours
};
app.use(cors(corsOptions));

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Compression
app.use(compression());

// HTTP request logging
if (process.env.ENABLE_REQUEST_LOGGING === 'true') {
  app.use(morgan('combined', { stream: logger.stream }));
}

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 60000, // 1 minute
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
  message: {
    error: 'Too Many Requests',
    message: 'Rate limit exceeded. Please try again later.',
    timestamp: new Date().toISOString(),
  },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use(limiter);

// Request ID middleware
app.use((req, res, next) => {
  req.id = req.headers['x-request-id'] || `req-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  res.setHeader('X-Request-ID', req.id);
  next();
});

// Response time tracking
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    res.setHeader('X-Response-Time', `${duration}ms`);
  });
  next();
});

// ============================================================================
// Health Check Endpoints
// ============================================================================

/**
 * Health check endpoint
 * Returns service health status
 */
app.get(process.env.HEALTH_CHECK_PATH || '/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: process.env.SERVICE_NAME || 'erp-service',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

/**
 * Readiness check endpoint
 * Checks if service is ready to accept requests
 */
app.get(process.env.READINESS_CHECK_PATH || '/ready', async (req, res) => {
  try {
    // Check database connection
    const dbReady = await db.testConnection();
    
    if (dbReady) {
      res.json({
        status: 'ready',
        service: process.env.SERVICE_NAME || 'erp-service',
        checks: {
          database: 'connected',
        },
        timestamp: new Date().toISOString(),
      });
    } else {
      res.status(503).json({
        status: 'not ready',
        service: process.env.SERVICE_NAME || 'erp-service',
        checks: {
          database: 'disconnected',
        },
        timestamp: new Date().toISOString(),
      });
    }
  } catch (error) {
    logger.error('Readiness check failed', { error: error.message });
    res.status(503).json({
      status: 'not ready',
      service: process.env.SERVICE_NAME || 'erp-service',
      error: error.message,
      timestamp: new Date().toISOString(),
    });
  }
});

/**
 * Metrics endpoint
 * Returns service metrics
 */
if (process.env.ENABLE_METRICS === 'true') {
  app.get(process.env.METRICS_PATH || '/metrics', (req, res) => {
    const poolStats = db.getPoolStats();
    res.json({
      service: process.env.SERVICE_NAME || 'erp-service',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      memory: process.memoryUsage(),
      database: {
        pool: poolStats,
      },
    });
  });
}

// ============================================================================
// API Routes
// ============================================================================

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    service: 'ERP Mock Service',
    version: '1.0.0',
    description: 'Mock ERP service for Production Order Consolidation Demo',
    endpoints: {
      health: process.env.HEALTH_CHECK_PATH || '/health',
      ready: process.env.READINESS_CHECK_PATH || '/ready',
      metrics: process.env.ENABLE_METRICS === 'true' ? (process.env.METRICS_PATH || '/metrics') : null,
      api: `${API_PREFIX}/${API_VERSION}/orders`,
    },
    documentation: 'https://github.com/your-org/erp-mock-service',
    timestamp: new Date().toISOString(),
  });
});

// API routes
app.use(`${API_PREFIX}/${API_VERSION}/orders`, orderRoutes);

// ============================================================================
// Error Handling
// ============================================================================

// 404 handler
app.use((req, res) => {
  logger.warn('Route not found', {
    method: req.method,
    path: req.path,
    ip: req.ip,
  });
  
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.method} ${req.path} not found`,
    timestamp: new Date().toISOString(),
  });
});

// Global error handler
app.use((err, req, res, next) => {
  logger.error('Unhandled error', {
    error: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
  });

  res.status(err.status || 500).json({
    error: err.name || 'Internal Server Error',
    message: err.message || 'An unexpected error occurred',
    timestamp: new Date().toISOString(),
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
});

// ============================================================================
// Server Startup
// ============================================================================

/**
 * Start the server
 */
const startServer = async () => {
  try {
    // Test database connection
    logger.info('Testing database connection...');
    const dbConnected = await db.testConnection();
    
    if (!dbConnected) {
      throw new Error('Database connection failed');
    }

    // Start HTTP server
    const server = app.listen(PORT, () => {
      logger.info('ERP Mock Service started', {
        port: PORT,
        environment: process.env.NODE_ENV || 'development',
        apiEndpoint: `http://localhost:${PORT}${API_PREFIX}/${API_VERSION}`,
      });
    });

    // Graceful shutdown
    const gracefulShutdown = async (signal) => {
      logger.info(`${signal} received, starting graceful shutdown...`);
      
      server.close(async () => {
        logger.info('HTTP server closed');
        
        try {
          await db.closePool();
          logger.info('Database connections closed');
          process.exit(0);
        } catch (error) {
          logger.error('Error during shutdown', { error: error.message });
          process.exit(1);
        }
      });

      // Force shutdown after 30 seconds
      setTimeout(() => {
        logger.error('Forced shutdown after timeout');
        process.exit(1);
      }, 30000);
    };

    // Handle shutdown signals
    process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
    process.on('SIGINT', () => gracefulShutdown('SIGINT'));

    // Handle uncaught exceptions
    process.on('uncaughtException', (error) => {
      logger.error('Uncaught exception', {
        error: error.message,
        stack: error.stack,
      });
      process.exit(1);
    });

    // Handle unhandled promise rejections
    process.on('unhandledRejection', (reason, promise) => {
      logger.error('Unhandled promise rejection', {
        reason: reason,
        promise: promise,
      });
    });

  } catch (error) {
    logger.error('Failed to start server', {
      error: error.message,
      stack: error.stack,
    });
    process.exit(1);
  }
};

// Start the server
startServer();

module.exports = app;

// Made with Bob
