/**
 * Production Step Routes
 * API endpoints for MES production step management
 */

const express = require('express');
const { param, query, validationResult } = require('express-validator');
const productionStepController = require('../controllers/productionStepController');
const { verifyToken, requireScope } = require('../middleware/auth');

const router = express.Router();

/**
 * Validation middleware
 */
const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: 'Validation Error',
      details: errors.array(),
      timestamp: new Date().toISOString(),
    });
  }
  next();
};

/**
 * GET /api/production-steps
 * Get production steps by order ID or all with filters
 */
router.get(
  '/',
  verifyToken,
  requireScope('read:production'),
  [
    query('orderId')
      .optional()
      .isString()
      .trim()
      .withMessage('Order ID must be a string'),
    query('status')
      .optional()
      .isIn(['PENDING', 'IN_PROGRESS', 'COMPLETED', 'FAILED', 'SKIPPED', 'ON_HOLD'])
      .withMessage('Invalid status value'),
    query('workstationId')
      .optional()
      .isString()
      .trim()
      .withMessage('Workstation ID must be a string'),
    query('operatorId')
      .optional()
      .isString()
      .trim()
      .withMessage('Operator ID must be a string'),
    query('limit')
      .optional()
      .isInt({ min: 1, max: 100 })
      .withMessage('Limit must be between 1 and 100'),
    query('offset')
      .optional()
      .isInt({ min: 0 })
      .withMessage('Offset must be a non-negative integer'),
    validate,
  ],
  (req, res, next) => {
    // If orderId is provided, use the specific controller
    if (req.query.orderId) {
      return productionStepController.getProductionStepsByOrderId(req, res, next);
    }
    // Otherwise, get all with filters
    return productionStepController.getAllProductionSteps(req, res, next);
  }
);

/**
 * GET /api/production-steps/statistics
 * Get production statistics
 */
router.get(
  '/statistics',
  verifyToken,
  requireScope('read:production'),
  productionStepController.getProductionStatistics
);

/**
 * GET /api/production-steps/:stepId
 * Get production step by ID
 */
router.get(
  '/:stepId',
  verifyToken,
  requireScope('read:production'),
  [
    param('stepId')
      .isInt({ min: 1 })
      .withMessage('Step ID must be a positive integer'),
    validate,
  ],
  productionStepController.getProductionStepById
);

module.exports = router;

// Made with Bob
