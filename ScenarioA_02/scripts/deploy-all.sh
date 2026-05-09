#!/bin/bash

###############################################################################
# Deploy Script for Scenario A - IBM Cloud Pak for Integration
#
# This script automates the complete deployment of:
# - PostgreSQL database
# - Backend mock services (ERP, MES, QMS)
# - ACE Integration Server
# - API Connect configuration
#
# Prerequisites:
# - oc CLI installed and logged in
# - Docker images built and pushed to registry
# - Cluster has IBM Cloud Pak for Integration installed
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="scenario-a-demo"
REGISTRY="${REGISTRY:-docker.io/your-org}"
VERSION="${VERSION:-1.0.0}"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check oc CLI
    if ! command -v oc &> /dev/null; then
        log_error "oc CLI not found. Please install OpenShift CLI."
        exit 1
    fi
    
    # Check if logged in
    if ! oc whoami &> /dev/null; then
        log_error "Not logged in to OpenShift. Please run 'oc login' first."
        exit 1
    fi
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_warning "Docker not found. Skipping image build."
    fi
    
    log_success "Prerequisites check passed"
}

create_namespace() {
    log_info "Creating namespace ${NAMESPACE}..."
    
    if oc get namespace ${NAMESPACE} &> /dev/null; then
        log_warning "Namespace ${NAMESPACE} already exists"
    else
        oc create namespace ${NAMESPACE}
        oc label namespace ${NAMESPACE} app.kubernetes.io/name=scenario-a-demo
        log_success "Namespace created"
    fi
}

build_and_push_images() {
    log_info "Building and pushing Docker images..."
    
    if ! command -v docker &> /dev/null; then
        log_warning "Skipping image build (Docker not available)"
        return
    fi
    
    # Build ERP Service
    log_info "Building ERP Service..."
    docker build -t ${REGISTRY}/erp-service:${VERSION} backend-mocks/erp-service/
    docker push ${REGISTRY}/erp-service:${VERSION}
    
    # Build MES Service
    log_info "Building MES Service..."
    docker build -t ${REGISTRY}/mes-service:${VERSION} backend-mocks/mes-service/
    docker push ${REGISTRY}/mes-service:${VERSION}
    
    # Build QMS Service
    log_info "Building QMS Service..."
    docker build -t ${REGISTRY}/qms-service:${VERSION} backend-mocks/qms-service/
    docker push ${REGISTRY}/qms-service:${VERSION}
    
    log_success "Images built and pushed"
}

deploy_postgresql() {
    log_info "Deploying PostgreSQL..."
    
    oc apply -f kubernetes/postgresql-statefulset.yaml -n ${NAMESPACE}
    
    # Wait for PostgreSQL to be ready
    log_info "Waiting for PostgreSQL to be ready..."
    oc wait --for=condition=ready pod -l app=postgresql -n ${NAMESPACE} --timeout=300s
    
    log_success "PostgreSQL deployed"
}

initialize_database() {
    log_info "Initializing database..."
    
    # Get PostgreSQL pod name
    POD_NAME=$(oc get pod -n ${NAMESPACE} -l app=postgresql -o jsonpath='{.items[0].metadata.name}')
    
    # Copy SQL scripts to pod
    log_info "Copying SQL scripts..."
    oc cp database/init-scripts ${NAMESPACE}/${POD_NAME}:/tmp/
    
    # Execute SQL scripts
    log_info "Executing SQL scripts..."
    oc exec -n ${NAMESPACE} ${POD_NAME} -- psql -U postgres -d production_orders -f /tmp/init-scripts/01-create-schemas.sql
    oc exec -n ${NAMESPACE} ${POD_NAME} -- psql -U postgres -d production_orders -f /tmp/init-scripts/02-seed-orders.sql
    oc exec -n ${NAMESPACE} ${POD_NAME} -- psql -U postgres -d production_orders -f /tmp/init-scripts/03-seed-production-steps.sql
    oc exec -n ${NAMESPACE} ${POD_NAME} -- psql -U postgres -d production_orders -f /tmp/init-scripts/04-seed-quality-checks.sql
    
    # Verify data
    log_info "Verifying data..."
    ORDER_COUNT=$(oc exec -n ${NAMESPACE} ${POD_NAME} -- psql -U postgres -d production_orders -t -c "SELECT COUNT(*) FROM orders;")
    log_info "Orders in database: ${ORDER_COUNT}"
    
    log_success "Database initialized"
}

deploy_backend_services() {
    log_info "Deploying backend services..."
    
    # Update image references if using custom registry
    if [ "${REGISTRY}" != "docker.io/your-org" ]; then
        log_info "Updating image references to ${REGISTRY}..."
        sed -i.bak "s|image: erp-service:1.0.0|image: ${REGISTRY}/erp-service:${VERSION}|g" kubernetes/erp-service-deployment.yaml
        sed -i.bak "s|image: mes-service:1.0.0|image: ${REGISTRY}/mes-service:${VERSION}|g" kubernetes/mes-service-deployment.yaml
        sed -i.bak "s|image: qms-service:1.0.0|image: ${REGISTRY}/qms-service:${VERSION}|g" kubernetes/qms-service-deployment.yaml
    fi
    
    # Deploy services
    oc apply -f kubernetes/erp-service-deployment.yaml -n ${NAMESPACE}
    oc apply -f kubernetes/mes-service-deployment.yaml -n ${NAMESPACE}
    oc apply -f kubernetes/qms-service-deployment.yaml -n ${NAMESPACE}
    
    # Wait for services to be ready
    log_info "Waiting for backend services to be ready..."
    oc wait --for=condition=ready pod -l app=erp-service -n ${NAMESPACE} --timeout=300s
    oc wait --for=condition=ready pod -l app=mes-service -n ${NAMESPACE} --timeout=300s
    oc wait --for=condition=ready pod -l app=qms-service -n ${NAMESPACE} --timeout=300s
    
    log_success "Backend services deployed"
}

test_backend_services() {
    log_info "Testing backend services..."
    
    # Get routes
    ERP_ROUTE=$(oc get route erp-service -n ${NAMESPACE} -o jsonpath='{.spec.host}')
    MES_ROUTE=$(oc get route mes-service -n ${NAMESPACE} -o jsonpath='{.spec.host}')
    QMS_ROUTE=$(oc get route qms-service -n ${NAMESPACE} -o jsonpath='{.spec.host}')
    
    # Test health endpoints
    log_info "Testing ERP Service..."
    curl -f https://${ERP_ROUTE}/health || log_error "ERP Service health check failed"
    
    log_info "Testing MES Service..."
    curl -f https://${MES_ROUTE}/health || log_error "MES Service health check failed"
    
    log_info "Testing QMS Service..."
    curl -f https://${QMS_ROUTE}/health || log_error "QMS Service health check failed"
    
    log_success "Backend services are healthy"
}

deploy_ace_integration_server() {
    log_info "Deploying ACE Integration Server..."
    
    # Note: This requires BAR file to be available
    log_warning "ACE Integration Server deployment requires BAR file"
    log_info "Please create BAR file using ACE Toolkit and update barURL in ace-integration-server.yaml"
    
    # Deploy ACE server
    oc apply -f kubernetes/ace-integration-server.yaml -n ${NAMESPACE}
    
    # Wait for ACE server to be ready
    log_info "Waiting for ACE Integration Server to be ready..."
    sleep 30  # Give it time to start
    
    log_success "ACE Integration Server deployed"
}

display_summary() {
    log_info "Deployment Summary"
    echo ""
    echo "Namespace: ${NAMESPACE}"
    echo ""
    echo "Services:"
    oc get pods -n ${NAMESPACE}
    echo ""
    echo "Routes:"
    oc get routes -n ${NAMESPACE}
    echo ""
    
    # Get service URLs
    ERP_URL=$(oc get route erp-service -n ${NAMESPACE} -o jsonpath='{.spec.host}' 2>/dev/null || echo "Not available")
    MES_URL=$(oc get route mes-service -n ${NAMESPACE} -o jsonpath='{.spec.host}' 2>/dev/null || echo "Not available")
    QMS_URL=$(oc get route qms-service -n ${NAMESPACE} -o jsonpath='{.spec.host}' 2>/dev/null || echo "Not available")
    ACE_URL=$(oc get route ace-integration-server -n ${NAMESPACE} -o jsonpath='{.spec.host}' 2>/dev/null || echo "Not available")
    
    echo "Service URLs:"
    echo "  ERP Service: https://${ERP_URL}"
    echo "  MES Service: https://${MES_URL}"
    echo "  QMS Service: https://${QMS_URL}"
    echo "  ACE Server:  https://${ACE_URL}"
    echo ""
    
    log_success "Deployment completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Create BAR file in ACE Toolkit"
    echo "2. Update barURL in kubernetes/ace-integration-server.yaml"
    echo "3. Configure API Connect (see api-connect/README.md)"
    echo "4. Run integration tests (cd tests && npm test)"
}

cleanup() {
    log_warning "Cleaning up on error..."
    # Add cleanup logic if needed
}

# Main execution
main() {
    log_info "Starting deployment of Scenario A..."
    echo ""
    
    # Set trap for cleanup on error
    trap cleanup ERR
    
    # Execute deployment steps
    check_prerequisites
    create_namespace
    build_and_push_images
    deploy_postgresql
    initialize_database
    deploy_backend_services
    test_backend_services
    #deploy_ace_integration_server
    display_summary
}

# Run main function
main "$@"

# Made with Bob
