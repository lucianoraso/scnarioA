/**
 * Authentication Middleware
 * OAuth2 Bearer Token validation
 */

const jwt = require('jsonwebtoken');
const logger = require('../utils/logger');

/**
 * Verify JWT token from Authorization header
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const verifyToken = (req, res, next) => {
  // Check if authentication is enabled
  if (process.env.ENABLE_AUTH === 'false') {
    logger.debug('Authentication disabled, skipping token verification');
    req.user = { sub: 'system', scope: 'all' };
    return next();
  }

  // Get token from Authorization header
  const authHeader = req.headers.authorization;
  
  if (!authHeader) {
    logger.warn('Missing Authorization header', {
      path: req.path,
      method: req.method,
      ip: req.ip,
    });
    return res.status(401).json({
      error: 'Unauthorized',
      message: 'Missing Authorization header',
      timestamp: new Date().toISOString(),
    });
  }

  // Check Bearer token format
  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    logger.warn('Invalid Authorization header format', {
      path: req.path,
      method: req.method,
      ip: req.ip,
    });
    return res.status(401).json({
      error: 'Unauthorized',
      message: 'Invalid Authorization header format. Expected: Bearer <token>',
      timestamp: new Date().toISOString(),
    });
  }

  const token = parts[1];

  try {
    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'default-secret', {
      issuer: process.env.JWT_ISSUER,
      audience: process.env.JWT_AUDIENCE,
    });

    // Attach user info to request
    req.user = decoded;
    req.token = token;

    logger.debug('Token verified successfully', {
      user: decoded.sub,
      scope: decoded.scope,
      path: req.path,
    });

    next();
  } catch (error) {
    logger.warn('Token verification failed', {
      error: error.message,
      path: req.path,
      method: req.method,
      ip: req.ip,
    });

    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        error: 'Unauthorized',
        message: 'Token expired',
        expiredAt: error.expiredAt,
        timestamp: new Date().toISOString(),
      });
    }

    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        error: 'Unauthorized',
        message: 'Invalid token',
        timestamp: new Date().toISOString(),
      });
    }

    return res.status(401).json({
      error: 'Unauthorized',
      message: 'Token verification failed',
      timestamp: new Date().toISOString(),
    });
  }
};

/**
 * Check if user has required scope
 * @param {string} requiredScope - Required scope
 * @returns {Function} Middleware function
 */
const requireScope = (requiredScope) => {
  return (req, res, next) => {
    if (!req.user || !req.user.scope) {
      logger.warn('Missing user scope', {
        path: req.path,
        method: req.method,
      });
      return res.status(403).json({
        error: 'Forbidden',
        message: 'Insufficient permissions',
        timestamp: new Date().toISOString(),
      });
    }

    const userScopes = Array.isArray(req.user.scope) 
      ? req.user.scope 
      : req.user.scope.split(' ');

    if (!userScopes.includes(requiredScope) && !userScopes.includes('all')) {
      logger.warn('Insufficient scope', {
        required: requiredScope,
        provided: userScopes,
        user: req.user.sub,
        path: req.path,
      });
      return res.status(403).json({
        error: 'Forbidden',
        message: `Required scope: ${requiredScope}`,
        timestamp: new Date().toISOString(),
      });
    }

    next();
  };
};

/**
 * Generate a test JWT token (for development/testing only)
 * @param {Object} payload - Token payload
 * @returns {string} JWT token
 */
const generateTestToken = (payload = {}) => {
  const defaultPayload = {
    sub: 'test-user',
    scope: 'read:orders write:orders',
    iss: process.env.JWT_ISSUER || 'leonardo-integration-demo',
    aud: process.env.JWT_AUDIENCE || 'erp-service',
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + (60 * 60), // 1 hour
  };

  const tokenPayload = { ...defaultPayload, ...payload };
  
  return jwt.sign(tokenPayload, process.env.JWT_SECRET || 'default-secret');
};

module.exports = {
  verifyToken,
  requireScope,
  generateTestToken,
};

// Made with Bob
