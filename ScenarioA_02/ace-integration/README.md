# IBM App Connect Enterprise - Order Orchestration Integration

Implementazione ACE per l'orchestrazione delle chiamate ai sistemi ERP, MES e QMS nello Scenario A.

## 📋 Panoramica

Questo progetto ACE implementa un pattern di orchestrazione sincrona che:
1. Riceve richiesta HTTP per un orderId
2. Chiama sequenzialmente ERP → MES → QMS
3. Trasforma i dati nel modello canonico (VETRO pattern)
4. Gestisce errori con retry e circuit breaker
5. Restituisce risposta consolidata

## 🏗️ Architettura

```
┌─────────────────────────────────────────────────────────────┐
│                  OrderOrchestrationFlow                      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  HTTPInput → Validate → CallERP → CallMES → CallQMS →       │
│              Request      ↓          ↓         ↓             │
│                        Transform  Transform Transform        │
│                           ↓          ↓         ↓             │
│                        Canonical Model Assembly              │
│                                  ↓                            │
│                           HTTPReply ← BuildResponse          │
│                                                               │
│  TryCatch → ErrorHandler → BuildErrorResponse → HTTPReply   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Struttura Progetto

```
ace-integration/
├── OrderOrchestrationApp/
│   └── application.descriptor          ✅ Application descriptor
│
├── OrderOrchestrationLib/
│   ├── OrderTransformation.esql        ✅ Trasformazioni VETRO
│   ├── ErrorHandling.esql              ✅ Retry e Circuit Breaker
│   ├── OrderOrchestrationFlow.msgflow  ⏳ Message flow principale
│   ├── ERP_CallSubflow.subflow         ⏳ Subflow chiamata ERP
│   ├── MES_CallSubflow.subflow         ⏳ Subflow chiamata MES
│   ├── QMS_CallSubflow.subflow         ⏳ Subflow chiamata QMS
│   └── ErrorHandlingSubflow.subflow    ⏳ Subflow gestione errori
│
├── policies/
│   ├── HTTPConnectorPolicy.policyxml   ⏳ Policy HTTP connector
│   └── RetryPolicy.policyxml           ⏳ Policy retry
│
├── server.conf.yaml                    ⏳ Configurazione server
└── README.md                           ✅ Questo file
```

## 🔧 Moduli ESQL Implementati

### 1. OrderTransformation.esql ✅

**Funzioni principali:**

| Funzione | Scopo |
|----------|-------|
| `ValidateRequest()` | Valida orderId in input |
| `BuildERPUrl()` | Costruisce URL chiamata ERP |
| `BuildMESUrl()` | Costruisce URL chiamata MES |
| `BuildQMSUrl()` | Costruisce URL chiamata QMS |
| `ExtractStepIds()` | Estrae stepIds da risposta MES |
| `TransformERPData()` | Trasforma dati ERP → Canonical |
| `TransformMESData()` | Trasforma dati MES → Canonical |
| `TransformQMSData()` | Trasforma dati QMS → Canonical |
| `BuildConsolidatedResponse()` | Costruisce risposta finale |
| `BuildErrorResponse()` | Costruisce messaggio errore |
| `HandlePartialFailure()` | Gestisce fallimenti parziali |

**Pattern VETRO:**
- **V**alidate: Validazione input request
- **E**nrich: Arricchimento con dati backend
- **T**ransform: Trasformazione in modello canonico
- **R**oute: Routing logico (non usato)
- **O**perate: Costruzione response finale

### 2. ErrorHandling.esql ✅

**Funzioni principali:**

| Funzione | Scopo |
|----------|-------|
| `GetRetryConfig()` | Configurazione retry policy |
| `IsRetriableError()` | Determina se errore è retriable |
| `CalculateRetryDelay()` | Calcola delay exponential backoff |
| `CallWithRetry()` | Esegue chiamata con retry logic |
| `GetCircuitBreakerState()` | Stato circuit breaker |
| `RecordCircuitBreakerSuccess()` | Registra successo |
| `RecordCircuitBreakerFailure()` | Registra fallimento |
| `CanProceedWithCall()` | Verifica se chiamata può procedere |
| `BuildCircuitBreakerErrorResponse()` | Errore circuit breaker |
| `MapHTTPErrorToMessage()` | Mappa HTTP code → messaggio |

**Retry Policy:**
- Max retries: 3 (configurabile)
- Initial delay: 1000ms
- Backoff multiplier: 2.0 (exponential)
- Max delay: 30000ms

**Circuit Breaker:**
- Threshold: 5 failures
- Timeout: 60 secondi
- Stati: CLOSED, OPEN, HALF_OPEN

## 🎯 Come Creare i Message Flow in ACE Toolkit

### Prerequisiti

1. **IBM App Connect Enterprise Toolkit 13** installato
2. Workspace ACE configurato
3. Accesso ai backend services (locale o OpenShift)

### Step 1: Creare Application e Library

```bash
# In ACE Toolkit
1. File → New → Application
   - Name: OrderOrchestrationApp
   - Location: ace-integration/

2. File → New → Library
   - Name: OrderOrchestrationLib
   - Location: ace-integration/

3. Associa Library ad Application
   - Right-click su OrderOrchestrationApp
   - Manage Library Dependencies
   - Add: OrderOrchestrationLib
```

### Step 2: Importare Moduli ESQL

```bash
# Copia i file ESQL nella library
1. Copia OrderTransformation.esql in OrderOrchestrationLib/
2. Copia ErrorHandling.esql in OrderOrchestrationLib/
3. Right-click su Library → Refresh
4. Verifica che i moduli siano compilati senza errori
```

### Step 3: Creare Message Flow Principale

#### OrderOrchestrationFlow.msgflow

**Nodi da aggiungere:**

1. **HTTPInput**
   - Path: `/api/v1/orders/*`
   - Method: GET
   - Parse timing: On Demand

2. **Compute (ValidateRequest)**
   ```esql
   CREATE COMPUTE MODULE ValidateRequest
   CREATE FUNCTION Main() RETURNS BOOLEAN
   BEGIN
       DECLARE isValid BOOLEAN;
       DECLARE errorMsg CHARACTER;
       
       -- Estrai orderId dal path
       DECLARE orderId CHARACTER;
       SET orderId = InputLocalEnvironment.HTTP.Input.Path.Segment[4];
       
       -- Valida usando funzione del modulo
       CALL com.ibm.scenario.order.ValidateRequest(
           InputRoot, isValid, errorMsg
       );
       
       IF NOT isValid THEN
           -- Propaga errore
           SET OutputRoot.JSON.Data.error.code = 'VALIDATION_ERROR';
           SET OutputRoot.JSON.Data.error.message = errorMsg;
           PROPAGATE TO TERMINAL 'out1' DELETE NONE;
           RETURN FALSE;
       END IF;
       
       -- Salva orderId in environment
       SET Environment.Variables.orderId = orderId;
       
       RETURN TRUE;
   END;
   ```

3. **Compute (CallERP)**
   ```esql
   CREATE COMPUTE MODULE CallERP
   CREATE FUNCTION Main() RETURNS BOOLEAN
   BEGIN
       DECLARE orderId CHARACTER Environment.Variables.orderId;
       DECLARE url CHARACTER;
       
       -- Costruisci URL
       SET url = com.ibm.scenario.order.BuildERPUrl(orderId);
       
       -- Prepara chiamata HTTP
       SET OutputLocalEnvironment.Destination.HTTP.RequestURL = url;
       SET OutputLocalEnvironment.Destination.HTTP.RequestLine.Method = 'GET';
       
       -- Propaga token OAuth2 se presente
       IF EXISTS(InputRoot.HTTPInputHeader.Authorization[]) THEN
           SET OutputRoot.HTTPRequestHeader.Authorization = 
               InputRoot.HTTPInputHeader.Authorization;
       END IF;
       
       RETURN TRUE;
   END;
   ```

4. **HTTPRequest (ERPRequest)**
   - URL: Da LocalEnvironment
   - Method: GET
   - Timeout: 30 secondi
   - HTTP version: 1.1

5. **Compute (TransformERP)**
   ```esql
   CREATE COMPUTE MODULE TransformERP
   CREATE FUNCTION Main() RETURNS BOOLEAN
   BEGIN
       -- Salva risposta ERP
       SET Environment.Variables.ERPResponse = InputRoot.JSON.Data;
       
       -- Trasforma in modello canonico
       DECLARE canonicalOrder REFERENCE TO Environment.Variables.CanonicalOrder;
       CALL com.ibm.scenario.order.TransformERPData(
           InputRoot.JSON.Data,
           canonicalOrder
       );
       
       RETURN TRUE;
   END;
   ```

6. **Compute (CallMES)** - Simile a CallERP
7. **HTTPRequest (MESRequest)**
8. **Compute (TransformMES)**
9. **Compute (CallQMS)** - Usa ExtractStepIds()
10. **HTTPRequest (QMSRequest)**
11. **Compute (TransformQMS)**

12. **Compute (BuildResponse)**
    ```esql
    CREATE COMPUTE MODULE BuildResponse
    CREATE FUNCTION Main() RETURNS BOOLEAN
    BEGIN
        DECLARE finalResponse REFERENCE TO OutputRoot.JSON.Data;
        
        -- Costruisci risposta consolidata
        CALL com.ibm.scenario.order.BuildConsolidatedResponse(
            Environment.Variables.CanonicalOrder,
            finalResponse
        );
        
        -- Set HTTP headers
        SET OutputRoot.HTTPReplyHeader."Content-Type" = 'application/json';
        SET OutputRoot.HTTPReplyHeader."X-Response-Time" = 
            CAST((CURRENT_TIMESTAMP - Environment.Variables.StartTime) AS CHARACTER);
        
        RETURN TRUE;
    END;
    ```

13. **HTTPReply**

14. **TryCatch** - Avvolge tutto il flow
15. **Compute (ErrorHandler)** - Nel catch
16. **HTTPReply (ErrorReply)**

### Step 4: Creare Subflows

#### ERP_CallSubflow.subflow

```
Input → CheckCircuitBreaker → HTTPRequest → RecordSuccess → Output
          ↓ (OPEN)                ↓ (Error)
        BuildError            RetryLogic → RecordFailure
```

**Implementazione:**

1. **Input Terminal**
2. **Compute (CheckCircuitBreaker)**
   ```esql
   IF NOT com.ibm.scenario.error.CanProceedWithCall('ERP') THEN
       -- Circuit breaker aperto
       PROPAGATE TO TERMINAL 'failure';
       RETURN FALSE;
   END IF;
   ```

3. **HTTPRequest con Retry**
4. **Compute (RecordSuccess)**
   ```esql
   CALL com.ibm.scenario.error.RecordCircuitBreakerSuccess('ERP');
   ```

5. **Compute (RecordFailure)** - Nel catch
   ```esql
   CALL com.ibm.scenario.error.RecordCircuitBreakerFailure('ERP');
   ```

6. **Output Terminal**

#### MES_CallSubflow.subflow
Identico a ERP_CallSubflow, cambia solo il nome servizio

#### QMS_CallSubflow.subflow
Identico a ERP_CallSubflow, cambia solo il nome servizio

### Step 5: Configurare Policies

#### HTTPConnectorPolicy.policyxml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<policies>
  <policy policyType="HTTPConnector" policyName="BackendHTTPPolicy">
    <connection>
      <connectionTimeout>30</connectionTimeout>
      <socketTimeout>30</socketTimeout>
      <maxConnections>100</maxConnections>
      <maxConnectionsPerRoute>20</maxConnectionsPerRoute>
    </connection>
    <proxy>
      <useSystemProxy>false</useSystemProxy>
    </proxy>
  </policy>
</policies>
```

#### RetryPolicy.policyxml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<policies>
  <policy policyType="Retry" policyName="BackendRetryPolicy">
    <maxRetries>3</maxRetries>
    <retryInterval>1000</retryInterval>
    <retryIntervalMultiplier>2.0</retryIntervalMultiplier>
    <maxRetryInterval>30000</maxRetryInterval>
    <retriableHTTPCodes>408,429,500,502,503,504</retriableHTTPCodes>
  </policy>
</policies>
```

### Step 6: Configurare Integration Server

#### server.conf.yaml

```yaml
---
ServerConf:
  serverName: 'OrderOrchestrationServer'
  
  # HTTP Listener
  HTTPListener:
    port: 7800
    host: '0.0.0.0'
    
  # Resource Managers
  ResourceManagers:
    HTTPConnector:
      policies:
        - BackendHTTPPolicy
    
  # Environment Variables
  Environment:
    Variables:
      # Backend URLs
      ERP_SERVICE_URL: 'http://erp-service.scenario-a-demo.svc.cluster.local:3001'
      MES_SERVICE_URL: 'http://mes-service.scenario-a-demo.svc.cluster.local:3002'
      QMS_SERVICE_URL: 'http://qms-service.scenario-a-demo.svc.cluster.local:3003'
      
      # Retry Configuration
      MAX_RETRIES: 3
      RETRY_INITIAL_DELAY_MS: 1000
      RETRY_BACKOFF_MULTIPLIER: 2.0
      HTTP_TIMEOUT_SECONDS: 30
      
      # Circuit Breaker Configuration
      CIRCUIT_BREAKER_THRESHOLD: 5
      CIRCUIT_BREAKER_TIMEOUT_SECONDS: 60
      
  # Logging
  Logging:
    consoleLog: true
    consoleFormat: 'json'
    consoleLogLevel: 'info'
```

## 🧪 Testing Locale

### 1. Avvia Backend Services

```bash
# Avvia PostgreSQL
docker run -d -p 5432:5432 -e POSTGRES_PASSWORD=postgres postgres:13

# Inizializza database
psql -U postgres < database/init-scripts/*.sql

# Avvia servizi
cd backend-mocks/erp-service && npm start &
cd backend-mocks/mes-service && npm start &
cd backend-mocks/qms-service && npm start &
```

### 2. Avvia Integration Server

```bash
# In ACE Toolkit
1. Right-click su OrderOrchestrationApp
2. Deploy → New Integration Server
3. Start Integration Server
4. Verifica log: http://localhost:7600/
```

### 3. Test con cURL

```bash
# Test happy path
curl http://localhost:7800/api/v1/orders/ORD-2026-001

# Test ordine non esistente
curl http://localhost:7800/api/v1/orders/ORD-9999-999

# Test con autenticazione
curl -H "Authorization: Bearer <token>" \
     http://localhost:7800/api/v1/orders/ORD-2026-001
```

### 4. Test Error Scenarios

```bash
# Simula errore ERP (ferma servizio)
# Verifica retry e circuit breaker

# Simula timeout
# Verifica timeout handling

# Simula errore parziale
# Verifica partial response
```

## 📦 Creazione BAR File

### Step 1: Prepare for Deployment

```bash
# In ACE Toolkit
1. File → New → BAR file
   - Name: OrderOrchestration.bar
   - Location: ace-integration/

2. Add resources:
   - OrderOrchestrationApp
   - OrderOrchestrationLib
   - Policies

3. Build and Save
```

### Step 2: Configure BAR File

```bash
# Configura properties per environment
1. Open BAR file editor
2. Configure → Properties
3. Set environment-specific values:
   - Backend URLs
   - Timeouts
   - Retry settings
```

### Step 3: Deploy to OpenShift

```bash
# Usa IBM Cloud Pak for Integration Operator
oc apply -f ace-integration-server.yaml
```

## 🚀 Deployment OpenShift

### Integration Server Custom Resource

```yaml
apiVersion: appconnect.ibm.com/v1beta1
kind: IntegrationServer
metadata:
  name: order-orchestration-server
  namespace: cp4i
spec:
  version: 13.0.1
  license:
    accept: true
    license: L-MJTK-WUU8HE
    use: CloudPakForIntegrationNonProduction
  pod:
    containers:
      runtime:
        resources:
          requests:
            cpu: 500m
            memory: 512Mi
          limits:
            cpu: 2000m
            memory: 2Gi
  replicas: 2
  router:
    timeout: 120s
  service:
    endpointType: http
  configurations:
    - order-orchestration-config
  barURL: >-
    https://github.com/your-repo/ace-integration/releases/download/v1.0.0/OrderOrchestration.bar
```

## 📊 Monitoring e Observability

### Metrics Endpoint

```bash
# ACE espone metriche Prometheus
curl http://localhost:7800/metrics
```

### Log Aggregation

```bash
# View logs in OpenShift
oc logs -f deployment/order-orchestration-server -n cp4i
```

### Distributed Tracing

```bash
# Configura OpenTelemetry in server.conf.yaml
Tracing:
  enabled: true
  endpoint: 'http://jaeger-collector:14268/api/traces'
```

## 🐛 Troubleshooting

### Issue: Connection Timeout

```bash
# Verifica connettività
oc exec -it <pod> -- curl http://erp-service:3001/health

# Aumenta timeout
# In server.conf.yaml: HTTP_TIMEOUT_SECONDS: 60
```

### Issue: Circuit Breaker Always Open

```bash
# Reset circuit breaker state
# Restart integration server o attendi timeout (60s default)
```

### Issue: Memory Leak

```bash
# Monitora memoria
oc adm top pods -n cp4i

# Aumenta limits se necessario
```

## 📚 Riferimenti

- [IBM ACE Documentation](https://www.ibm.com/docs/en/app-connect/13.0)
- [ESQL Reference](https://www.ibm.com/docs/en/app-connect/13.0?topic=reference-esql)
- [Message Flow Development](https://www.ibm.com/docs/en/app-connect/13.0?topic=flows-developing-message)
- [Cloud Pak for Integration](https://www.ibm.com/docs/en/cloud-paks/cp-integration)

---

**Versione:** 1.0.0  
**Ultima modifica:** 2026-05-08  
**Maintainer:** IBM Cloud Pak for Integration Team