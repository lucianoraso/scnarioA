/**
 * Quality Check Controller
 * Handles QMS quality check-related business logic
 */

const db = require('../config/database');
const logger = require('../utils/logger');

const simulateLatency = () => {
  if (process.env.SIMULATE_LATENCY === 'true') {
    const min = parseInt(process.env.MIN_LATENCY_MS) || 50;
    const max = parseInt(process.env.MAX_LATENCY_MS) || 200;
    const delay = Math.floor(Math.random() * (max - min + 1)) + min;
    return new Promise(resolve => setTimeout(resolve, delay));
  }
  return Promise.resolve();
};

const simulateError = () => {
  if (process.env.SIMULATE_ERRORS === 'true') {
    const errorRate = parseFloat(process.env.ERROR_RATE) || 0.05;
    if (Math.random() < errorRate) {
      throw new Error('Simulated service error');
    }
  }
};

/**
 * Get quality checks by step IDs
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getQualityChecksByStepIds = async (req, res) => {
  const startTime = Date.now();
  const { stepIds } = req.query;

  try {
    logger.info('Fetching quality checks', {
      stepIds,
      user: req.user?.sub,
      requestId: req.id,
    });

    if (!stepIds) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'stepIds query parameter is required',
        timestamp: new Date().toISOString(),
      });
    }

    await simulateLatency();
    simulateError();

    // Parse stepIds (comma-separated string to array)
    const stepIdArray = stepIds.split(',').map(id => parseInt(id.trim())).filter(id => !isNaN(id));

    if (stepIdArray.length === 0) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Invalid stepIds format. Expected comma-separated integers.',
        timestamp: new Date().toISOString(),
      });
    }

    const query = `
      SELECT 
        check_id AS "checkId",
        ref_order AS "refOrder",
        step_id AS "stepId",
        check_type AS "checkType",
        check_parameter AS "checkParameter",
        check_description AS "checkDescription",
        measured_value AS "measuredValue",
        target_value AS "targetValue",
        tolerance_min AS "toleranceMin",
        tolerance_max AS "toleranceMax",
        unit_of_measure AS "unitOfMeasure",
        result,
        severity,
        inspector_id AS "inspectorId",
        inspector_name AS "inspectorName",
        check_timestamp AS "checkTimestamp",
        notes,
        corrective_action AS "correctiveAction",
        created_at AS "createdAt"
      FROM quality_checks
      WHERE step_id = ANY($1::int[])
      ORDER BY check_timestamp DESC
    `;

    const result = await db.query(query, [stepIdArray]);

    if (result.rows.length === 0) {
      logger.warn('No quality checks found', { stepIds: stepIdArray });
      return res.status(404).json({
        error: 'Not Found',
        message: `No quality checks found for step IDs: ${stepIds}`,
        timestamp: new Date().toISOString(),
      });
    }

    // Group by step_id
    const checksByStep = {};
    result.rows.forEach(check => {
      if (!checksByStep[check.stepId]) {
        checksByStep[check.stepId] = [];
      }
      checksByStep[check.stepId].push(check);
    });

    const responseTime = Date.now() - startTime;

    logger.info('Quality checks retrieved successfully', {
      stepIds: stepIdArray,
      totalChecks: result.rows.length,
      responseTime: `${responseTime}ms`,
    });

    res.json({
      data: {
        stepIds: stepIdArray,
        checks: result.rows,
        checksByStep: checksByStep,
        totalChecks: result.rows.length,
        passedChecks: result.rows.filter(c => c.result === 'PASS').length,
        failedChecks: result.rows.filter(c => c.result === 'FAIL').length,
        pendingChecks: result.rows.filter(c => c.result === 'PENDING').length,
      },
      metadata: {
        timestamp: new Date().toISOString(),
        responseTime: `${responseTime}ms`,
        source: 'QMS',
      },
    });
  } catch (error) {
    logger.error('Error fetching quality checks', {
      stepIds,
      error: error.message,
      stack: error.stack,
    });

    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to retrieve quality checks',
      timestamp: new Date().toISOString(),
    });
  }
};

/**
 * Get quality check by ID
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getQualityCheckById = async (req, res) => {
  const startTime = Date.now();
  const { checkId } = req.params;

  try {
    logger.info('Fetching quality check', {
      checkId,
      user: req.user?.sub,
      requestId: req.id,
    });

    await simulateLatency();
    simulateError();

    const query = `
      SELECT 
        check_id AS "checkId",
        ref_order AS "refOrder",
        step_id AS "stepId",
        check_type AS "checkType",
        check_parameter AS "checkParameter",
        check_description AS "checkDescription",
        measured_value AS "measuredValue",
        target_value AS "targetValue",
        tolerance_min AS "toleranceMin",
        tolerance_max AS "toleranceMax",
        unit_of_measure AS "unitOfMeasure",
        result,
        severity,
        inspector_id AS "inspectorId",
        inspector_name AS "inspectorName",
        check_timestamp AS "checkTimestamp",
        notes,
        corrective_action AS "correctiveAction",
        created_at AS "createdAt"
      FROM quality_checks
      WHERE check_id = $1
    `;

    const result = await db.query(query, [checkId]);

    if (result.rows.length === 0) {
      logger.warn('Quality check not found', { checkId });
      return res.status(404).json({
        error: 'Not Found',
        message: `Quality check with ID ${checkId} not found`,
        timestamp: new Date().toISOString(),
      });
    }

    const responseTime = Date.now() - startTime;

    logger.info('Quality check retrieved successfully', {
      checkId,
      responseTime: `${responseTime}ms`,
    });

    res.json({
      data: result.rows[0],
      metadata: {
        timestamp: new Date().toISOString(),
        responseTime: `${responseTime}ms`,
        source: 'QMS',
      },
    });
  } catch (error) {
    logger.error('Error fetching quality check', {
      checkId,
      error: error.message,
      stack: error.stack,
    });

    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to retrieve quality check',
      timestamp: new Date().toISOString(),
    });
  }
};

/**
 * Get all quality checks with optional filtering
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getAllQualityChecks = async (req, res) => {
  const startTime = Date.now();
  const {
    result: resultFilter,
    severity,
    checkType,
    refOrder,
    limit = 50,
    offset = 0,
  } = req.query;

  try {
    logger.info('Fetching all quality checks', {
      filters: { result: resultFilter, severity, checkType, refOrder },
      pagination: { limit, offset },
      user: req.user?.sub,
    });

    await simulateLatency();

    let query = `
      SELECT 
        check_id AS "checkId",
        ref_order AS "refOrder",
        step_id AS "stepId",
        check_type AS "checkType",
        check_parameter AS "checkParameter",
        result,
        severity,
        inspector_name AS "inspectorName",
        check_timestamp AS "checkTimestamp",
        created_at AS "createdAt"
      FROM quality_checks
      WHERE 1=1
    `;

    const params = [];
    let paramIndex = 1;

    if (resultFilter) {
      query += ` AND result = $${paramIndex}`;
      params.push(resultFilter);
      paramIndex++;
    }

    if (severity) {
      query += ` AND severity = $${paramIndex}`;
      params.push(severity);
      paramIndex++;
    }

    if (checkType) {
      query += ` AND check_type = $${paramIndex}`;
      params.push(checkType);
      paramIndex++;
    }

    if (refOrder) {
      query += ` AND ref_order = $${paramIndex}`;
      params.push(refOrder);
      paramIndex++;
    }

    query += ` ORDER BY check_timestamp DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(parseInt(limit), parseInt(offset));

    const result = await db.query(query, params);

    // Get total count
    let countQuery = 'SELECT COUNT(*) FROM quality_checks WHERE 1=1';
    const countParams = [];
    let countParamIndex = 1;

    if (resultFilter) {
      countQuery += ` AND result = $${countParamIndex}`;
      countParams.push(resultFilter);
      countParamIndex++;
    }

    if (severity) {
      countQuery += ` AND severity = $${countParamIndex}`;
      countParams.push(severity);
      countParamIndex++;
    }

    if (checkType) {
      countQuery += ` AND check_type = $${countParamIndex}`;
      countParams.push(checkType);
      countParamIndex++;
    }

    if (refOrder) {
      countQuery += ` AND ref_order = $${countParamIndex}`;
      countParams.push(refOrder);
      countParamIndex++;
    }

    const countResult = await db.query(countQuery, countParams);
    const totalCount = parseInt(countResult.rows[0].count);

    const responseTime = Date.now() - startTime;

    logger.info('Quality checks retrieved successfully', {
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
        source: 'QMS',
      },
    });
  } catch (error) {
    logger.error('Error fetching quality checks', {
      error: error.message,
      stack: error.stack,
    });

    res.status(500).json({
      error: 'Internal Server Error',
      message: 'Failed to retrieve quality checks',
      timestamp: new Date().toISOString(),
    });
  }
};

/**
 * Get quality statistics
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const getQualityStatistics = async (req, res) => {
  const startTime = Date.now();

  try {
    logger.info('Fetching quality statistics', {
      user: req.user?.sub,
    });

    await simulateLatency();

    const query = `
      SELECT 
        result,
        severity,
        COUNT(*) AS count,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
      FROM quality_checks
      GROUP BY result, severity
      ORDER BY result, severity
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
        source: 'QMS',
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
  getQualityChecksByStepIds,
  getQualityCheckById,
  getAllQualityChecks,
  getQualityStatistics,
};

// Made with Bob
