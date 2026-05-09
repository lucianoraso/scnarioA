-- ============================================================================
-- Database Initialization Script for Production Order Consolidation Demo
-- Scenario A - IBM Cloud Pak for Integration
-- ============================================================================
-- This script creates the database schemas for three mock backend systems:
-- 1. ERP (Enterprise Resource Planning) - Order Management
-- 2. MES (Manufacturing Execution System) - Production Steps
-- 3. QMS (Quality Management System) - Quality Checks
-- ============================================================================

-- Drop existing tables if they exist (for clean reinstall)
DROP TABLE IF EXISTS quality_checks CASCADE;
DROP TABLE IF EXISTS production_steps CASCADE;
DROP TABLE IF EXISTS orders CASCADE;

-- ============================================================================
-- ERP SYSTEM - Orders Table
-- ============================================================================
-- Stores order header information including customer, dates, and status
-- ============================================================================

CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    order_num VARCHAR(100) NOT NULL UNIQUE,
    customer_id VARCHAR(50) NOT NULL,
    customer_name VARCHAR(200) NOT NULL,
    order_date TIMESTAMP NOT NULL,
    delivery_date TIMESTAMP,
    status VARCHAR(50) NOT NULL CHECK (status IN ('CREATED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'ON_HOLD')),
    total_amount DECIMAL(15,2),
    currency VARCHAR(3) DEFAULT 'EUR',
    plant_code VARCHAR(10),
    plant_name VARCHAR(200),
    priority VARCHAR(20) DEFAULT 'NORMAL' CHECK (priority IN ('LOW', 'NORMAL', 'HIGH', 'URGENT')),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

-- Indexes for performance optimization
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_orders_plant ON orders(plant_code);
CREATE INDEX idx_orders_priority ON orders(priority);

-- Comments for documentation
COMMENT ON TABLE orders IS 'ERP System - Order header information';
COMMENT ON COLUMN orders.order_id IS 'Unique order identifier';
COMMENT ON COLUMN orders.order_num IS 'Human-readable order number';
COMMENT ON COLUMN orders.status IS 'Order status: CREATED, IN_PROGRESS, COMPLETED, CANCELLED, ON_HOLD';

-- ============================================================================
-- MES SYSTEM - Production Steps Table
-- ============================================================================
-- Stores production step details including workstation, operator, and timing
-- ============================================================================

CREATE TABLE production_steps (
    step_id SERIAL PRIMARY KEY,
    production_order_id VARCHAR(50) NOT NULL,
    step_number INTEGER NOT NULL,
    step_name VARCHAR(200) NOT NULL,
    step_description TEXT,
    workstation_id VARCHAR(50),
    workstation_name VARCHAR(200),
    operator_id VARCHAR(50),
    operator_name VARCHAR(200),
    status VARCHAR(50) NOT NULL CHECK (status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'FAILED', 'SKIPPED', 'ON_HOLD')),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    duration_minutes INTEGER,
    quantity_planned INTEGER NOT NULL DEFAULT 0,
    quantity_completed INTEGER DEFAULT 0,
    quantity_rejected INTEGER DEFAULT 0,
    efficiency_percentage DECIMAL(5,2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_production_order FOREIGN KEY (production_order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT chk_step_number_positive CHECK (step_number > 0),
    CONSTRAINT chk_quantities_valid CHECK (quantity_completed >= 0 AND quantity_rejected >= 0 AND quantity_planned >= 0)
);

-- Indexes for performance optimization
CREATE INDEX idx_prod_steps_order ON production_steps(production_order_id);
CREATE INDEX idx_prod_steps_status ON production_steps(status);
CREATE INDEX idx_prod_steps_workstation ON production_steps(workstation_id);
CREATE INDEX idx_prod_steps_operator ON production_steps(operator_id);
CREATE INDEX idx_prod_steps_start_time ON production_steps(start_time);
CREATE UNIQUE INDEX idx_prod_steps_order_number ON production_steps(production_order_id, step_number);

-- Comments for documentation
COMMENT ON TABLE production_steps IS 'MES System - Production step details and execution tracking';
COMMENT ON COLUMN production_steps.step_id IS 'Unique step identifier (auto-generated)';
COMMENT ON COLUMN production_steps.production_order_id IS 'Reference to order in ERP system';
COMMENT ON COLUMN production_steps.status IS 'Step status: PENDING, IN_PROGRESS, COMPLETED, FAILED, SKIPPED, ON_HOLD';

-- ============================================================================
-- QMS SYSTEM - Quality Checks Table
-- ============================================================================
-- Stores quality check results including measurements and inspector details
-- ============================================================================

CREATE TABLE quality_checks (
    check_id SERIAL PRIMARY KEY,
    ref_order VARCHAR(50) NOT NULL,
    step_id INTEGER NOT NULL,
    check_type VARCHAR(100) NOT NULL,
    check_parameter VARCHAR(200),
    check_description TEXT,
    measured_value DECIMAL(15,4),
    target_value DECIMAL(15,4),
    tolerance_min DECIMAL(15,4),
    tolerance_max DECIMAL(15,4),
    unit_of_measure VARCHAR(50),
    result VARCHAR(50) NOT NULL CHECK (result IN ('PASS', 'FAIL', 'PENDING', 'NOT_APPLICABLE', 'CONDITIONAL_PASS')),
    severity VARCHAR(20) DEFAULT 'NORMAL' CHECK (severity IN ('LOW', 'NORMAL', 'HIGH', 'CRITICAL')),
    inspector_id VARCHAR(50),
    inspector_name VARCHAR(200),
    check_timestamp TIMESTAMP NOT NULL,
    notes TEXT,
    corrective_action TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_quality_order FOREIGN KEY (ref_order) REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_quality_step FOREIGN KEY (step_id) REFERENCES production_steps(step_id) ON DELETE CASCADE,
    CONSTRAINT chk_tolerance_valid CHECK (tolerance_min IS NULL OR tolerance_max IS NULL OR tolerance_min <= tolerance_max)
);

-- Indexes for performance optimization
CREATE INDEX idx_quality_order ON quality_checks(ref_order);
CREATE INDEX idx_quality_step ON quality_checks(step_id);
CREATE INDEX idx_quality_result ON quality_checks(result);
CREATE INDEX idx_quality_check_type ON quality_checks(check_type);
CREATE INDEX idx_quality_timestamp ON quality_checks(check_timestamp);
CREATE INDEX idx_quality_inspector ON quality_checks(inspector_id);
CREATE INDEX idx_quality_severity ON quality_checks(severity);

-- Comments for documentation
COMMENT ON TABLE quality_checks IS 'QMS System - Quality check results and measurements';
COMMENT ON COLUMN quality_checks.check_id IS 'Unique check identifier (auto-generated)';
COMMENT ON COLUMN quality_checks.ref_order IS 'Reference to order in ERP system';
COMMENT ON COLUMN quality_checks.step_id IS 'Reference to production step in MES system';
COMMENT ON COLUMN quality_checks.result IS 'Check result: PASS, FAIL, PENDING, NOT_APPLICABLE, CONDITIONAL_PASS';

-- ============================================================================
-- Trigger Functions for automatic timestamp updates
-- ============================================================================

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for orders table
CREATE TRIGGER update_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for production_steps table
CREATE TRIGGER update_production_steps_updated_at
    BEFORE UPDATE ON production_steps
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- Views for common queries
-- ============================================================================

-- View: Complete order overview with step counts
CREATE OR REPLACE VIEW v_order_overview AS
SELECT 
    o.order_id,
    o.order_num,
    o.customer_name,
    o.status AS order_status,
    o.plant_name,
    o.priority,
    COUNT(DISTINCT ps.step_id) AS total_steps,
    COUNT(DISTINCT CASE WHEN ps.status = 'COMPLETED' THEN ps.step_id END) AS completed_steps,
    COUNT(DISTINCT CASE WHEN ps.status = 'FAILED' THEN ps.step_id END) AS failed_steps,
    COUNT(DISTINCT qc.check_id) AS total_quality_checks,
    COUNT(DISTINCT CASE WHEN qc.result = 'PASS' THEN qc.check_id END) AS passed_checks,
    COUNT(DISTINCT CASE WHEN qc.result = 'FAIL' THEN qc.check_id END) AS failed_checks,
    o.order_date,
    o.delivery_date
FROM orders o
LEFT JOIN production_steps ps ON o.order_id = ps.production_order_id
LEFT JOIN quality_checks qc ON o.order_id = qc.ref_order
GROUP BY o.order_id, o.order_num, o.customer_name, o.status, o.plant_name, o.priority, o.order_date, o.delivery_date;

COMMENT ON VIEW v_order_overview IS 'Consolidated view of orders with step and quality check statistics';

-- ============================================================================
-- Grant permissions (adjust as needed for your environment)
-- ============================================================================

-- Grant permissions to application user (replace 'app_user' with actual username)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user;
-- GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly_user;

-- ============================================================================
-- Database initialization complete
-- ============================================================================

-- Display table information
SELECT 
    'Schema creation completed successfully' AS status,
    COUNT(*) AS table_count
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE';

-- Made with Bob
