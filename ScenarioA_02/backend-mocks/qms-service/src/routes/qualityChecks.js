const express = require('express');
const router = express.Router();
const { authenticateToken, requireScope } = require('../middleware/auth');
const {
  getQualityChecksByStepIds,
  getQualityCheckById,
  getAllQualityChecks,
  getQualityStatistics
} = require('../controllers/qualityCheckController');

/**
 * @route   GET /api/v1/quality-checks
 * @desc    Get quality checks by step IDs (for ACE orchestration) or all checks with filters
 * @access  Protected (requires qms:read scope)
 * @query   stepIds - Comma-separated list of production step IDs (optional)
 * @query   result - Filter by result (PASS, FAIL, PENDING) (optional)
 * @query   severity - Filter by severity (CRITICAL, HIGH, NORMAL, LOW) (optional)
 * @query   checkType - Filter by check type (optional)
 * @query   limit - Number of records to return (default: 100)
 * @query   offset - Number of records to skip (default: 0)
 */
router.get('/', authenticateToken, requireScope('qms:read'), async (req, res) => {
  const { stepIds } = req.query;
  
  // Se stepIds è fornito, usa l'endpoint specifico per ACE
  if (stepIds) {
    return getQualityChecksByStepIds(req, res);
  }
  
  // Altrimenti, restituisci tutti i check con filtri
  return getAllQualityChecks(req, res);
});

/**
 * @route   GET /api/v1/quality-checks/statistics
 * @desc    Get aggregated quality statistics
 * @access  Protected (requires qms:read scope)
 * @query   startDate - Start date for statistics (ISO 8601) (optional)
 * @query   endDate - End date for statistics (ISO 8601) (optional)
 * @query   orderId - Filter by order ID (optional)
 */
router.get('/statistics', authenticateToken, requireScope('qms:read'), getQualityStatistics);

/**
 * @route   GET /api/v1/quality-checks/:checkId
 * @desc    Get a specific quality check by ID
 * @access  Protected (requires qms:read scope)
 * @param   checkId - Quality check ID
 */
router.get('/:checkId', authenticateToken, requireScope('qms:read'), getQualityCheckById);

module.exports = router;

// Made with Bob
