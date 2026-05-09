# ============================================================================
# Multi-stage Dockerfile for MES Mock Service
# Optimized for production deployment on OpenShift
# ============================================================================

# Stage 1: Build stage
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci --only=production && \
    npm cache clean --force

# Stage 2: Production stage
FROM node:18-alpine

# Add labels for OpenShift
LABEL name="mes-mock-service" \
      vendor="Leonardo Integration Team" \
      version="1.0.0" \
      description="Mock MES Service for Production Order Consolidation Demo" \
      io.k8s.description="Mock MES Service providing production step management APIs" \
      io.k8s.display-name="MES Mock Service" \
      io.openshift.tags="integration,mes,manufacturing,mock,nodejs"

WORKDIR /app

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy dependencies from builder
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules

# Copy application code
COPY --chown=nodejs:nodejs . .

# Create logs directory
RUN mkdir -p logs && chown -R nodejs:nodejs logs

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3002

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3002/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start application
CMD ["node", "src/index.js"]

# Made with Bob
