/**
 * Production Step Controller
 * Handles MES production step-related business logic
 */

const db = require('../config/database');
const logger = require('../utils/logger');

/**
 * Simulate network latency for realistic testing
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
 * Get production steps by order ID
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getProductionStepsByOrderId = async (req, res) => {
  const startTime = Date.now();
  const { orderId } = req.query;

  try {
    logger.info('Fetching production steps', {
      orderId,
      user: req.user?.sub,
      requestId: req.id,
    });

    if (!orderId) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'orderId query parameter is required',
        timestamp: new Date().toISOString(),
      });
    }

    // Simulate latency
    await simulateLatency();

    // Simulate errors
    simulateError();

    // Query database
    const query = `
      SELECT 
        step_id AS "stepId",
        production_order_id AS "productionOrderId",
        step_number AS "stepNumber",
        step_name AS "stepName",
        step_description AS "stepDescription",
        workstation_id AS "workstationId",
        workstation_name AS "workstationName",
        operator_id AS "operatorId",
        operator_name AS "operatorName",
        status,
        start_time AS "startTime",
        end_time AS "endTime",
        duration_minutes AS "durationMinutes",
        quantity_planned AS "quantityPlanned",
        quantity_completed AS "quantityCompleted",
        quantity_rejected AS "quantityRejected",
        efficiency_percentage AS "efficiencyPercentage",
        notes,
        created_at AS "createdAt",
        updated_at AS "updatedAt"
      FROM production_steps
      WHERE production_order_id = $1
      ORDER BY step_number ASC
    `;

    const result = await db.query(query, [orderId]);

    if (result.rows.length === 0) {
      logger.warn('No production steps found', { orderId });
      return res.status(404).json({
        error: 'Not Found',
        message: `No production steps found for order ${orderId}`,
        timestamp: new Date().toISOString(),
      });
    }

    const responseTime = Date.now() - startTime;

    logger.info('Production steps retrieved successfully', {
      orderId,
      count: result.rows.length,
      responseTime: `${responseTime}ms`,
    });

    res.json({
      data: {
        orderId: orderId,
        steps: result.rows,
        totalSteps: result.rows.length,
        completedSteps: result.rows.filter(s => s.status === 'COMPLETED').length,
        inProgressSteps: result.rows.filter(s => s.status === 'IN_PROGRESS').length,
        pendingSteps: result.rows.filter(s => s.status === 'PENDING').length,
      },
      metadata: {
        timestamp: new Date().toISOString(),
        responseTime: `${responseTime}ms`,
        source: 'MES',
      },
    });
  } catch (error) {
    logger.error('Error fetching production steps', {
      orderId,
      error: error.message,
      stack: error.stack,
    });

    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to retrieve production steps',
      timestamp: new Date().toISOString(),
    });
  }
};

/**
 * Get production step by ID
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getProductionStepById = async (req, res) => {
  const startTime = Date.now();
  const { stepId } = req.params;

  try {
    logger.info('Fetching production step', {
      stepId,
      user: req.user?.sub,
      requestId: req.id,
    });

    await simulateLatency();
    simulateError();

    const query = `
      SELECT 
        step_id AS "stepId",
        production_order_id AS "productionOrderId",
        step_number AS "stepNumber",
        step_name AS "stepName",
        step_description AS "stepDescription",
        workstation_id AS "workstationId",
        workstation_name AS "workstationName",
        operator_id AS "operatorId",
        operator_name AS "operatorName",
        status,
        start_time AS "startTime",
        end_time AS "endTime",
        duration_minutes AS "durationMinutes",
        quantity_planned AS "quantityPlanned",
        quantity_completed AS "quantityCompleted",
        quantity_rejected AS "quantityRejected",
        efficiency_percentage AS "efficiencyPercentage",
        notes,
        created_at AS "createdAt",
        updated_at AS "updatedAt"
      FROM production_steps
      WHERE step_id = $1
    `;

    const result = await db.query(query, [stepId]);

    if (result.rows.length === 0) {
      logger.warn('Production step not found', { stepId });
      return res.status(404).json({
        error: 'Not Found',
        message: `Production step with ID ${stepId} not found`,
        timestamp: new Date().toISOString(),
      });
    }

    const responseTime = Date.now() - startTime;

    logger.info('Production step retrieved successfully', {
      stepId,
      responseTime: `${responseTime}ms`,
    });

    res.json({
      data: result.rows[0],
      metadata: {
        timestamp: new Date().toISOString(),
        responseTime: `${responseTime}ms`,
        source: 'MES',
      },
    });
  } catch (error) {
    logger.error('Error fetching production step', {
      stepId,
      error: error.message,
      stack: error.stack,
    });

    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to retrieve production step',
      timestamp: new Date().toISOString(),
    });
  }
};

/**
 * Get all production steps with optional filtering
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getAllProductionSteps = async (req, res) => {
  const startTime = Date.now();
  const {
    status,
    workstationId,
    operatorId,
    limit = 50,
    offset = 0,
  } = req.query;

  try {
    logger.info('Fetching all production steps', {
      filters: { status, workstationId, operatorId },
      pagination: { limit, offset },
      user: req.user?.sub,
    });

    await simulateLatency();

    let query = `
      SELECT 
        step_id AS "stepId",
        production_order_id AS "productionOrderId",
        step_number AS "stepNumber",
        step_name AS "stepName",
        workstation_name AS "workstationName",
        operator_name AS "operatorName",
        status,
        start_time AS "startTime",
        end_time AS "endTime",
        quantity_planned AS "quantityPlanned",
        quantity_completed AS "quantityCompleted",
        efficiency_percentage AS "efficiencyPercentage",
        created_at AS "createdAt"
      FROM production_steps
      WHERE 1=1
    `;

    const params = [];
    let paramIndex = 1;

    if (status) {
      query += ` AND status = $${paramIndex}`;
      params.push(status);
      paramIndex++;
    }

    if (workstationId) {
      query += ` AND workstation_id = $${paramIndex}`;
      params.push(workstationId);
      paramIndex++;
    }

    if (operatorId) {
      query += ` AND operator_id = $${paramIndex}`;
      params.push(operatorId);
      paramIndex++;
    }

    query += ` ORDER BY created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(parseInt(limit), parseInt(offset));

    const result = await db.query(query, params);

    // Get total count
    let countQuery = 'SELECT COUNT(*) FROM production_steps WHERE 1=1';
    const countParams = [];
    let countParamIndex = 1;

    if (status) {
      countQuery += ` AND status = $${countParamIndex}`;
      countParams.push(status);
      countParamIndex++;
    }

    if (workstationId) {
      countQuery += ` AND workstation_id = $${countParamIndex}`;
      countParams.push(workstationId);
      countParamIndex++;
    }

    if (operatorId) {
      countQuery += ` AND operator_id = $${countParamIndex}`;
      countParams.push(operatorId);
      countParamIndex++;
    }

    const countResult = await db.query(countQuery, countParams);
    const totalCount = parseInt(countResult.rows[0].count);

    const responseTime = Date.now() - startTime;

    logger.info('Production steps retrieved successfully', {
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
        source: 'MES',
      },
    });
  } catch (error) {
    logger.error('Error fetching production steps', {
      error: error.message,
      stack: error.stack,
    });

    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to retrieve production steps',
      timestamp: new Date().toISOString(),
    });
  }
};

/**
 * Get production statistics
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getProductionStatistics = async (req, res) => {
  const startTime = Date.now();

  try {
    logger.info('Fetching production statistics', {
      user: req.user?.sub,
    });

    await simulateLatency();

    const query = `
      SELECT 
        status,
        COUNT(*) AS count,
        AVG(efficiency_percentage) AS avg_efficiency,
        SUM(quantity_planned) AS total_planned,
        SUM(quantity_completed) AS total_completed,
        SUM(quantity_rejected) AS total_rejected
      FROM production_steps
      GROUP BY status
      ORDER BY status
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
        source: 'MES',
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
  getProductionStepsByOrderId,
  getProductionStepById,
  getAllProductionSteps,
  getProductionStatistics,
};

// Made with Bob
