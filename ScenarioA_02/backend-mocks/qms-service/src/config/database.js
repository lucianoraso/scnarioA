const { Pool } = require('pg');
const logger = require('../utils/logger');

// Configurazione pool PostgreSQL
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  database: process.env.DB_NAME || 'production_orders',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  max: parseInt(process.env.DB_POOL_MAX || '20', 10),
  idleTimeoutMillis: parseInt(process.env.DB_IDLE_TIMEOUT || '30000', 10),
  connectionTimeoutMillis: parseInt(process.env.DB_CONNECTION_TIMEOUT || '2000', 10),
  ssl: process.env.DB_SSL === 'true' ? {
    rejectUnauthorized: false
  } : false
});

// Event handlers per il pool
pool.on('connect', (client) => {
  logger.debug('New database client connected to QMS database');
});

pool.on('error', (err, client) => {
  logger.error('Unexpected error on idle database client', { error: err.message });
});

pool.on('remove', (client) => {
  logger.debug('Database client removed from pool');
});

// Test connessione al database
const testConnection = async () => {
  try {
    const client = await pool.connect();
    const result = await client.query('SELECT NOW() as current_time, current_database() as database');
    logger.info('Database connection successful', {
      database: result.rows[0].database,
      timestamp: result.rows[0].current_time
    });
    client.release();
    return true;
  } catch (error) {
    logger.error('Database connection failed', {
      error: error.message,
      host: process.env.DB_HOST,
      database: process.env.DB_NAME
    });
    return false;
  }
};

// Graceful shutdown
const closePool = async () => {
  try {
    await pool.end();
    logger.info('Database pool closed successfully');
  } catch (error) {
    logger.error('Error closing database pool', { error: error.message });
  }
};

module.exports = {
  pool,
  testConnection,
  closePool
};

// Made with Bob
