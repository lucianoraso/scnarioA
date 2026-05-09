-- ============================================================================
-- Seed Data Script - MES Production Steps
-- Scenario A - IBM Cloud Pak for Integration
-- ============================================================================
-- This script populates the production_steps table with realistic test data
-- representing various production phases, workstations, and operators
-- ============================================================================

-- Production steps for ORD-2026-001 (IN_PROGRESS - High Priority)
INSERT INTO production_steps (production_order_id, step_number, step_name, step_description, workstation_id, workstation_name, operator_id, operator_name, status, start_time, end_time, duration_minutes, quantity_planned, quantity_completed, quantity_rejected, efficiency_percentage, notes) VALUES
('ORD-2026-001', 1, 'Preparazione Materiali', 'Prelievo e preparazione materie prime dal magazzino', 'WS-001', 'Magazzino Materie Prime', 'OP-101', 'Mario Rossi', 'COMPLETED', '2026-01-16 08:00:00', '2026-01-16 10:30:00', 150, 100, 100, 0, 100.00, 'Completato senza problemi'),
('ORD-2026-001', 2, 'Taglio Lamiere', 'Taglio laser lamiere in alluminio aeronautico', 'WS-002', 'Centro Taglio Laser', 'OP-102', 'Giuseppe Bianchi', 'COMPLETED', '2026-01-16 11:00:00', '2026-01-16 16:45:00', 345, 100, 98, 2, 98.00, 'Due pezzi scartati per imperfezioni'),
('ORD-2026-001', 3, 'Formatura', 'Formatura componenti con pressa idraulica', 'WS-003', 'Reparto Formatura', 'OP-103', 'Anna Verdi', 'COMPLETED', '2026-01-17 08:00:00', '2026-01-17 14:20:00', 380, 98, 96, 2, 97.96, 'Processo completato con successo'),
('ORD-2026-001', 4, 'Trattamento Termico', 'Trattamento termico per indurimento', 'WS-004', 'Forno Trattamento Termico', 'OP-104', 'Luca Neri', 'COMPLETED', '2026-01-18 08:00:00', '2026-01-18 20:00:00', 720, 96, 96, 0, 100.00, 'Ciclo termico completato correttamente'),
('ORD-2026-001', 5, 'Lavorazione CNC', 'Lavorazione di precisione su centro CNC 5 assi', 'WS-005', 'Centro CNC 5 Assi', 'OP-105', 'Francesca Gialli', 'IN_PROGRESS', '2026-01-19 08:00:00', NULL, NULL, 96, 45, 1, 46.88, 'In corso - 45 pezzi completati'),
('ORD-2026-001', 6, 'Controllo Dimensionale', 'Verifica dimensionale con CMM', 'WS-006', 'Sala Metrologia', 'OP-106', 'Paolo Blu', 'PENDING', NULL, NULL, NULL, 95, 0, 0, 0.00, 'In attesa completamento fase precedente'),
('ORD-2026-001', 7, 'Trattamento Superficiale', 'Anodizzazione componenti', 'WS-007', 'Reparto Trattamenti', 'OP-107', 'Elena Rosa', 'PENDING', NULL, NULL, NULL, 95, 0, 0, 0.00, 'Programmato'),
('ORD-2026-001', 8, 'Assemblaggio Finale', 'Assemblaggio e montaggio componenti', 'WS-008', 'Linea Assemblaggio', 'OP-108', 'Marco Viola', 'PENDING', NULL, NULL, NULL, 95, 0, 0, 0.00, 'Programmato'),
('ORD-2026-001', 9, 'Collaudo Funzionale', 'Test funzionali e prove di carico', 'WS-009', 'Banco Collaudo', 'OP-109', 'Sara Arancio', 'PENDING', NULL, NULL, NULL, 95, 0, 0, 0.00, 'Programmato'),
('ORD-2026-001', 10, 'Imballaggio e Spedizione', 'Imballaggio per trasporto aereo', 'WS-010', 'Area Spedizioni', 'OP-110', 'Andrea Grigio', 'PENDING', NULL, NULL, NULL, 95, 0, 0, 0.00, 'Programmato');

-- Production steps for ORD-2026-002 (IN_PROGRESS - Normal Priority)
INSERT INTO production_steps (production_order_id, step_number, step_name, step_description, workstation_id, workstation_name, operator_id, operator_name, status, start_time, end_time, duration_minutes, quantity_planned, quantity_completed, quantity_rejected, efficiency_percentage, notes) VALUES
('ORD-2026-002', 1, 'Preparazione Materiali', 'Prelievo acciaio navale dal magazzino', 'WS-011', 'Magazzino Genova', 'OP-201', 'Giovanni Marrone', 'COMPLETED', '2026-01-21 08:00:00', '2026-01-21 09:45:00', 105, 50, 50, 0, 100.00, 'Materiali pronti'),
('ORD-2026-002', 2, 'Taglio Plasma', 'Taglio plasma lamiere spesse', 'WS-012', 'Centro Taglio Plasma', 'OP-202', 'Silvia Celeste', 'COMPLETED', '2026-01-21 10:00:00', '2026-01-21 17:30:00', 450, 50, 49, 1, 98.00, 'Un pezzo scartato'),
('ORD-2026-002', 3, 'Saldatura', 'Saldatura TIG componenti navali', 'WS-013', 'Reparto Saldatura', 'OP-203', 'Roberto Turchese', 'COMPLETED', '2026-01-22 08:00:00', '2026-01-23 17:00:00', 1860, 49, 48, 1, 97.96, 'Saldature certificate'),
('ORD-2026-002', 4, 'Controllo Radiografico', 'Controllo RX saldature', 'WS-014', 'Sala Radiografia', 'OP-204', 'Chiara Indaco', 'IN_PROGRESS', '2026-01-24 08:00:00', NULL, NULL, 48, 25, 0, 52.08, 'Controlli in corso'),
('ORD-2026-002', 5, 'Sabbiatura', 'Sabbiatura superfici', 'WS-015', 'Cabina Sabbiatura', 'OP-205', 'Davide Magenta', 'PENDING', NULL, NULL, NULL, 48, 0, 0, 0.00, 'Programmato'),
('ORD-2026-002', 6, 'Verniciatura', 'Verniciatura protettiva marina', 'WS-016', 'Cabina Verniciatura', 'OP-206', 'Laura Corallo', 'PENDING', NULL, NULL, NULL, 48, 0, 0, 0.00, 'Programmato');

-- Production steps for ORD-2026-003 (IN_PROGRESS - Urgent Priority)
INSERT INTO production_steps (production_order_id, step_number, step_name, step_description, workstation_id, workstation_name, operator_id, operator_name, status, start_time, end_time, duration_minutes, quantity_planned, quantity_completed, quantity_rejected, efficiency_percentage, notes) VALUES
('ORD-2026-003', 1, 'Fusione Leghe Speciali', 'Fusione leghe titanio per turbine', 'WS-017', 'Fonderia Speciale', 'OP-301', 'Matteo Smeraldo', 'COMPLETED', '2026-01-26 06:00:00', '2026-01-27 18:00:00', 2160, 20, 20, 0, 100.00, 'Fusione perfetta'),
('ORD-2026-003', 2, 'Colata e Raffreddamento', 'Colata in stampi ceramici', 'WS-018', 'Area Colata', 'OP-302', 'Valentina Rubino', 'COMPLETED', '2026-01-28 08:00:00', '2026-01-29 20:00:00', 2160, 20, 19, 1, 95.00, 'Un pezzo con difetto di colata'),
('ORD-2026-003', 3, 'Lavorazione Pale Turbina', 'Fresatura 5 assi pale turbina', 'WS-019', 'CNC Alta Precisione', 'OP-303', 'Simone Zaffiro', 'COMPLETED', '2026-01-30 08:00:00', '2026-02-02 17:00:00', 5340, 19, 19, 0, 100.00, 'Tolleranze rispettate'),
('ORD-2026-003', 4, 'Bilanciatura Dinamica', 'Bilanciatura componenti rotanti', 'WS-020', 'Banco Bilanciatura', 'OP-304', 'Federica Topazio', 'IN_PROGRESS', '2026-02-03 08:00:00', NULL, NULL, 19, 8, 0, 42.11, 'Bilanciatura in corso'),
('ORD-2026-003', 5, 'Controllo Ultrasuoni', 'Controllo UT per difetti interni', 'WS-021', 'Laboratorio UT', 'OP-305', 'Alessandro Ametista', 'PENDING', NULL, NULL, NULL, 19, 0, 0, 0.00, 'Programmato urgente'),
('ORD-2026-003', 6, 'Rivestimento Ceramico', 'Applicazione rivestimento termico', 'WS-022', 'Reparto Coating', 'OP-306', 'Beatrice Opale', 'PENDING', NULL, NULL, NULL, 19, 0, 0, 0.00, 'Programmato'),
('ORD-2026-003', 7, 'Test Banco Prova', 'Test su banco prova turbina', 'WS-023', 'Banco Prova Turbine', 'OP-307', 'Cristiano Quarzo', 'PENDING', NULL, NULL, NULL, 19, 0, 0, 0.00, 'Programmato');

-- Production steps for ORD-2026-004 (IN_PROGRESS - High Priority - Satellite Components)
INSERT INTO production_steps (production_order_id, step_number, step_name, step_description, workstation_id, workstation_name, operator_id, operator_name, status, start_time, end_time, duration_minutes, quantity_planned, quantity_completed, quantity_rejected, efficiency_percentage, notes) VALUES
('ORD-2026-004', 1, 'Preparazione Camera Bianca', 'Setup ambiente cleanroom classe 100', 'WS-024', 'Camera Bianca A', 'OP-401', 'Daniela Perla', 'COMPLETED', '2026-02-02 08:00:00', '2026-02-02 12:00:00', 240, 10, 10, 0, 100.00, 'Ambiente certificato'),
('ORD-2026-004', 2, 'Assemblaggio Struttura', 'Assemblaggio struttura satellitare', 'WS-025', 'Banco Assemblaggio Satelliti', 'OP-402', 'Emanuele Giada', 'COMPLETED', '2026-02-03 08:00:00', '2026-02-05 17:00:00', 3540, 10, 10, 0, 100.00, 'Assemblaggio preciso'),
('ORD-2026-004', 3, 'Integrazione Elettronica', 'Integrazione sistemi elettronici', 'WS-026', 'Laboratorio Elettronica', 'OP-403', 'Filippo Ambra', 'IN_PROGRESS', '2026-02-06 08:00:00', NULL, NULL, 10, 4, 0, 40.00, 'Integrazione complessa in corso'),
('ORD-2026-004', 4, 'Test Funzionali', 'Test funzionali sottosistemi', 'WS-027', 'Laboratorio Test', 'OP-404', 'Giorgia Corallo', 'PENDING', NULL, NULL, NULL, 10, 0, 0, 0.00, 'Programmato'),
('ORD-2026-004', 5, 'Test Ambientali', 'Test vibrazione e termico', 'WS-028', 'Camera Test Ambientali', 'OP-405', 'Jacopo Tormalina', 'PENDING', NULL, NULL, NULL, 10, 0, 0, 0.00, 'Programmato');

-- Production steps for ORD-2026-006 (COMPLETED)
INSERT INTO production_steps (production_order_id, step_number, step_name, step_description, workstation_id, workstation_name, operator_id, operator_name, status, start_time, end_time, duration_minutes, quantity_planned, quantity_completed, quantity_rejected, efficiency_percentage, notes) VALUES
('ORD-2026-006', 1, 'Preparazione Materiali', 'Prelievo materiali', 'WS-001', 'Magazzino Materie Prime', 'OP-101', 'Mario Rossi', 'COMPLETED', '2026-01-11 08:00:00', '2026-01-11 09:30:00', 90, 75, 75, 0, 100.00, 'Completato'),
('ORD-2026-006', 2, 'Lavorazione Meccanica', 'Lavorazione componenti', 'WS-002', 'Centro Taglio Laser', 'OP-102', 'Giuseppe Bianchi', 'COMPLETED', '2026-01-11 10:00:00', '2026-01-12 17:00:00', 1860, 75, 74, 1, 98.67, 'Completato'),
('ORD-2026-006', 3, 'Assemblaggio', 'Assemblaggio finale', 'WS-008', 'Linea Assemblaggio', 'OP-108', 'Marco Viola', 'COMPLETED', '2026-01-13 08:00:00', '2026-01-14 17:00:00', 1860, 74, 74, 0, 100.00, 'Completato'),
('ORD-2026-006', 4, 'Collaudo', 'Collaudo finale', 'WS-009', 'Banco Collaudo', 'OP-109', 'Sara Arancio', 'COMPLETED', '2026-01-15 08:00:00', '2026-01-15 17:00:00', 540, 74, 74, 0, 100.00, 'Tutti i test superati'),
('ORD-2026-006', 5, 'Spedizione', 'Imballaggio e spedizione', 'WS-010', 'Area Spedizioni', 'OP-110', 'Andrea Grigio', 'COMPLETED', '2026-01-16 08:00:00', '2026-01-16 12:00:00', 240, 74, 74, 0, 100.00, 'Spedito');

-- Production steps for ORD-2026-014 (IN_PROGRESS - Urgent - Helicopter Components)
INSERT INTO production_steps (production_order_id, step_number, step_name, step_description, workstation_id, workstation_name, operator_id, operator_name, status, start_time, end_time, duration_minutes, quantity_planned, quantity_completed, quantity_rejected, efficiency_percentage, notes) VALUES
('ORD-2026-014', 1, 'Preparazione Compositi', 'Preparazione materiali compositi', 'WS-029', 'Laboratorio Compositi', 'OP-501', 'Katia Diamante', 'COMPLETED', '2026-02-09 08:00:00', '2026-02-09 17:00:00', 540, 30, 30, 0, 100.00, 'Materiali pronti'),
('ORD-2026-014', 2, 'Stratificazione', 'Stratificazione fibra di carbonio', 'WS-030', 'Sala Stratificazione', 'OP-502', 'Lorenzo Cristallo', 'COMPLETED', '2026-02-10 08:00:00', '2026-02-11 17:00:00', 1860, 30, 29, 1, 96.67, 'Un pezzo con delaminazione'),
('ORD-2026-014', 3, 'Autoclave', 'Polimerizzazione in autoclave', 'WS-031', 'Autoclave Grande', 'OP-503', 'Monica Berillo', 'COMPLETED', '2026-02-12 08:00:00', '2026-02-13 08:00:00', 1440, 29, 29, 0, 100.00, 'Ciclo completato'),
('ORD-2026-014', 4, 'Rifinitura', 'Rifinitura e finitura superfici', 'WS-032', 'Reparto Rifinitura', 'OP-504', 'Nicola Granato', 'IN_PROGRESS', '2026-02-14 08:00:00', NULL, NULL, 29, 12, 0, 41.38, 'Rifinitura in corso'),
('ORD-2026-014', 5, 'Controllo NDT', 'Controllo non distruttivo', 'WS-033', 'Laboratorio NDT', 'OP-505', 'Olivia Malachite', 'PENDING', NULL, NULL, NULL, 29, 0, 0, 0.00, 'Programmato'),
('ORD-2026-014', 6, 'Verniciatura Speciale', 'Verniciatura anti-radar', 'WS-034', 'Cabina Verniciatura Speciale', 'OP-506', 'Pietro Lapislazzuli', 'PENDING', NULL, NULL, NULL, 29, 0, 0, 0.00, 'Programmato');

-- Production steps for ORD-2026-020 (IN_PROGRESS - High Priority - Turbine Blades)
INSERT INTO production_steps (production_order_id, step_number, step_name, step_description, workstation_id, workstation_name, operator_id, operator_name, status, start_time, end_time, duration_minutes, quantity_planned, quantity_completed, quantity_rejected, efficiency_percentage, notes) VALUES
('ORD-2026-020', 1, 'Fusione Monocristallina', 'Fusione monocristallina pale', 'WS-035', 'Forno Monocristallino', 'OP-601', 'Quirino Turchese', 'COMPLETED', '2026-02-23 06:00:00', '2026-02-25 18:00:00', 4320, 15, 15, 0, 100.00, 'Cristalli perfetti'),
('ORD-2026-020', 2, 'Elettroerosione', 'Lavorazione EDM pale', 'WS-036', 'Centro EDM', 'OP-602', 'Rosa Acquamarina', 'COMPLETED', '2026-02-26 08:00:00', '2026-02-28 17:00:00', 3540, 15, 14, 1, 93.33, 'Un pezzo con difetto'),
('ORD-2026-020', 3, 'Foratura Raffreddamento', 'Foratura canali raffreddamento', 'WS-037', 'Centro Foratura Laser', 'OP-603', 'Stefano Onice', 'IN_PROGRESS', '2026-03-01 08:00:00', NULL, NULL, 14, 5, 0, 35.71, 'Foratura di precisione in corso'),
('ORD-2026-020', 4, 'Rivestimento TBC', 'Applicazione Thermal Barrier Coating', 'WS-038', 'Camera TBC', 'OP-604', 'Teresa Agata', 'PENDING', NULL, NULL, NULL, 14, 0, 0, 0.00, 'Programmato'),
('ORD-2026-020', 5, 'Test Aerodinamici', 'Test in galleria del vento', 'WS-039', 'Galleria del Vento', 'OP-605', 'Umberto Calcedonio', 'PENDING', NULL, NULL, NULL, 14, 0, 0, 0.00, 'Programmato');

-- ============================================================================
-- Verify data insertion
-- ============================================================================

-- Display summary of production steps by status
SELECT 
    status,
    COUNT(*) AS step_count,
    SUM(quantity_planned) AS total_planned,
    SUM(quantity_completed) AS total_completed,
    SUM(quantity_rejected) AS total_rejected,
    ROUND(AVG(efficiency_percentage), 2) AS avg_efficiency
FROM production_steps
GROUP BY status
ORDER BY 
    CASE status
        WHEN 'COMPLETED' THEN 1
        WHEN 'IN_PROGRESS' THEN 2
        WHEN 'PENDING' THEN 3
        WHEN 'FAILED' THEN 4
        ELSE 5
    END;

-- Display production steps by order
SELECT 
    ps.production_order_id,
    o.order_num,
    o.status AS order_status,
    COUNT(ps.step_id) AS total_steps,
    COUNT(CASE WHEN ps.status = 'COMPLETED' THEN 1 END) AS completed_steps,
    COUNT(CASE WHEN ps.status = 'IN_PROGRESS' THEN 1 END) AS in_progress_steps,
    COUNT(CASE WHEN ps.status = 'PENDING' THEN 1 END) AS pending_steps
FROM production_steps ps
JOIN orders o ON ps.production_order_id = o.order_id
GROUP BY ps.production_order_id, o.order_num, o.status
ORDER BY ps.production_order_id;

-- Display overall statistics
SELECT 
    COUNT(DISTINCT production_order_id) AS orders_with_steps,
    COUNT(*) AS total_steps,
    COUNT(DISTINCT workstation_id) AS active_workstations,
    COUNT(DISTINCT operator_id) AS active_operators,
    SUM(quantity_planned) AS total_quantity_planned,
    SUM(quantity_completed) AS total_quantity_completed,
    SUM(quantity_rejected) AS total_quantity_rejected,
    ROUND(AVG(efficiency_percentage), 2) AS overall_efficiency
FROM production_steps;

-- Made with Bob
