-- ============================================================================
-- Seed Data Script - ERP Orders
-- Scenario A - IBM Cloud Pak for Integration
-- ============================================================================
-- This script populates the orders table with realistic test data
-- representing various order statuses, priorities, and plants
-- ============================================================================

-- Insert sample orders with diverse characteristics
INSERT INTO orders (order_id, order_num, customer_id, customer_name, order_date, delivery_date, status, total_amount, currency, plant_code, plant_name, priority, notes, created_by, updated_by) VALUES
-- Active orders in progress
('ORD-2026-001', 'PO-2026-001234', 'CUST-001', 'Leonardo S.p.A. - Divisione Aeronautica', '2026-01-15 08:30:00', '2026-03-15 17:00:00', 'IN_PROGRESS', 1250000.00, 'EUR', 'PLT-001', 'Stabilimento di Torino', 'HIGH', 'Ordine prioritario per componenti aeronautici', 'system', 'operator_001'),
('ORD-2026-002', 'PO-2026-001235', 'CUST-002', 'Fincantieri S.p.A.', '2026-01-20 09:15:00', '2026-04-20 17:00:00', 'IN_PROGRESS', 850000.00, 'EUR', 'PLT-002', 'Stabilimento di Genova', 'NORMAL', 'Componenti navali standard', 'system', 'operator_002'),
('ORD-2026-003', 'PO-2026-001236', 'CUST-003', 'Avio Aero', '2026-01-25 10:00:00', '2026-03-25 17:00:00', 'IN_PROGRESS', 2100000.00, 'EUR', 'PLT-001', 'Stabilimento di Torino', 'URGENT', 'Turbine per motori aeronautici - consegna urgente', 'system', 'operator_001'),
('ORD-2026-004', 'PO-2026-001237', 'CUST-004', 'Thales Alenia Space Italia', '2026-02-01 08:00:00', '2026-05-01 17:00:00', 'IN_PROGRESS', 3500000.00, 'EUR', 'PLT-003', 'Stabilimento di Roma', 'HIGH', 'Componenti satellitari ad alta precisione', 'system', 'operator_003'),
('ORD-2026-005', 'PO-2026-001238', 'CUST-005', 'Elettronica S.p.A.', '2026-02-05 09:30:00', '2026-04-05 17:00:00', 'IN_PROGRESS', 950000.00, 'EUR', 'PLT-002', 'Stabilimento di Genova', 'NORMAL', 'Sistemi elettronici di difesa', 'system', 'operator_002'),

-- Recently completed orders
('ORD-2026-006', 'PO-2026-001239', 'CUST-001', 'Leonardo S.p.A. - Divisione Aeronautica', '2026-01-10 08:00:00', '2026-02-28 17:00:00', 'COMPLETED', 750000.00, 'EUR', 'PLT-001', 'Stabilimento di Torino', 'NORMAL', 'Ordine completato con successo', 'system', 'operator_001'),
('ORD-2026-007', 'PO-2026-001240', 'CUST-006', 'MBDA Italia', '2026-01-12 10:30:00', '2026-03-01 17:00:00', 'COMPLETED', 1800000.00, 'EUR', 'PLT-003', 'Stabilimento di Roma', 'HIGH', 'Sistemi missilistici - completato', 'system', 'operator_003'),
('ORD-2026-008', 'PO-2026-001241', 'CUST-002', 'Fincantieri S.p.A.', '2026-01-18 09:00:00', '2026-03-10 17:00:00', 'COMPLETED', 620000.00, 'EUR', 'PLT-002', 'Stabilimento di Genova', 'NORMAL', 'Completato nei tempi previsti', 'system', 'operator_002'),

-- New orders just created
('ORD-2026-009', 'PO-2026-001242', 'CUST-007', 'Telespazio S.p.A.', '2026-02-10 08:15:00', '2026-05-10 17:00:00', 'CREATED', 1100000.00, 'EUR', 'PLT-003', 'Stabilimento di Roma', 'NORMAL', 'Nuovo ordine in attesa di avvio produzione', 'system', 'system'),
('ORD-2026-010', 'PO-2026-001243', 'CUST-003', 'Avio Aero', '2026-02-12 09:45:00', '2026-04-15 17:00:00', 'CREATED', 1650000.00, 'EUR', 'PLT-001', 'Stabilimento di Torino', 'HIGH', 'In attesa di allocazione risorse', 'system', 'system'),

-- Orders on hold
('ORD-2026-011', 'PO-2026-001244', 'CUST-008', 'OTO Melara', '2026-01-28 10:00:00', '2026-04-28 17:00:00', 'ON_HOLD', 890000.00, 'EUR', 'PLT-002', 'Stabilimento di Genova', 'NORMAL', 'In attesa di approvazione cliente per modifiche', 'system', 'operator_002'),
('ORD-2026-012', 'PO-2026-001245', 'CUST-004', 'Thales Alenia Space Italia', '2026-02-03 08:30:00', '2026-06-03 17:00:00', 'ON_HOLD', 2800000.00, 'EUR', 'PLT-003', 'Stabilimento di Roma', 'HIGH', 'Sospeso per verifica specifiche tecniche', 'system', 'operator_003'),

-- Cancelled order
('ORD-2026-013', 'PO-2026-001246', 'CUST-009', 'Selex ES', '2026-01-22 11:00:00', '2026-03-22 17:00:00', 'CANCELLED', 450000.00, 'EUR', 'PLT-001', 'Stabilimento di Torino', 'LOW', 'Cancellato su richiesta cliente', 'system', 'operator_001'),

-- Additional in-progress orders for testing
('ORD-2026-014', 'PO-2026-001247', 'CUST-001', 'Leonardo S.p.A. - Divisione Aeronautica', '2026-02-08 08:00:00', '2026-04-08 17:00:00', 'IN_PROGRESS', 1450000.00, 'EUR', 'PLT-001', 'Stabilimento di Torino', 'URGENT', 'Componenti critici per elicotteri', 'system', 'operator_001'),
('ORD-2026-015', 'PO-2026-001248', 'CUST-010', 'Vitrociset S.p.A.', '2026-02-11 09:30:00', '2026-05-11 17:00:00', 'IN_PROGRESS', 780000.00, 'EUR', 'PLT-003', 'Stabilimento di Roma', 'NORMAL', 'Sistemi di controllo e simulazione', 'system', 'operator_003'),
('ORD-2026-016', 'PO-2026-001249', 'CUST-002', 'Fincantieri S.p.A.', '2026-02-14 10:15:00', '2026-05-14 17:00:00', 'IN_PROGRESS', 1320000.00, 'EUR', 'PLT-002', 'Stabilimento di Genova', 'HIGH', 'Sistemi propulsione navale', 'system', 'operator_002'),

-- Orders with different priorities for testing
('ORD-2026-017', 'PO-2026-001250', 'CUST-005', 'Elettronica S.p.A.', '2026-02-16 08:45:00', '2026-04-16 17:00:00', 'IN_PROGRESS', 560000.00, 'EUR', 'PLT-002', 'Stabilimento di Genova', 'LOW', 'Ordine a bassa priorità', 'system', 'operator_002'),
('ORD-2026-018', 'PO-2026-001251', 'CUST-006', 'MBDA Italia', '2026-02-18 09:00:00', '2026-05-18 17:00:00', 'IN_PROGRESS', 2250000.00, 'EUR', 'PLT-003', 'Stabilimento di Roma', 'URGENT', 'Sistemi d''arma - massima priorità', 'system', 'operator_003'),
('ORD-2026-019', 'PO-2026-001252', 'CUST-007', 'Telespazio S.p.A.', '2026-02-20 10:30:00', '2026-06-20 17:00:00', 'CREATED', 1890000.00, 'EUR', 'PLT-003', 'Stabilimento di Roma', 'HIGH', 'Stazioni di terra satellitari', 'system', 'system'),
('ORD-2026-020', 'PO-2026-001253', 'CUST-003', 'Avio Aero', '2026-02-22 08:15:00', '2026-04-22 17:00:00', 'IN_PROGRESS', 1750000.00, 'EUR', 'PLT-001', 'Stabilimento di Torino', 'HIGH', 'Pale turbina ad alta efficienza', 'system', 'operator_001'),

-- Additional completed orders for historical data
('ORD-2026-021', 'PO-2026-001254', 'CUST-008', 'OTO Melara', '2026-01-05 09:00:00', '2026-02-20 17:00:00', 'COMPLETED', 980000.00, 'EUR', 'PLT-002', 'Stabilimento di Genova', 'NORMAL', 'Sistemi d''arma navali completati', 'system', 'operator_002'),
('ORD-2026-022', 'PO-2026-001255', 'CUST-009', 'Selex ES', '2026-01-08 10:00:00', '2026-02-25 17:00:00', 'COMPLETED', 1120000.00, 'EUR', 'PLT-001', 'Stabilimento di Torino', 'HIGH', 'Radar e sensori completati', 'system', 'operator_001'),
('ORD-2026-023', 'PO-2026-001256', 'CUST-010', 'Vitrociset S.p.A.', '2026-01-11 08:30:00', '2026-03-05 17:00:00', 'COMPLETED', 670000.00, 'EUR', 'PLT-003', 'Stabilimento di Roma', 'NORMAL', 'Simulatori di volo completati', 'system', 'operator_003'),

-- Orders for load testing (higher volume)
('ORD-2026-024', 'PO-2026-001257', 'CUST-001', 'Leonardo S.p.A. - Divisione Aeronautica', '2026-02-24 09:15:00', '2026-05-24 17:00:00', 'IN_PROGRESS', 2100000.00, 'EUR', 'PLT-001', 'Stabilimento di Torino', 'URGENT', 'Ordine complesso multi-fase', 'system', 'operator_001'),
('ORD-2026-025', 'PO-2026-001258', 'CUST-002', 'Fincantieri S.p.A.', '2026-02-25 10:00:00', '2026-06-25 17:00:00', 'IN_PROGRESS', 3200000.00, 'EUR', 'PLT-002', 'Stabilimento di Genova', 'HIGH', 'Progetto navale di grande scala', 'system', 'operator_002'),
('ORD-2026-026', 'PO-2026-001259', 'CUST-004', 'Thales Alenia Space Italia', '2026-02-26 08:00:00', '2026-07-26 17:00:00', 'IN_PROGRESS', 4500000.00, 'EUR', 'PLT-003', 'Stabilimento di Roma', 'URGENT', 'Satellite completo - progetto strategico', 'system', 'operator_003'),
('ORD-2026-027', 'PO-2026-001260', 'CUST-005', 'Elettronica S.p.A.', '2026-02-27 09:30:00', '2026-05-27 17:00:00', 'IN_PROGRESS', 1340000.00, 'EUR', 'PLT-002', 'Stabilimento di Genova', 'NORMAL', 'Suite elettronica integrata', 'system', 'operator_002'),
('ORD-2026-028', 'PO-2026-001261', 'CUST-006', 'MBDA Italia', '2026-02-28 10:15:00', '2026-06-28 17:00:00', 'CREATED', 2650000.00, 'EUR', 'PLT-003', 'Stabilimento di Roma', 'HIGH', 'Sistema missilistico avanzato', 'system', 'system'),
('ORD-2026-029', 'PO-2026-001262', 'CUST-007', 'Telespazio S.p.A.', '2026-03-01 08:45:00', '2026-07-01 17:00:00', 'CREATED', 1560000.00, 'EUR', 'PLT-003', 'Stabilimento di Roma', 'NORMAL', 'Infrastruttura comunicazioni satellitari', 'system', 'system'),
('ORD-2026-030', 'PO-2026-001263', 'CUST-003', 'Avio Aero', '2026-03-02 09:00:00', '2026-05-02 17:00:00', 'IN_PROGRESS', 1890000.00, 'EUR', 'PLT-001', 'Stabilimento di Torino', 'HIGH', 'Motori aeronautici di nuova generazione', 'system', 'operator_001');

-- ============================================================================
-- Verify data insertion
-- ============================================================================

-- Display summary of inserted orders
SELECT 
    status,
    priority,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_value,
    AVG(total_amount) AS avg_value
FROM orders
GROUP BY status, priority
ORDER BY status, priority;

-- Display orders by plant
SELECT 
    plant_code,
    plant_name,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_value
FROM orders
GROUP BY plant_code, plant_name
ORDER BY plant_code;

-- Display overall statistics
SELECT 
    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT plant_code) AS active_plants,
    SUM(total_amount) AS total_order_value,
    MIN(order_date) AS earliest_order,
    MAX(order_date) AS latest_order
FROM orders;

-- Made with Bob
