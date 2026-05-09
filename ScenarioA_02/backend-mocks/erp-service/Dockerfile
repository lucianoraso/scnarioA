# ============================================================================
# Multi-stage Dockerfile for ERP Mock Service
# Optimized for production deployment on OpenShift
# ============================================================================

# Stage 1: Build stage
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies (including dev dependencies for build)
RUN npm ci --only=production && \
    npm cache clean --force

# Stage 2: Production stage
FROM node:18-alpine

# Add labels for OpenShift
LABEL name="erp-mock-service" \
      vendor="Leonardo Integration Team" \
      version="1.0.0" \
      description="Mock ERP Service for Production Order Consolidation Demo" \
      io.k8s.description="Mock ERP Service providing order management APIs" \
      io.k8s.display-name="ERP Mock Service" \
      io.openshift.tags="integration,erp,mock,nodejs"

# Create app directory
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
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3001/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start application
CMD ["node", "src/index.js"]

# Made with Bob
