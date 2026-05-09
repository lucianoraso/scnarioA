/**
 * Order Routes
 * API endpoints for ERP order management
 */

const express = require('express');
const { param, query, validationResult } = require('express-validator');
const orderController = require('../controllers/orderController');
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
 * GET /api/orders
 * Get all orders with optional filtering
 */
router.get(
  '/',
  verifyToken,
  requireScope('read:orders'),
  [
    query('status')
      .optional()
      .isIn(['CREATED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'ON_HOLD'])
      .withMessage('Invalid status value'),
    query('priority')
      .optional()
      .isIn(['LOW', 'NORMAL', 'HIGH', 'URGENT'])
      .withMessage('Invalid priority value'),
    query('plantCode')
      .optional()
      .isString()
      .trim()
      .withMessage('Plant code must be a string'),
    query('customerId')
      .optional()
      .isString()
      .trim()
      .withMessage('Customer ID must be a string'),
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
  orderController.getAllOrders
);

/**
 * GET /api/orders/statistics
 * Get order statistics
 */
router.get(
  '/statistics',
  verifyToken,
  requireScope('read:orders'),
  orderController.getOrderStatistics
);

/**
 * GET /api/orders/:orderId
 * Get order by ID
 */
router.get(
  '/:orderId',
  verifyToken,
  requireScope('read:orders'),
  [
    param('orderId')
      .isString()
      .trim()
      .notEmpty()
      .withMessage('Order ID is required'),
    validate,
  ],
  orderController.getOrderById
);

module.exports = router;

// Made with Bob
