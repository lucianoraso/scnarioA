-- ============================================================================
-- Seed Data Script - QMS Quality Checks
-- Scenario A - IBM Cloud Pak for Integration
-- ============================================================================
-- This script populates the quality_checks table with realistic test data
-- representing various quality control measurements and inspections
-- ============================================================================

-- Quality checks for ORD-2026-001, Step 1 (Preparazione Materiali - COMPLETED)
INSERT INTO quality_checks (ref_order, step_id, check_type, check_parameter, check_description, measured_value, target_value, tolerance_min, tolerance_max, unit_of_measure, result, severity, inspector_id, inspector_name, check_timestamp, notes) VALUES
('ORD-2026-001', 1, 'Verifica Materiale', 'Certificato Materiale', 'Verifica certificazione lega alluminio 7075-T6', NULL, NULL, NULL, NULL, NULL, 'PASS', 'NORMAL', 'QC-001', 'Ing. Carlo Ferretti', '2026-01-16 10:00:00', 'Certificato conforme EN 485-2'),
('ORD-2026-001', 1, 'Controllo Quantità', 'Conteggio Pezzi', 'Verifica quantità materiale prelevato', 100.0000, 100.0000, 99.0000, 101.0000, 'pz', 'PASS', 'NORMAL', 'QC-001', 'Ing. Carlo Ferretti', '2026-01-16 10:15:00', 'Quantità corretta');

-- Quality checks for ORD-2026-001, Step 2 (Taglio Lamiere - COMPLETED)
INSERT INTO quality_checks (ref_order, step_id, check_type, check_parameter, check_description, measured_value, target_value, tolerance_min, tolerance_max, unit_of_measure, result, severity, inspector_id, inspector_name, check_timestamp, notes, corrective_action) VALUES
('ORD-2026-001', 2, 'Controllo Dimensionale', 'Lunghezza', 'Misura lunghezza componente', 250.05, 250.00, 249.90, 250.10, 'mm', 'PASS', 'NORMAL', 'QC-002', 'Dott.ssa Maria Conti', '2026-01-16 14:00:00', 'Dimensione entro tolleranza', NULL),
('ORD-2026-001', 2, 'Controllo Dimensionale', 'Larghezza', 'Misura larghezza componente', 150.02, 150.00, 149.95, 150.05, 'mm', 'PASS', 'NORMAL', 'QC-002', 'Dott.ssa Maria Conti', '2026-01-16 14:05:00', 'Dimensione entro tolleranza', NULL),
('ORD-2026-001', 2, 'Controllo Dimensionale', 'Spessore', 'Misura spessore lamiera', 3.01, 3.00, 2.98, 3.02, 'mm', 'PASS', 'NORMAL', 'QC-002', 'Dott.ssa Maria Conti', '2026-01-16 14:10:00', 'Spessore uniforme', NULL),
('ORD-2026-001', 2, 'Controllo Visivo', 'Qualità Taglio', 'Ispezione visiva bordi taglio', NULL, NULL, NULL, NULL, NULL, 'PASS', 'NORMAL', 'QC-002', 'Dott.ssa Maria Conti', '2026-01-16 14:20:00', 'Bordi puliti senza bave', NULL),
('ORD-2026-001', 2, 'Controllo Visivo', 'Difetti Superficie', 'Verifica assenza graffi e ammaccature', NULL, NULL, NULL, NULL, NULL, 'FAIL', 'LOW', 'QC-002', 'Dott.ssa Maria Conti', '2026-01-16 14:30:00', 'Due pezzi con graffi superficiali', 'Pezzi scartati e sostituiti');

-- Quality checks for ORD-2026-001, Step 3 (Formatura - COMPLETED)
INSERT INTO quality_checks (ref_order, step_id, check_type, check_parameter, check_description, measured_value, target_value, tolerance_min, tolerance_max, unit_of_measure, result, severity, inspector_id, inspector_name, check_timestamp, notes) VALUES
('ORD-2026-001', 3, 'Controllo Geometrico', 'Raggio Curvatura', 'Misura raggio di curvatura', 50.15, 50.00, 49.50, 50.50, 'mm', 'PASS', 'HIGH', 'QC-003', 'Ing. Paolo Martini', '2026-01-17 12:00:00', 'Curvatura conforme'),
('ORD-2026-001', 3, 'Controllo Geometrico', 'Angolo Piegatura', 'Misura angolo di piegatura', 90.2, 90.0, 89.5, 90.5, 'gradi', 'PASS', 'HIGH', 'QC-003', 'Ing. Paolo Martini', '2026-01-17 12:15:00', 'Angolo preciso'),
('ORD-2026-001', 3, 'Controllo Visivo', 'Cricche Formatura', 'Verifica assenza cricche da formatura', NULL, NULL, NULL, NULL, NULL, 'PASS', 'CRITICAL', 'QC-003', 'Ing. Paolo Martini', '2026-01-17 12:30:00', 'Nessuna cricca rilevata'),
('ORD-2026-001', 3, 'Controllo Dimensionale', 'Planarità', 'Misura planarità superficie', 0.08, 0.00, 0.00, 0.10, 'mm', 'PASS', 'NORMAL', 'QC-003', 'Ing. Paolo Martini', '2026-01-17 12:45:00', 'Planarità accettabile');

-- Quality checks for ORD-2026-001, Step 4 (Trattamento Termico - COMPLETED)
INSERT INTO quality_checks (ref_order, step_id, check_type, check_parameter, check_description, measured_value, target_value, tolerance_min, tolerance_max, unit_of_measure, result, severity, inspector_id, inspector_name, check_timestamp, notes) VALUES
('ORD-2026-001', 4, 'Controllo Durezza', 'Durezza Brinell', 'Misura durezza dopo trattamento', 178.0, 175.0, 170.0, 180.0, 'HB', 'PASS', 'CRITICAL', 'QC-004', 'Dott. Andrea Russo', '2026-01-18 21:00:00', 'Durezza conforme specifica'),
('ORD-2026-001', 4, 'Controllo Microstruttura', 'Analisi Metallografica', 'Verifica microstruttura', NULL, NULL, NULL, NULL, NULL, 'PASS', 'HIGH', 'QC-004', 'Dott. Andrea Russo', '2026-01-18 22:00:00', 'Grani uniformi, nessuna segregazione'),
('ORD-2026-001', 4, 'Controllo Dimensionale', 'Deformazione', 'Misura deformazione post-trattamento', 0.05, 0.00, 0.00, 0.15, 'mm', 'PASS', 'NORMAL', 'QC-004', 'Dott. Andrea Russo', '2026-01-18 21:30:00', 'Deformazione minima');

-- Quality checks for ORD-2026-001, Step 5 (Lavorazione CNC - IN_PROGRESS)
INSERT INTO quality_checks (ref_order, step_id, check_type, check_parameter, check_description, measured_value, target_value, tolerance_min, tolerance_max, unit_of_measure, result, severity, inspector_id, inspector_name, check_timestamp, notes) VALUES
('ORD-2026-001', 5, 'Controllo Dimensionale', 'Diametro Foro', 'Misura diametro fori lavorati', 10.005, 10.000, 9.995, 10.005, 'mm', 'PASS', 'HIGH', 'QC-005', 'Ing. Laura Bianchi', '2026-01-19 14:00:00', 'Primo campione conforme'),
('ORD-2026-001', 5, 'Controllo Rugosità', 'Ra Superficie', 'Misura rugosità superficiale', 0.8, 0.8, 0.0, 1.2, 'μm', 'PASS', 'NORMAL', 'QC-005', 'Ing. Laura Bianchi', '2026-01-19 14:30:00', 'Finitura superficiale ottima'),
('ORD-2026-001', 5, 'Controllo Geometrico', 'Perpendicolarità', 'Verifica perpendicolarità assi', 0.02, 0.00, 0.00, 0.05, 'mm', 'PASS', 'HIGH', 'QC-005', 'Ing. Laura Bianchi', '2026-01-19 15:00:00', 'Geometria precisa');

-- Quality checks for ORD-2026-002, Step 2 (Taglio Plasma - COMPLETED)
INSERT INTO quality_checks (ref_order, step_id, check_type, check_parameter, check_description, measured_value, target_value, tolerance_min, tolerance_max, unit_of_measure, result, severity, inspector_id, inspector_name, check_timestamp, notes, corrective_action) VALUES
('ORD-2026-002', 8, 'Controllo Dimensionale', 'Lunghezza Taglio', 'Verifica lunghezza componente', 1500.5, 1500.0, 1498.0, 1502.0, 'mm', 'PASS', 'NORMAL', 'QC-006', 'Geom. Stefano Verdi', '2026-01-21 16:00:00', 'Dimensione corretta', NULL),
('ORD-2026-002', 8, 'Controllo Visivo', 'Qualità Taglio Plasma', 'Ispezione bordi taglio plasma', NULL, NULL, NULL, NULL, NULL, 'PASS', 'NORMAL', 'QC-006', 'Geom. Stefano Verdi', '2026-01-21 16:30:00', 'Bordi accettabili', NULL),
('ORD-2026-002', 8, 'Controllo Visivo', 'Scorie Taglio', 'Verifica presenza scorie', NULL, NULL, NULL, NULL, NULL, 'FAIL', 'LOW', 'QC-006', 'Geom. Stefano Verdi', '2026-01-21 17:00:00', 'Un pezzo con eccessive scorie', 'Pezzo scartato');

-- Quality checks for ORD-2026-002, Step 3 (Saldatura - COMPLETED)
INSERT INTO quality_checks (ref_order, step_id, check_type, check_parameter, check_description, measured_value, target_value, tolerance_min, tolerance_max, unit_of_measure, result, severity, inspector_id, inspector_name, check_timestamp, notes) VALUES
('ORD-2026-002', 9, 'Controllo Visivo', 'Aspetto Saldatura', 'Ispezione visiva cordoni saldatura', NULL, NULL, NULL, NULL, NULL, 'PASS', 'HIGH', 'QC-007', 'Ing. Francesca Neri', '2026-01-23 16:00:00', 'Cordoni uniformi e regolari'),
('ORD-2026-002', 9, 'Controllo Dimensionale', 'Altezza Cordone', 'Misura altezza cordone saldatura', 4.2, 4.0, 3.5, 4.5, 'mm', 'PASS', 'NORMAL', 'QC-007', 'Ing. Francesca Neri', '2026-01-23 16:30:00', 'Altezza conforme'),
('ORD-2026-002', 9, 'Controllo Penetrazione', 'Penetrazione Saldatura', 'Verifica penetrazione radice', NULL, NULL, NULL, NULL, NULL, 'PASS', 'CRITICAL', 'QC-007', 'Ing. Francesca Neri', '2026-01-23 17:00:00', 'Penetrazione completa');

-- Quality checks for ORD-2026-002, Step 4 (Controllo Radiografico - IN_PROGRESS)
INSERT INTO quality_checks (ref_order, step_id, check_type, check_parameter, check_description, measured_value, target_value, tolerance_min, tolerance_max, unit_of_measure, result, severity, inspector_id, inspector_name, check_timestamp, notes) VALUES
('ORD-2026-002', 10, 'Controllo Radiografico', 'RX Saldature', 'Radiografia saldature - Campione 1-10', NULL, NULL, NULL, NULL, NULL, 'PASS', 'CRITICAL', 'QC-008', 'Dott. Marco Gialli', '2026-01-24 12:00:00', 'Primi 10 campioni: nessun difetto rilevato'),
('ORD-2026-002', 10, 'Controllo Radiografico', 'RX Saldature', 'Radiografia saldature - Campione 11-20', NULL, NULL, NULL, NULL, NULL, 'PASS', 'CRITICAL', 'QC-008', 'Dott. Marco Gialli', '2026-01-24 15:00:00', 'Campioni 11-20: conformi'),
('ORD-2026-002', 10, 'Controllo Radiografico', 'RX Saldature', 'Radiografia saldature - Campione 21-25', NULL, NULL, NULL, NULL, NULL, 'PENDING', 'CRITICAL', 'QC-008', 'Dott. Marco Gialli', '2026-01-24 17:00:00', 'Controllo in corso');

-- Quality checks for ORD-2026-003, Step 1 (Fusione Leghe Speciali - COMPLETED)
INSERT INTO quality_checks (ref_order, step_id, check_type, check_parameter, check_description, measured_value, target_value, tolerance_min, tolerance_max, unit_of_measure, result, severity, inspector_id, inspector_name, check_timestamp, notes) VALUES
('ORD-2026-003', 11, 'Analisi Chimica', 'Composizione Titanio', 'Analisi spettrometrica lega Ti-6Al-4V', NULL, NULL, NULL, NULL, NULL, 'PASS', 'CRITICAL', 'QC-009', 'Dott.ssa Elena Rossi', '2026-01-27 20:00:00', 'Composizione conforme AMS 4928'),
('ORD-2026-003', 11, 'Controllo Temperatura', 'Temperatura Fusione', 'Monitoraggio temperatura fusione', 1670.0, 1668.0, 1665.0, 1675.0, '°C', 'PASS', 'CRITICAL', 'QC-009', 'Dott.ssa Elena Rossi', '2026-01-27 12:00:00', 'Temperatura controllata'),
('ORD-2026-003', 11, 'Controllo Atmosfera', 'Vuoto Camera', 'Verifica livello vuoto', 0.00001, 0.00001, 0.00000, 0.00005, 'mbar', 'PASS', 'CRITICAL', 'QC-009', 'Dott.ssa Elena Rossi', '2026-01-27 10:00:00', 'Vuoto ottimale');

-- Quality checks for ORD-2026-003, Step 2 (Colata e Raffreddamento - COMPLETED)
INSERT INTO quality_checks (ref_order, step_id, check_type, check_parameter, check_description, measured_value, target_value, tolerance_min, tolerance_max, unit_of_measure, result, severity, inspector_id, inspector_name, check_timestamp, notes, corrective_action) VALUES
('ORD-2026-003', 12, 'Controllo Visivo', 'Difetti Colata', 'Ispezione visiva getti', NULL, NULL, NULL, NULL, NULL, 'PASS', 'CRITICAL', 'QC-010', 'Ing. Roberto Blu', '2026-01-29 22:00:00', '19 pezzi conformi', NULL),
('ORD-2026-003', 12, 'Controllo Visivo', 'Difetti Colata', 'Ispezione visiva getti - Pezzo difettoso', NULL, NULL, NULL, NULL, NULL, 'FAIL', 'CRITICAL', 'QC-010', 'Ing. Roberto Blu', '2026-01-29 22:30:00', 'Un pezzo con porosità superficiale', 'Pezzo scartato'),
('ORD-2026-003', 12, 'Controllo Dimensionale', 'Ritiro Colata', 'Misura ritiro dopo raffreddamento', 1.8, 2.0, 1.5, 2.5, '%', 'PASS', 'NORMAL', 'QC-010', 'Ing. Roberto Blu', '2026-01-29 23:00:00', 'Ritiro entro limiti');

-- Quality checks for ORD-2026-003, Step 3 (Lavorazione Pale Turbina - COMPLETED)
INSERT INTO quality_checks (ref_order, step_id, check_type, check_parameter, check_description, measured_value, target_value, tolerance_min, tolerance_max, unit_of_measure, result, severity, inspector_id, inspector_name, check_timestamp, notes) VALUES
('ORD-2026-003', 13, 'Controllo Dimensionale', 'Profilo Pala', 'Scansione 3D profilo aerodinamico', NULL, NULL, NULL, NULL, NULL, 'PASS', 'CRITICAL', 'QC-011', 'Ing. Silvia Viola', '2026-02-02 16:00:00', 'Profilo conforme CAD entro 0.01mm'),
('ORD-2026-003', 13, 'Controllo Rugosità', 'Ra Profilo', 'Misura rugosità profilo aerodinamico', 0.4, 0.4, 0.0, 0.6, 'μm', 'PASS', 'HIGH', 'QC-011', 'Ing. Silvia Viola', '2026-02-02 16:30:00', 'Finitura superficiale eccellente'),
('ORD-2026-003', 13, 'Controllo Geometrico', 'Twist Angle', 'Misura angolo di torsione pala', 28.5, 28.5, 28.3, 28.7, 'gradi', 'PASS', 'CRITICAL', 'QC-011', 'Ing. Silvia Viola', '2026-02-02 17:00:00', 'Angolo preciso');

-- Quality checks for ORD-2026-003, Step 4 (Bilanciatura Dinamica - IN_PROGRESS)
INSERT INTO quality_checks (ref_order, step_id, check_type, check_parameter, check_description, measured_value, target_value, tolerance_min, tolerance_max, unit_of_measure, result, severity, inspector_id, inspector_name, check_timestamp, notes) VALUES
('ORD-2026-003', 14, 'Controllo Bilanciatura', 'Sbilanciamento Statico', 'Misura sbilanciamento statico', 0.5, 0.0, 0.0, 1.0, 'g·mm', 'PASS', 'CRITICAL', 'QC-012', 'Tec. Giovanni Arancio', '2026-02-03 12:00:00', 'Primi 8 pezzi bilanciati'),
('ORD-2026-003', 14, 'Controllo Bilanciatura', 'Sbilanciamento Dinamico', 'Misura sbilanciamento dinamico', 0.8, 0.0, 0.0, 1.5, 'g·mm', 'PASS', 'CRITICAL', 'QC-012', 'Tec. Giovanni Arancio', '2026-02-03 12:30:00', 'Bilanciatura dinamica OK');

-- Quality checks for ORD-2026-004, Step 2 (Assemblaggio Struttura Satellitare - COMPLETED)
INSERT INTO quality_checks (ref_order, step_id, check_type, check_parameter, check_description, measured_value, target_value, tolerance_min, tolerance_max, unit_of_measure, result, severity, inspector_id, inspector_name, check_timestamp, notes) VALUES
('ORD-2026-004', 16, 'Controllo Dimensionale', 'Allineamento Struttura', 'Verifica allineamento assi strutturali', 0.02, 0.00, 0.00, 0.05, 'mm', 'PASS', 'CRITICAL', 'QC-013', 'Ing. Alessandro Grigio', '2026-02-05 16:00:00', 'Allineamento perfetto'),
('ORD-2026-004', 16, 'Controllo Coppia', 'Coppia Serraggio Bulloni', 'Verifica coppia di serraggio', 25.2, 25.0, 24.5, 25.5, 'N·m', 'PASS', 'HIGH', 'QC-013', 'Ing. Alessandro Grigio', '2026-02-05 16:30:00', 'Tutti i bulloni serrati correttamente'),
('ORD-2026-004', 16, 'Controllo Pulizia', 'Contaminazione Particolato', 'Misura livello particolato', 50.0, 0.0, 0.0, 100.0, 'particelle/m³', 'PASS', 'CRITICAL', 'QC-013', 'Ing. Alessandro Grigio', '2026-02-05 17:00:00', 'Ambiente cleanroom conforme');

-- Quality checks for ORD-2026-004, Step 3 (Integrazione Elettronica - IN_PROGRESS)
INSERT INTO quality_checks (ref_order, step_id, check_type, check_parameter, check_description, measured_value, target_value, tolerance_min, tolerance_max, unit_of_measure, result, severity, inspector_id, inspector_name, check_timestamp, notes) VALUES
('ORD-2026-004', 17, 'Test Elettrico', 'Continuità Circuiti', 'Verifica continuità collegamenti', NULL, NULL, NULL, NULL, NULL, 'PASS', 'CRITICAL', 'QC-014', 'Ing. Beatrice Celeste', '2026-02-06 14:00:00', 'Primi 4 moduli: continuità OK'),
('ORD-2026-004', 17, 'Test Elettrico', 'Isolamento', 'Misura resistenza isolamento', 1000.0, 1000.0, 500.0, 10000.0, 'MΩ', 'PASS', 'CRITICAL', 'QC-014', 'Ing. Beatrice Celeste', '2026-02-06 14:30:00', 'Isolamento eccellente'),
('ORD-2026-004', 17, 'Test Funzionale', 'Power-On Test', 'Test accensione sottosistemi', NULL, NULL, NULL, NULL, NULL, 'PASS', 'HIGH', 'QC-014', 'Ing. Beatrice Celeste', '2026-02-06 15:00:00', 'Tutti i sottosistemi si accendono correttamente');

-- Quality checks for ORD-2026-006 (COMPLETED order)
INSERT INTO quality_checks (ref_order, step_id, check_type, check_parameter, check_description, measured_value, target_value, tolerance_min, tolerance_max, unit_of_measure, result, severity, inspector_id, inspector_name, check_timestamp, notes) VALUES
('ORD-2026-006', 18, 'Controllo Finale', 'Ispezione Visiva Finale', 'Controllo finale pre-spedizione', NULL, NULL, NULL, NULL, NULL, 'PASS', 'NORMAL', 'QC-015', 'Tec. Davide Turchese', '2026-01-15 16:00:00', 'Tutti i componenti conformi'),
('ORD-2026-006', 19, 'Test Funzionale', 'Test Operativo', 'Verifica funzionamento operativo', NULL, NULL, NULL, NULL, NULL, 'PASS', 'HIGH', 'QC-015', 'Tec. Davide Turchese', '2026-01-15 16:30:00', 'Funzionamento corretto'),
('ORD-2026-006', 20, 'Controllo Documentazione', 'Completezza Documenti', 'Verifica documentazione tecnica', NULL, NULL, NULL, NULL, NULL, 'PASS', 'NORMAL', 'QC-015', 'Tec. Davide Turchese', '2026-01-15 17:00:00', 'Documentazione completa');

-- Quality checks for ORD-2026-014, Step 2 (Stratificazione Compositi - COMPLETED)
INSERT INTO quality_checks (ref_order, step_id, check_type, check_parameter, check_description, measured_value, target_value, tolerance_min, tolerance_max, unit_of_measure, result, severity, inspector_id, inspector_name, check_timestamp, notes, corrective_action) VALUES
('ORD-2026-014', 22, 'Controllo Visivo', 'Orientamento Fibre', 'Verifica orientamento strati fibra carbonio', NULL, NULL, NULL, NULL, NULL, 'PASS', 'CRITICAL', 'QC-016', 'Ing. Cristina Magenta', '2026-02-11 16:00:00', '29 pezzi con orientamento corretto', NULL),
('ORD-2026-014', 22, 'Controllo Visivo', 'Bolle d''Aria', 'Verifica assenza bolle d''aria', NULL, NULL, NULL, NULL, NULL, 'FAIL', 'HIGH', 'QC-016', 'Ing. Cristina Magenta', '2026-02-11 16:30:00', 'Un pezzo con delaminazione', 'Pezzo scartato'),
('ORD-2026-014', 22, 'Controllo Spessore', 'Spessore Laminato', 'Misura spessore laminato', 5.02, 5.00, 4.95, 5.05, 'mm', 'PASS', 'HIGH', 'QC-016', 'Ing. Cristina Magenta', '2026-02-11 17:00:00', 'Spessore uniforme');

-- Quality checks for ORD-2026-014, Step 3 (Autoclave - COMPLETED)
INSERT INTO quality_checks (ref_order, step_id, check_type, check_parameter, check_description, measured_value, target_value, tolerance_min, tolerance_max, unit_of_measure, result, severity, inspector_id, inspector_name, check_timestamp, notes) VALUES
('ORD-2026-014', 23, 'Controllo Processo', 'Temperatura Autoclave', 'Monitoraggio temperatura ciclo', 180.0, 180.0, 178.0, 182.0, '°C', 'PASS', 'CRITICAL', 'QC-017', 'Tec. Emanuele Corallo', '2026-02-12 20:00:00', 'Temperatura stabile'),
('ORD-2026-014', 23, 'Controllo Processo', 'Pressione Autoclave', 'Monitoraggio pressione ciclo', 6.0, 6.0, 5.8, 6.2, 'bar', 'PASS', 'CRITICAL', 'QC-017', 'Tec. Emanuele Corallo', '2026-02-12 20:00:00', 'Pressione costante'),
('ORD-2026-014', 23, 'Controllo Visivo', 'Polimerizzazione', 'Verifica completa polimerizzazione', NULL, NULL, NULL, NULL, NULL, 'PASS', 'CRITICAL', 'QC-017', 'Tec. Emanuele Corallo', '2026-02-13 08:00:00', 'Polimerizzazione completa');

-- Quality checks for ORD-2026-014, Step 4 (Rifinitura - IN_PROGRESS)
INSERT INTO quality_checks (ref_order, step_id, check_type, check_parameter, check_description, measured_value, target_value, tolerance_min, tolerance_max, unit_of_measure, result, severity, inspector_id, inspector_name, check_timestamp, notes) VALUES
('ORD-2026-014', 24, 'Controllo Dimensionale', 'Dimensioni Finali', 'Verifica dimensioni post-rifinitura', NULL, NULL, NULL, NULL, NULL, 'PASS', 'HIGH', 'QC-018', 'Geom. Filippo Ambra', '2026-02-14 14:00:00', 'Primi 12 pezzi conformi'),
('ORD-2026-014', 24, 'Controllo Rugosità', 'Finitura Superficie', 'Misura rugosità superficiale', 1.2, 1.0, 0.0, 1.5, 'μm', 'PASS', 'NORMAL', 'QC-018', 'Geom. Filippo Ambra', '2026-02-14 14:30:00', 'Finitura accettabile');

-- Quality checks for ORD-2026-020, Step 2 (Elettroerosione - COMPLETED)
INSERT INTO quality_checks (ref_order, step_id, check_type, check_parameter, check_description, measured_value, target_value, tolerance_min, tolerance_max, unit_of_measure, result, severity, inspector_id, inspector_name, check_timestamp, notes, corrective_action) VALUES
('ORD-2026-020', 27, 'Controllo Dimensionale', 'Profilo EDM', 'Verifica profilo dopo EDM', NULL, NULL, NULL, NULL, NULL, 'PASS', 'CRITICAL', 'QC-019', 'Ing. Giulia Giada', '2026-02-28 16:00:00', '14 pezzi conformi', NULL),
('ORD-2026-020', 27, 'Controllo Visivo', 'Cricche EDM', 'Verifica assenza cricche da EDM', NULL, NULL, NULL, NULL, NULL, 'FAIL', 'CRITICAL', 'QC-019', 'Ing. Giulia Giada', '2026-02-28 16:30:00', 'Un pezzo con micro-cricche', 'Pezzo scartato'),
('ORD-2026-020', 27, 'Controllo Rugosità', 'Ra Post-EDM', 'Misura rugosità dopo EDM', 3.2, 3.0, 0.0, 4.0, 'μm', 'PASS', 'NORMAL', 'QC-019', 'Ing. Giulia Giada', '2026-02-28 17:00:00', 'Rugosità accettabile');

-- Quality checks for ORD-2026-020, Step 3 (Foratura Raffreddamento - IN_PROGRESS)
INSERT INTO quality_checks (ref_order, step_id, check_type, check_parameter, check_description, measured_value, target_value, tolerance_min, tolerance_max, unit_of_measure, result, severity, inspector_id, inspector_name, check_timestamp, notes) VALUES
('ORD-2026-020', 28, 'Controllo Dimensionale', 'Diametro Fori', 'Misura diametro fori raffreddamento', 0.502, 0.500, 0.495, 0.505, 'mm', 'PASS', 'CRITICAL', 'QC-020', 'Tec. Irene Tormalina', '2026-03-01 14:00:00', 'Primi 5 pezzi: fori conformi'),
('ORD-2026-020', 28, 'Controllo Geometrico', 'Angolo Fori', 'Verifica angolo inclinazione fori', 15.1, 15.0, 14.8, 15.2, 'gradi', 'PASS', 'CRITICAL', 'QC-020', 'Tec. Irene Tormalina', '2026-03-01 14:30:00', 'Angolazione precisa'),
('ORD-2026-020', 28, 'Test Flusso', 'Portata Aria', 'Test portata aria canali raffreddamento', 2.1, 2.0, 1.8, 2.2, 'l/min', 'PASS', 'HIGH', 'QC-020', 'Tec. Irene Tormalina', '2026-03-01 15:00:00', 'Flusso ottimale');

-- ============================================================================
-- Verify data insertion
-- ============================================================================

-- Display summary of quality checks by result
SELECT 
    result,
    severity,
    COUNT(*) AS check_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM quality_checks
GROUP BY result, severity
ORDER BY 
    CASE result
        WHEN 'PASS' THEN 1
        WHEN 'CONDITIONAL_PASS' THEN 2
        WHEN 'PENDING' THEN 3
        WHEN 'FAIL' THEN 4
        WHEN 'NOT_APPLICABLE' THEN 5
        ELSE 6
    END,
    CASE severity
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'NORMAL' THEN 3
        WHEN 'LOW' THEN 4
        ELSE 5
    END;

-- Display quality checks by order
SELECT 
    qc.ref_order,
    o.order_num,
    o.status AS order_status,
    COUNT(qc.check_id) AS total_checks,
    COUNT(CASE WHEN qc.result = 'PASS' THEN 1 END) AS passed_checks,
    COUNT(CASE WHEN qc.result = 'FAIL' THEN 1 END) AS failed_checks,
    COUNT(CASE WHEN qc.result = 'PENDING' THEN 1 END) AS pending_checks,
    ROUND(COUNT(CASE WHEN qc.result = 'PASS' THEN 1 END) * 100.0 / NULLIF(COUNT(CASE WHEN qc.result IN ('PASS', 'FAIL') THEN 1 END), 0), 2) AS pass_rate
FROM quality_checks qc
JOIN orders o ON qc.ref_order = o.order_id
GROUP BY qc.ref_order, o.order_num, o.status
ORDER BY qc.ref_order;

-- Display quality checks by check type
SELECT 
    check_type,
    COUNT(*) AS check_count,
    COUNT(CASE WHEN result = 'PASS' THEN 1 END) AS passed,
    COUNT(CASE WHEN result = 'FAIL' THEN 1 END) AS failed,
    ROUND(COUNT(CASE WHEN result = 'PASS' THEN 1 END) * 100.0 / NULLIF(COUNT(CASE WHEN result IN ('PASS', 'FAIL') THEN 1 END), 0), 2) AS pass_rate
FROM quality_checks
GROUP BY check_type
ORDER BY check_count DESC;

-- Display overall statistics
SELECT 
    COUNT(DISTINCT ref_order) AS orders_with_checks,
    COUNT(DISTINCT step_id) AS steps_with_checks,
    COUNT(*) AS total_checks,
    COUNT(DISTINCT inspector_id) AS active_inspectors,
    COUNT(CASE WHEN result = 'PASS' THEN 1 END) AS total_passed,
    COUNT(CASE WHEN result = 'FAIL' THEN 1 END) AS total_failed,
    COUNT(CASE WHEN result = 'PENDING' THEN 1 END) AS total_pending,
    ROUND(COUNT(CASE WHEN result = 'PASS' THEN 1 END) * 100.0 / NULLIF(COUNT(CASE WHEN result IN ('PASS', 'FAIL') THEN 1 END), 0), 2) AS overall_pass_rate
FROM quality_checks;

-- Display critical failures requiring attention
SELECT 
    qc.ref_order,
    o.order_num,
    ps.step_name,
    qc.check_type,
    qc.check_parameter,
    qc.result,
    qc.severity,
    qc.notes,
    qc.corrective_action,
    qc.inspector_name,
    qc.check_timestamp
FROM quality_checks qc
JOIN orders o ON qc.ref_order = o.order_id
JOIN production_steps ps ON qc.step_id = ps.step_id
WHERE qc.result = 'FAIL' AND qc.severity IN ('CRITICAL', 'HIGH')
ORDER BY qc.check_timestamp DESC;

-- Made with Bob
