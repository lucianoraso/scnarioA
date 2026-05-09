# QMS Service - Quality Management System Mock Service

Mock service per il sistema di gestione qualità (QMS) utilizzato nella demo IBM Cloud Pak for Integration - Scenario A.

## 📋 Descrizione

Il servizio QMS fornisce API REST per la gestione dei controlli qualità associati agli step di produzione. Simula un sistema reale di Quality Management con dati di test realistici per l'industria aerospaziale/difesa.

## 🚀 Features

- ✅ API REST per controlli qualità
- ✅ OAuth2 Bearer Token authentication
- ✅ Rate limiting e security headers
- ✅ Logging strutturato con Winston
- ✅ Health check e readiness probe
- ✅ Simulazione latenza ed errori per testing
- ✅ Containerizzazione Docker
- ✅ Graceful shutdown
- ✅ Connection pooling PostgreSQL

## 📊 Endpoints API

### Base URL
```
http://localhost:3003/api/v1
```

### Endpoints Principali

#### 1. Get Quality Checks by Step IDs (per ACE orchestration)
```http
GET /quality-checks?stepIds=1,2,3
Authorization: Bearer <token>
```

**Response:**
```json
{
  "data": {
    "stepIds": [1, 2, 3],
    "checks": [
      {
        "checkId": 1,
        "stepId": 1,
        "checkType": "Verifica Materiale",
        "result": "PASS",
        "severity": "NORMAL",
        "inspectorName": "Ing. Carlo Ferretti",
        "checkTimestamp": "2026-01-16T10:00:00.000Z",
        "notes": "Materiale conforme alle specifiche"
      }
    ],
    "totalChecks": 15,
    "passedChecks": 13,
    "failedChecks": 2,
    "pendingChecks": 0
  },
  "metadata": {
    "timestamp": "2026-05-08T14:30:00.000Z",
    "responseTime": "52ms",
    "source": "QMS"
  }
}
```

#### 2. Get Quality Check by ID
```http
GET /quality-checks/1
Authorization: Bearer <token>
```

#### 3. Get All Quality Checks (con filtri)
```http
GET /quality-checks?result=FAIL&severity=CRITICAL&limit=50
Authorization: Bearer <token>
```

#### 4. Get Quality Statistics
```http
GET /quality-checks/statistics?startDate=2026-01-01&endDate=2026-12-31
Authorization: Bearer <token>
```

### Endpoints di Sistema

#### Health Check
```http
GET /health
```

#### Readiness Check
```http
GET /ready
```

#### Metrics
```http
GET /metrics
```

## 🗄️ Database Schema

### Tabella: quality_checks

| Campo | Tipo | Descrizione |
|-------|------|-------------|
| check_id | SERIAL PRIMARY KEY | ID univoco controllo |
| step_id | INTEGER | ID step produzione (FK) |
| ref_order | VARCHAR(50) | Riferimento ordine |
| check_type | VARCHAR(100) | Tipo controllo |
| result | VARCHAR(20) | Risultato (PASS/FAIL/PENDING) |
| severity | VARCHAR(20) | Severità (CRITICAL/HIGH/NORMAL/LOW) |
| inspector_name | VARCHAR(100) | Nome ispettore |
| check_timestamp | TIMESTAMP | Data/ora controllo |
| notes | TEXT | Note aggiuntive |

## 🛠️ Setup e Installazione

### Prerequisiti
- Node.js 18+
- PostgreSQL 13+
- npm o yarn

### 1. Clona e installa dipendenze
```bash
cd backend-mocks/qms-service
npm install
```

### 2. Configura environment
```bash
cp .env.example .env
# Modifica .env con le tue configurazioni
```

### 3. Setup database
```bash
# Esegui gli script SQL in ordine
psql -U postgres -d production_orders -f ../../database/init-scripts/01-create-schemas.sql
psql -U postgres -d production_orders -f ../../database/init-scripts/02-seed-orders.sql
psql -U postgres -d production_orders -f ../../database/init-scripts/03-seed-production-steps.sql
psql -U postgres -d production_orders -f ../../database/init-scripts/04-seed-quality-checks.sql
```

### 4. Avvia il servizio
```bash
npm start
```

Il servizio sarà disponibile su `http://localhost:3003`

## 🐳 Docker

### Build immagine
```bash
docker build -t qms-service:1.0.0 .
```

### Run container
```bash
docker run -d \
  -p 3003:3003 \
  -e DB_HOST=host.docker.internal \
  -e DB_PASSWORD=postgres \
  --name qms-service \
  qms-service:1.0.0
```

## ⚙️ Configurazione

### Variabili Environment

| Variabile | Default | Descrizione |
|-----------|---------|-------------|
| `NODE_ENV` | development | Ambiente (development/production) |
| `PORT` | 3003 | Porta server |
| `DB_HOST` | localhost | Host PostgreSQL |
| `DB_PORT` | 5432 | Porta PostgreSQL |
| `DB_NAME` | production_orders | Nome database |
| `DB_USER` | postgres | Username database |
| `DB_PASSWORD` | postgres | Password database |
| `AUTH_ENABLED` | false | Abilita autenticazione OAuth2 |
| `JWT_SECRET` | qms-secret-key | Chiave segreta JWT |
| `LOG_LEVEL` | info | Livello logging |
| `SIMULATE_LATENCY` | false | Simula latenza per testing |
| `SIMULATE_ERRORS` | false | Simula errori per testing |

### Autenticazione OAuth2

Per abilitare l'autenticazione:
```bash
AUTH_ENABLED=true
JWT_SECRET=your-secret-key
JWT_ISSUER=qms-service
JWT_AUDIENCE=qms-api
```

### Scope Richiesti
- `qms:read` - Lettura controlli qualità
- `qms:write` - Scrittura controlli qualità (futuro)

## 🧪 Testing

### Test con cURL

#### Senza autenticazione (AUTH_ENABLED=false)
```bash
# Get quality checks by step IDs
curl "http://localhost:3003/api/v1/quality-checks?stepIds=1,2,3"

# Get specific quality check
curl "http://localhost:3003/api/v1/quality-checks/1"

# Get statistics
curl "http://localhost:3003/api/v1/quality-checks/statistics"

# Health check
curl "http://localhost:3003/health"
```

#### Con autenticazione (AUTH_ENABLED=true)
```bash
# Genera token JWT (esempio)
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# Chiamata autenticata
curl -H "Authorization: Bearer $TOKEN" \
     "http://localhost:3003/api/v1/quality-checks?stepIds=1,2,3"
```

### Simulazione Errori
```bash
# Abilita simulazione errori (5% rate)
export SIMULATE_ERRORS=true
export ERROR_RATE=0.05

# Abilita simulazione latenza (50-200ms)
export SIMULATE_LATENCY=true
export MIN_LATENCY_MS=50
export MAX_LATENCY_MS=200
```

## 📊 Dati di Test

Il servizio include 80+ controlli qualità di test con:

- **Tipi controlli:** Verifica Materiale, Controllo Dimensionale, Test Funzionale, Ispezione Visiva, Test Prestazioni
- **Risultati:** PASS (75%), FAIL (20%), PENDING (5%)
- **Severità:** CRITICAL, HIGH, NORMAL, LOW
- **Ispettori:** 8 ispettori diversi
- **Ordini:** Collegati a 30 ordini di produzione
- **Step:** Collegati a 60+ step di produzione

## 🔧 Integrazione con ACE

Il servizio è progettato per integrarsi con IBM App Connect Enterprise:

### Endpoint per ACE Orchestration
```http
GET /api/v1/quality-checks?stepIds={stepIds}
```

### Field Mapping
Il servizio usa naming convention specifiche che richiedono mapping in ACE:
- `checkId` → `qualityCheckId`
- `stepId` → `productionStepId`
- `ref_order` → `orderId`

### Error Handling
- Status 200: Successo
- Status 404: Controlli non trovati
- Status 500: Errore interno
- Status 503: Database non disponibile

## 📝 Logging

Il servizio usa Winston per logging strutturato:

```json
{
  "timestamp": "2026-05-08 16:30:00:123",
  "level": "info",
  "message": "Request completed",
  "method": "GET",
  "path": "/api/v1/quality-checks",
  "statusCode": 200,
  "duration": "52ms",
  "requestId": "qms-1683556200123-abc123"
}
```

### Log Files (produzione)
- `logs/qms-error.log` - Solo errori
- `logs/qms-combined.log` - Tutti i log

## 🚨 Monitoring

### Health Checks
- `/health` - Stato generale servizio
- `/ready` - Readiness per Kubernetes
- `/metrics` - Metriche base (memoria, CPU, uptime)

### Kubernetes Probes
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 3003
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: 3003
  initialDelaySeconds: 5
  periodSeconds: 5
```

## 🔒 Security

- ✅ Helmet security headers
- ✅ CORS configurabile
- ✅ Rate limiting (100 req/min default)
- ✅ OAuth2 JWT validation
- ✅ Input validation
- ✅ Non-root Docker user
- ✅ Secrets via environment variables

## 📈 Performance

- ✅ Connection pooling PostgreSQL (max 20 connessioni)
- ✅ Compression middleware
- ✅ Graceful shutdown
- ✅ Request timeout handling
- ✅ Memory leak prevention

## 🐛 Troubleshooting

### Problemi Comuni

#### 1. Errore connessione database
```bash
# Verifica connessione
curl http://localhost:3003/ready

# Check logs
docker logs qms-service
```

#### 2. Errore autenticazione
```bash
# Verifica token JWT
# Controlla AUTH_ENABLED=false per testing
```

#### 3. Performance lente
```bash
# Disabilita simulazione latenza
export SIMULATE_LATENCY=false
```

## 📚 Riferimenti

- [IBM App Connect Enterprise](https://www.ibm.com/products/app-connect)
- [IBM API Connect](https://www.ibm.com/products/api-connect)
- [Node.js Express](https://expressjs.com/)
- [PostgreSQL](https://www.postgresql.org/)
- [Winston Logging](https://github.com/winstonjs/winston)

---

**Versione:** 1.0.0  
**Ultima modifica:** 2026-05-08  
**Maintainer:** IBM Cloud Pak for Integration Team