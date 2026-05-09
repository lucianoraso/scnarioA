# IBM API Connect Configuration

Configurazione IBM API Connect 10 per l'API consolidata Order Management nello Scenario A.

## 📋 Panoramica

IBM API Connect funge da API Gateway per:
- Esporre l'API consolidata ai consumer esterni
- Gestire autenticazione OAuth2
- Applicare rate limiting e throttling
- Fornire analytics e monitoring
- Gestire versioning e lifecycle API

## 🏗️ Architettura

```
┌─────────────────────────────────────────────────────────────┐
│                    API Connect Gateway                       │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Consumer → OAuth2 → Rate Limit → Invoke ACE → Response     │
│             Security   Policy      Integration   Transform   │
│                                    Server                     │
│                                                               │
│  Analytics ← Logging ← Monitoring ← Tracing                 │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## 📁 File Configurazione

| File | Descrizione |
|------|-------------|
| `order-management-api.yaml` | OpenAPI 3.0 specification con x-ibm-configuration |
| `product-definition.yaml` | Product e Plan definition |
| `oauth-provider.yaml` | OAuth2 provider configuration |
| `README.md` | Questo file |

## 🚀 Setup API Connect

### Prerequisiti

1. **IBM Cloud Pak for Integration 16.1.3** installato
2. **API Connect 10** configurato
3. **ACE Integration Server** deployato e funzionante
4. Accesso alla **API Manager UI**

### Step 1: Accesso API Manager

```bash
# Ottieni URL API Manager
oc get route apim-demo-mgmt -n cp4i -o jsonpath='{.spec.host}'

# Ottieni credenziali admin
oc get secret apim-demo-mgmt-admin-creds -n cp4i -o jsonpath='{.data.password}' | base64 -d

# Login
https://<api-manager-url>/manager
Username: admin
Password: <from secret>
```

### Step 2: Creare Provider Organization

```bash
# In API Manager UI
1. Navigate to: Manage Organizations
2. Click: Add → Provider Organization
3. Fill:
   - Name: scenario-a-provider
   - Title: Scenario A Provider Org
   - Owner: admin
4. Click: Create
```

### Step 3: Importare OpenAPI Specification

```bash
# In API Manager UI
1. Navigate to: Develop APIs and Products
2. Click: Add → API (from REST, GraphQL or SOAP)
3. Select: OpenAPI 3.0
4. Upload: order-management-api.yaml
5. Click: Next
6. Review and click: Next
7. Activate API: Yes
8. Click: Create
```

### Step 4: Configurare OAuth2 Provider

#### Creare OAuth Provider

```bash
# In API Manager UI
1. Navigate to: Resources → OAuth Providers
2. Click: Add → Native OAuth Provider
3. Fill:
   - Title: Order Management OAuth Provider
   - Name: order-oauth-provider
   - Gateway Type: DataPower API Gateway
4. Configure:
   - Supported Grant Types: Client Credentials
   - Supported Client Types: Confidential
   - Token TTL: 3600 seconds
5. Click: Save
```

#### Configurare OAuth Provider nella API

```yaml
# In order-management-api.yaml (già configurato)
securitySchemes:
  OAuth2:
    type: oauth2
    flows:
      clientCredentials:
        tokenUrl: https://oauth-server/token
        scopes:
          orders:read: Lettura ordini
```

### Step 5: Creare Product e Plan

#### Product Definition

```yaml
# product-definition.yaml
product: 1.0.0
info:
  name: order-management-product
  title: Order Management Product
  version: 1.0.0
  description: Product per API Order Management
  
apis:
  order-management-api:
    name: order-management-api:1.0.0
    
plans:
  standard:
    title: Standard Plan
    description: Piano standard con rate limiting
    approval: false
    rate-limits:
      default:
        value: 100/1minute
    burst-limits:
      default:
        value: 200/1minute
        
  premium:
    title: Premium Plan
    description: Piano premium con rate limiting elevato
    approval: true
    rate-limits:
      default:
        value: 1000/1minute
    burst-limits:
      default:
        value: 2000/1minute
        
visibility:
  view:
    type: public
  subscribe:
    type: authenticated
```

#### Importare Product

```bash
# In API Manager UI
1. Navigate to: Develop APIs and Products
2. Click: Add → Product
3. Upload: product-definition.yaml
4. Click: Next
5. Review and click: Create
```

### Step 6: Pubblicare su Gateway

```bash
# In API Manager UI
1. Navigate to: Develop APIs and Products
2. Select: order-management-product
3. Click: Publish
4. Select Catalog: Sandbox (per test) o Production
5. Click: Publish
6. Verify: Status = Published
```

### Step 7: Creare Application e Subscribe

#### Creare Application

```bash
# In Developer Portal o API Manager
1. Navigate to: Apps
2. Click: Create new app
3. Fill:
   - Title: Order Management Test App
   - Description: App per testing
4. Click: Save
5. Note: Client ID e Client Secret
```

#### Subscribe al Product

```bash
1. Navigate to: Products
2. Select: Order Management Product
3. Click: Subscribe
4. Select: Standard Plan
5. Select: Your Application
6. Click: Subscribe
```

## 🧪 Testing

### 1. Ottenere OAuth2 Token

```bash
# Client Credentials Flow
curl -X POST https://<api-gateway>/oauth2/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials" \
  -d "client_id=<your-client-id>" \
  -d "client_secret=<your-client-secret>" \
  -d "scope=orders:read"

# Response
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "orders:read"
}
```

### 2. Chiamare API

```bash
# Get Order
curl -X GET https://<api-gateway>/scenario-a/api/v1/orders/ORD-2026-001 \
  -H "Authorization: Bearer <access-token>" \
  -H "X-IBM-Client-Id: <client-id>"

# Response
{
  "order": {
    "orderId": "ORD-2026-001",
    "orderNumber": "PO-2026-001234",
    "status": "IN_PROGRESS",
    ...
  },
  "metadata": {
    "orchestrationTimestamp": "2026-05-08T15:00:00Z"
  }
}
```

### 3. Test Rate Limiting

```bash
# Esegui 101 richieste in 1 minuto
for i in {1..101}; do
  curl -X GET https://<api-gateway>/scenario-a/api/v1/orders/ORD-2026-001 \
    -H "Authorization: Bearer <token>" \
    -H "X-IBM-Client-Id: <client-id>"
done

# La 101esima richiesta dovrebbe restituire 429 Too Many Requests
```

### 4. Test Error Scenarios

```bash
# Ordine non esistente
curl -X GET https://<api-gateway>/scenario-a/api/v1/orders/ORD-9999-999 \
  -H "Authorization: Bearer <token>"
# Expected: 404 Not Found

# Token non valido
curl -X GET https://<api-gateway>/scenario-a/api/v1/orders/ORD-2026-001 \
  -H "Authorization: Bearer invalid-token"
# Expected: 401 Unauthorized

# Senza token
curl -X GET https://<api-gateway>/scenario-a/api/v1/orders/ORD-2026-001
# Expected: 401 Unauthorized
```

## 📊 Monitoring e Analytics

### View Analytics

```bash
# In API Manager UI
1. Navigate to: Analytics
2. Select: Time Range
3. View:
   - API Calls
   - Response Times
   - Error Rates
   - Top APIs
   - Top Products
   - Top Applications
```

### Export Analytics Data

```bash
# Via API
curl -X GET https://<api-manager>/analytics/data \
  -H "Authorization: Bearer <admin-token>" \
  -H "Accept: application/json" \
  -d "start_date=2026-05-01" \
  -d "end_date=2026-05-08"
```

## 🔧 Configurazioni Avanzate

### Custom Assembly Policies

#### Add Logging Policy

```yaml
# In API assembly
- gatewayscript:
    title: Log Request
    version: 2.0.0
    source: |
      var logger = require('logger');
      logger.info('Request received', {
        path: context.request.path,
        method: context.request.verb,
        clientId: context.request.headers['x-ibm-client-id']
      });
```

#### Add Response Transformation

```yaml
- gatewayscript:
    title: Transform Response
    version: 2.0.0
    source: |
      // Add custom fields
      var response = context.message.body;
      response.apiVersion = '1.0.0';
      response.timestamp = new Date().toISOString();
      context.message.body = response;
```

### Circuit Breaker Policy

```yaml
- invoke:
    title: Call Backend with Circuit Breaker
    version: 2.0.0
    target-url: $(target-url)
    timeout: 30
    circuit-breaker:
      enabled: true
      threshold: 5
      timeout: 60
      half-open-requests: 3
```

### Caching Policy

```yaml
- cache:
    title: Cache Response
    version: 2.0.0
    cache-key: $(request.path)
    ttl: 300
    cache-type: protocol
```

## 🔒 Security Best Practices

### 1. OAuth2 Configuration

```yaml
# Usa sempre HTTPS
# Configura token expiration appropriato
# Implementa token refresh
# Usa scope granulari
```

### 2. Rate Limiting

```yaml
# Configura limiti per plan
# Monitora usage patterns
# Implementa burst limits
# Configura hard limits
```

### 3. API Keys

```yaml
# Ruota regolarmente
# Usa secrets management
# Non hardcodare in codice
# Monitora usage
```

## 📚 Riferimenti

- [IBM API Connect Documentation](https://www.ibm.com/docs/en/api-connect/10.0.x)
- [OpenAPI 3.0 Specification](https://swagger.io/specification/)
- [OAuth 2.0 RFC](https://tools.ietf.org/html/rfc6749)
- [API Connect Developer Portal](https://www.ibm.com/docs/en/api-connect/10.0.x?topic=portal-developer)

---

**Versione:** 1.0.0  
**Ultima modifica:** 2026-05-08  
**Maintainer:** IBM Cloud Pak for Integration Team