const jwt = require('jsonwebtoken');
const logger = require('../utils/logger');

/**
 * Middleware per autenticazione OAuth2 Bearer Token
 * Valida JWT token e verifica scope/permissions
 */
const authenticateToken = (req, res, next) => {
  // Se l'autenticazione è disabilitata, passa oltre
  if (process.env.AUTH_ENABLED === 'false') {
    logger.debug('Authentication disabled, skipping token validation');
    req.user = {
      sub: 'test-user',
      scope: 'qms:read qms:write',
      client_id: 'test-client'
    };
    return next();
  }

  // Estrai il token dall'header Authorization
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    logger.warn('Missing authorization token', {
      path: req.path,
      method: req.method,
      ip: req.ip
    });
    return res.status(401).json({
      error: 'Unauthorized',
      message: 'Missing authorization token',
      timestamp: new Date().toISOString()
    });
  }

  // Verifica il token JWT
  jwt.verify(token, process.env.JWT_SECRET || 'qms-secret-key', {
    issuer: process.env.JWT_ISSUER || 'qms-service',
    audience: process.env.JWT_AUDIENCE || 'qms-api'
  }, (err, user) => {
    if (err) {
      logger.warn('Invalid or expired token', {
        error: err.message,
        path: req.path,
        method: req.method,
        ip: req.ip
      });
      
      return res.status(403).json({
        error: 'Forbidden',
        message: 'Invalid or expired token',
        timestamp: new Date().toISOString()
      });
    }

    // Token valido, aggiungi user info alla request
    req.user = user;
    logger.debug('Token validated successfully', {
      user: user.sub,
      scope: user.scope,
      client_id: user.client_id
    });
    
    next();
  });
};

/**
 * Middleware per verificare scope specifici
 * @param {string} requiredScope - Lo scope richiesto (es. 'qms:read')
 */
const requireScope = (requiredScope) => {
  return (req, res, next) => {
    if (process.env.AUTH_ENABLED === 'false') {
      return next();
    }

    const userScopes = req.user?.scope?.split(' ') || [];
    
    if (!userScopes.includes(requiredScope)) {
      logger.warn('Insufficient scope', {
        required: requiredScope,
        provided: userScopes,
        user: req.user?.sub,
        path: req.path
      });
      
      return res.status(403).json({
        error: 'Forbidden',
        message: `Insufficient scope. Required: ${requiredScope}`,
        timestamp: new Date().toISOString()
      });
    }

    next();
  };
};

/**
 * Middleware per verificare permessi specifici
 * @param {string[]} requiredPermissions - Array di permessi richiesti
 */
const requirePermissions = (requiredPermissions) => {
  return (req, res, next) => {
    if (process.env.AUTH_ENABLED === 'false') {
      return next();
    }

    const userPermissions = req.user?.permissions || [];
    const hasAllPermissions = requiredPermissions.every(perm => 
      userPermissions.includes(perm)
    );

    if (!hasAllPermissions) {
      logger.warn('Insufficient permissions', {
        required: requiredPermissions,
        provided: userPermissions,
        user: req.user?.sub,
        path: req.path
      });
      
      return res.status(403).json({
        error: 'Forbidden',
        message: 'Insufficient permissions',
        timestamp: new Date().toISOString()
      });
    }

    next();
  };
};

module.exports = {
  authenticateToken,
  requireScope,
  requirePermissions
};

// Made with Bob
