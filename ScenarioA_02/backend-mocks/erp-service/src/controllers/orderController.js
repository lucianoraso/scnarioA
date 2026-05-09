/**
 * Order Controller
 * Handles ERP order-related business logic
 */

const db = require('../config/database');
const logger = require('../utils/logger');

/**
 * Simulate network latency for realistic testing
 * @returns {Promise<void>}
 */
const simulateLatency = () => {
  if (process.env.SIMULATE_LATENCY === 'true') {
    const min = parseInt(process.env.MIN_LATENCY_MS) || 50;
    const max = parseInt(process.env.MAX_LATENCY_MS) || 200;
    const delay = Math.floor(Math.random() * (max - min + 1)) + min;
    return new Promise(resolve => setTimeout(resolve, delay));
  }
  return Promise.resolve();
};

/**
 * Simulate random errors for testing error handling
 * @throws {Error} Random error
 */
const simulateError = () => {
  if (process.env.SIMULATE_ERRORS === 'true') {
    const errorRate = parseFloat(process.env.ERROR_RATE) || 0.05;
    if (Math.random() < errorRate) {
      throw new Error('Simulated service error');
    }
  }
};

/**
 * Get order by ID
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getOrderById = async (req, res) => {
  const startTime = Date.now();
  const { orderId } = req.params;

  try {
    logger.info('Fetching order', {
      orderId,
      user: req.user?.sub,
      requestId: req.id,
    });

    // Simulate latency
    await simulateLatency();

    // Simulate errors
    simulateError();

    // Query database
    const query = `
      SELECT 
        order_id,
        order_num AS "orderNumber",
        customer_id AS "customerId",
        customer_name AS "customerName",
        order_date AS "orderDate",
        delivery_date AS "deliveryDate",
        status,
        total_amount AS "totalAmount",
        currency,
        plant_code AS "plantCode",
        plant_name AS "plantName",
        priority,
        notes,
        created_at AS "createdAt",
        updated_at AS "updatedAt"
      FROM orders
      WHERE order_id = $1
    `;

    const result = await db.query(query, [orderId]);

    if (result.rows.length === 0) {
      logger.warn('Order not found', { orderId });
      return res.status(404).json({
        error: 'Not Found',
        message: `Order with ID ${orderId} not found`,
        timestamp: new Date().toISOString(),
      });
    }

    const order = result.rows[0];
    const responseTime = Date.now() - startTime;

    logger.info('Order retrieved successfully', {
      orderId,
      responseTime: `${responseTime}ms`,
    });

    res.json({
      data: order,
      metadata: {
        timestamp: new Date().toISOString(),
        responseTime: `${responseTime}ms`,
        source: 'ERP',
      },
    });
  } catch (error) {
    logger.error('Error fetching order', {
      orderId,
      error: error.message,
      stack: error.stack,
    });

    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to retrieve order',
      timestamp: new Date().toISOString(),
    });
  }
};

/**
 * Get all orders with optional filtering
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getAllOrders = async (req, res) => {
  const startTime = Date.now();
  const {
    status,
    priority,
    plantCode,
    customerId,
    limit = 50,
    offset = 0,
  } = req.query;

  try {
    logger.info('Fetching orders', {
      filters: { status, priority, plantCode, customerId },
      pagination: { limit, offset },
      user: req.user?.sub,
    });

    // Simulate latency
    await simulateLatency();

    // Build dynamic query
    let query = `
      SELECT 
        order_id,
        order_num AS "orderNumber",
        customer_id AS "customerId",
        customer_name AS "customerName",
        order_date AS "orderDate",
        delivery_date AS "deliveryDate",
        status,
        total_amount AS "totalAmount",
        currency,
        plant_code AS "plantCode",
        plant_name AS "plantName",
        priority,
        created_at AS "createdAt",
        updated_at AS "updatedAt"
      FROM orders
      WHERE 1=1
    `;

    const params = [];
    let paramIndex = 1;

    if (status) {
      query += ` AND status = $${paramIndex}`;
      params.push(status);
      paramIndex++;
    }

    if (priority) {
      query += ` AND priority = $${paramIndex}`;
      params.push(priority);
      paramIndex++;
    }

    if (plantCode) {
      query += ` AND plant_code = $${paramIndex}`;
      params.push(plantCode);
      paramIndex++;
    }

    if (customerId) {
      query += ` AND customer_id = $${paramIndex}`;
      params.push(customerId);
      paramIndex++;
    }

    query += ` ORDER BY order_date DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(parseInt(limit), parseInt(offset));

    const result = await db.query(query, params);

    // Get total count
    let countQuery = 'SELECT COUNT(*) FROM orders WHERE 1=1';
    const countParams = [];
    let countParamIndex = 1;

    if (status) {
      countQuery += ` AND status = $${countParamIndex}`;
      countParams.push(status);
      countParamIndex++;
    }

    if (priority) {
      countQuery += ` AND priority = $${countParamIndex}`;
      countParams.push(priority);
      countParamIndex++;
    }

    if (plantCode) {
      countQuery += ` AND plant_code = $${countParamIndex}`;
      countParams.push(plantCode);
      countParamIndex++;
    }

    if (customerId) {
      countQuery += ` AND customer_id = $${countParamIndex}`;
      countParams.push(customerId);
      countParamIndex++;
    }

    const countResult = await db.query(countQuery, countParams);
    const totalCount = parseInt(countResult.rows[0].count);

    const responseTime = Date.now() - startTime;

    logger.info('Orders retrieved successfully', {
      count: result.rows.length,
      totalCount,
      responseTime: `${responseTime}ms`,
    });

    res.json({
      data: result.rows,
      pagination: {
        limit: parseInt(limit),
        offset: parseInt(offset),
        total: totalCount,
        hasMore: parseInt(offset) + result.rows.length < totalCount,
      },
      metadata: {
        timestamp: new Date().toISOString(),
        responseTime: `${responseTime}ms`,
        source: 'ERP',
      },
    });
  } catch (error) {
    logger.error('Error fetching orders', {
      error: error.message,
      stack: error.stack,
    });

    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to retrieve orders',
      timestamp: new Date().toISOString(),
    });
  }
};

/**
 * Get order statistics
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getOrderStatistics = async (req, res) => {
  const startTime = Date.now();

  try {
    logger.info('Fetching order statistics', {
      user: req.user?.sub,
    });

    await simulateLatency();

    const query = `
      SELECT 
        status,
        priority,
        COUNT(*) AS count,
        SUM(total_amount) AS total_value,
        AVG(total_amount) AS avg_value
      FROM orders
      GROUP BY status, priority
      ORDER BY status, priority
    `;

    const result = await db.query(query);

    const responseTime = Date.now() - startTime;

    logger.info('Statistics retrieved successfully', {
      responseTime: `${responseTime}ms`,
    });

    res.json({
      data: result.rows,
      metadata: {
        timestamp: new Date().toISOString(),
        responseTime: `${responseTime}ms`,
        source: 'ERP',
      },
    });
  } catch (error) {
    logger.error('Error fetching statistics', {
      error: error.message,
      stack: error.stack,
    });

    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to retrieve statistics',
      timestamp: new Date().toISOString(),
    });
  }
};

module.exports = {
  getOrderById,
  getAllOrders,
  getOrderStatistics,
};

// Made with Bob
