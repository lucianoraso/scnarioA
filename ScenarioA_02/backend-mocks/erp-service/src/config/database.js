/**
 * Database Configuration for ERP Mock Service
 * PostgreSQL connection pool management
 */

const { Pool } = require('pg');
const logger = require('../utils/logger');

// Database configuration from environment variables
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT) || 5432,
  database: process.env.DB_NAME || 'production_orders',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  max: parseInt(process.env.DB_MAX_CONNECTIONS) || 20,
  idleTimeoutMillis: parseInt(process.env.DB_IDLE_TIMEOUT) || 30000,
  connectionTimeoutMillis: parseInt(process.env.DB_CONNECTION_TIMEOUT) || 2000,
};

// Create connection pool
const pool = new Pool(dbConfig);

// Pool error handling
pool.on('error', (err, client) => {
  logger.error('Unexpected error on idle client', { error: err.message });
});

pool.on('connect', () => {
  logger.debug('New client connected to database');
});

pool.on('remove', () => {
  logger.debug('Client removed from pool');
});

/**
 * Execute a query with automatic connection management
 * @param {string} text - SQL query text
 * @param {Array} params - Query parameters
 * @returns {Promise<Object>} Query result
 */
const query = async (text, params) => {
  const start = Date.now();
  try {
    const result = await pool.query(text, params);
    const duration = Date.now() - start;
    logger.debug('Executed query', {
      query: text,
      duration: `${duration}ms`,
      rows: result.rowCount,
    });
    return result;
  } catch (error) {
    logger.error('Database query error', {
      query: text,
      error: error.message,
      stack: error.stack,
    });
    throw error;
  }
};

/**
 * Get a client from the pool for transaction management
 * @returns {Promise<Object>} Database client
 */
const getClient = async () => {
  try {
    const client = await pool.connect();
    const query = client.query;
    const release = client.release;

    // Set a timeout of 5 seconds, after which we will log this client's last query
    const timeout = setTimeout(() => {
      logger.error('A client has been checked out for more than 5 seconds!');
    }, 5000);

    // Monkey patch the query method to keep track of the last query executed
    client.query = (...args) => {
      client.lastQuery = args;
      return query.apply(client, args);
    };

    // Monkey patch the release method to clear our timeout
    client.release = () => {
      clearTimeout(timeout);
      // Set the methods back to their old un-monkey-patched version
      client.query = query;
      client.release = release;
      return release.apply(client);
    };

    return client;
  } catch (error) {
    logger.error('Error getting database client', { error: error.message });
    throw error;
  }
};

/**
 * Test database connection
 * @returns {Promise<boolean>} Connection status
 */
const testConnection = async () => {
  try {
    const result = await query('SELECT NOW() as current_time, version() as pg_version');
    logger.info('Database connection successful', {
      time: result.rows[0].current_time,
      version: result.rows[0].pg_version,
    });
    return true;
  } catch (error) {
    logger.error('Database connection failed', { error: error.message });
    return false;
  }
};

/**
 * Close all database connections
 * @returns {Promise<void>}
 */
const closePool = async () => {
  try {
    await pool.end();
    logger.info('Database pool closed');
  } catch (error) {
    logger.error('Error closing database pool', { error: error.message });
    throw error;
  }
};

/**
 * Get pool statistics
 * @returns {Object} Pool statistics
 */
const getPoolStats = () => {
  return {
    total: pool.totalCount,
    idle: pool.idleCount,
    waiting: pool.waitingCount,
  };
};

module.exports = {
  query,
  getClient,
  testConnection,
  closePool,
  getPoolStats,
  pool,
};

// Made with Bob
