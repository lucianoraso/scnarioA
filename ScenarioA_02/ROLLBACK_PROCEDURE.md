# Procedura di Rollback - Scenario A

Documento che descrive le procedure di rollback per tutti i componenti dello Scenario A.

## 📋 Panoramica

Questo documento fornisce istruzioni dettagliate per il rollback di:
- Backend Mock Services (ERP, MES, QMS)
- ACE Integration Server
- API Connect Configuration
- Database PostgreSQL

## 🎯 Scenari di Rollback

### Scenario 1: Rollback Completo
Ripristino completo dello stato precedente al deployment

### Scenario 2: Rollback Parziale
Rollback di singoli componenti mantenendo gli altri attivi

### Scenario 3: Rollback Database
Ripristino solo dei dati del database

## 🔄 Procedura Rollback Completo

### Step 1: Backup Stato Corrente

```bash
# Backup configurazioni
oc get all -n scenario-a-demo -o yaml > backup-$(date +%Y%m%d-%H%M%S).yaml

# Backup database
POD_NAME=$(oc get pod -n scenario-a-demo -l app=postgresql -o jsonpath='{.items[0].metadata.name}')
oc exec -n scenario-a-demo ${POD_NAME} -- pg_dump -U postgres production_orders > db-backup-$(date +%Y%m%d-%H%M%S).sql

# Backup secrets e configmaps
oc get secrets -n scenario-a-demo -o yaml > secrets-backup.yaml
oc get configmaps -n scenario-a-demo -o yaml > configmaps-backup.yaml
```

### Step 2: Rollback ACE Integration Server

```bash
# Verifica deployment history
oc rollout history deployment/order-orchestration-server -n scenario-a-demo

# Rollback alla versione precedente
oc rollout undo deployment/order-orchestration-server -n scenario-a-demo

# Rollback a versione specifica
oc rollout undo deployment/order-orchestration-server --to-revision=2 -n scenario-a-demo

# Verifica stato
oc rollout status deployment/order-orchestration-server -n scenario-a-demo

# Verifica pods
oc get pods -n scenario-a-demo -l app=ace-integration-server
```

### Step 3: Rollback Backend Services

```bash
# Rollback ERP Service
oc rollout undo deployment/erp-service -n scenario-a-demo
oc rollout status deployment/erp-service -n scenario-a-demo

# Rollback MES Service
oc rollout undo deployment/mes-service -n scenario-a-demo
oc rollout status deployment/mes-service -n scenario-a-demo

# Rollback QMS Service
oc rollout undo deployment/qms-service -n scenario-a-demo
oc rollout status deployment/qms-service -n scenario-a-demo

# Verifica health
curl https://$(oc get route erp-service -n scenario-a-demo -o jsonpath='{.spec.host}')/health
curl https://$(oc get route mes-service -n scenario-a-demo -o jsonpath='{.spec.host}')/health
curl https://$(oc get route qms-service -n scenario-a-demo -o jsonpath='{.spec.host}')/health
```

### Step 4: Rollback Database

```bash
# Stop applicazioni che usano il database
oc scale deployment/erp-service --replicas=0 -n scenario-a-demo
oc scale deployment/mes-service --replicas=0 -n scenario-a-demo
oc scale deployment/qms-service --replicas=0 -n scenario-a-demo

# Ripristina database da backup
POD_NAME=$(oc get pod -n scenario-a-demo -l app=postgresql -o jsonpath='{.items[0].metadata.name}')

# Drop e ricrea database
oc exec -n scenario-a-demo ${POD_NAME} -- psql -U postgres -c "DROP DATABASE IF EXISTS production_orders;"
oc exec -n scenario-a-demo ${POD_NAME} -- psql -U postgres -c "CREATE DATABASE production_orders;"

# Ripristina da backup
cat db-backup-YYYYMMDD-HHMMSS.sql | oc exec -i -n scenario-a-demo ${POD_NAME} -- psql -U postgres production_orders

# Verifica ripristino
oc exec -n scenario-a-demo ${POD_NAME} -- psql -U postgres -d production_orders -c "SELECT COUNT(*) FROM orders;"

# Riavvia applicazioni
oc scale deployment/erp-service --replicas=2 -n scenario-a-demo
oc scale deployment/mes-service --replicas=2 -n scenario-a-demo
oc scale deployment/qms-service --replicas=2 -n scenario-a-demo
```

### Step 5: Rollback API Connect

```bash
# In API Manager UI
1. Navigate to: Develop APIs and Products
2. Select: order-management-product
3. Click: Manage → Versions
4. Select: Previous version
5. Click: Replace current version
6. Publish to Gateway

# Via CLI (se disponibile)
apic products:replace order-management-product:1.0.0 \
  --scope catalog \
  --catalog sandbox \
  --org scenario-a-provider
```

## 🔧 Rollback Parziale

### Rollback Solo ACE

```bash
# Rollback ACE mantenendo backend services
oc rollout undo deployment/order-orchestration-server -n scenario-a-demo

# Verifica che backend services siano ancora attivi
oc get pods -n scenario-a-demo -l app.kubernetes.io/component=backend
```

### Rollback Solo Backend Service Specifico

```bash
# Esempio: Rollback solo ERP Service
oc rollout undo deployment/erp-service -n scenario-a-demo

# Verifica
oc rollout status deployment/erp-service -n scenario-a-demo
curl https://$(oc get route erp-service -n scenario-a-demo -o jsonpath='{.spec.host}')/health
```

### Rollback Configurazione (ConfigMap/Secret)

```bash
# Ripristina ConfigMap da backup
oc apply -f configmaps-backup.yaml -n scenario-a-demo

# Ripristina Secret da backup
oc apply -f secrets-backup.yaml -n scenario-a-demo

# Restart pods per applicare nuova configurazione
oc rollout restart deployment/erp-service -n scenario-a-demo
oc rollout restart deployment/mes-service -n scenario-a-demo
oc rollout restart deployment/qms-service -n scenario-a-demo
```

## 🗑️ Rimozione Completa

### Rimuovi Tutti i Componenti

```bash
# Delete all resources in namespace
oc delete all --all -n scenario-a-demo

# Delete ConfigMaps and Secrets
oc delete configmaps --all -n scenario-a-demo
oc delete secrets --all -n scenario-a-demo

# Delete PVCs (attenzione: elimina i dati!)
oc delete pvc --all -n scenario-a-demo

# Delete namespace
oc delete namespace scenario-a-demo
```

### Rimuovi Solo Applicazioni (Mantieni Database)

```bash
# Delete deployments
oc delete deployment erp-service mes-service qms-service order-orchestration-server -n scenario-a-demo

# Delete services
oc delete service erp-service mes-service qms-service ace-integration-server -n scenario-a-demo

# Delete routes
oc delete route erp-service mes-service qms-service ace-integration-server -n scenario-a-demo

# Mantieni PostgreSQL e PVC
```

## 📊 Verifica Post-Rollback

### Checklist Verifica

```bash
# 1. Verifica pods
oc get pods -n scenario-a-demo
# Tutti i pods devono essere Running

# 2. Verifica services
oc get services -n scenario-a-demo
# Tutti i services devono avere endpoints

# 3. Verifica routes
oc get routes -n scenario-a-demo
# Tutte le routes devono essere accessibili

# 4. Test health endpoints
for service in erp-service mes-service qms-service; do
  echo "Testing ${service}..."
  curl -f https://$(oc get route ${service} -n scenario-a-demo -o jsonpath='{.spec.host}')/health
done

# 5. Test database connectivity
POD_NAME=$(oc get pod -n scenario-a-demo -l app=postgresql -o jsonpath='{.items[0].metadata.name}')
oc exec -n scenario-a-demo ${POD_NAME} -- psql -U postgres -d production_orders -c "SELECT 1;"

# 6. Test end-to-end
curl https://$(oc get route ace-integration-server -n scenario-a-demo -o jsonpath='{.spec.host}')/api/v1/orders/ORD-2026-001
```

### Script Verifica Automatica

```bash
#!/bin/bash
# verify-rollback.sh

NAMESPACE="scenario-a-demo"
FAILED=0

echo "Verifying rollback..."

# Check pods
echo "Checking pods..."
if ! oc get pods -n ${NAMESPACE} | grep -v "Running\|Completed"; then
  echo "✓ All pods are running"
else
  echo "✗ Some pods are not running"
  FAILED=1
fi

# Check services
echo "Checking services..."
SERVICES="erp-service mes-service qms-service"
for svc in ${SERVICES}; do
  if curl -sf https://$(oc get route ${svc} -n ${NAMESPACE} -o jsonpath='{.spec.host}')/health > /dev/null; then
    echo "✓ ${svc} is healthy"
  else
    echo "✗ ${svc} is not healthy"
    FAILED=1
  fi
done

if [ ${FAILED} -eq 0 ]; then
  echo "✓ Rollback verification passed"
  exit 0
else
  echo "✗ Rollback verification failed"
  exit 1
fi
```

## 🚨 Troubleshooting Rollback

### Problema: Rollback Bloccato

```bash
# Forza rollback
oc rollout undo deployment/erp-service -n scenario-a-demo --force

# Se ancora bloccato, elimina e ricrea
oc delete deployment erp-service -n scenario-a-demo
oc apply -f kubernetes/erp-service-deployment.yaml -n scenario-a-demo
```

### Problema: Database Corrotto

```bash
# Ripristina da backup più vecchio
cat db-backup-OLDER.sql | oc exec -i -n scenario-a-demo ${POD_NAME} -- psql -U postgres production_orders

# Se necessario, ricrea da zero
oc exec -n scenario-a-demo ${POD_NAME} -- psql -U postgres < database/init-scripts/01-create-schemas.sql
oc exec -n scenario-a-demo ${POD_NAME} -- psql -U postgres < database/init-scripts/02-seed-orders.sql
# etc...
```

### Problema: PVC Non Eliminabile

```bash
# Rimuovi finalizers
oc patch pvc postgresql-data -n scenario-a-demo -p '{"metadata":{"finalizers":null}}'

# Force delete
oc delete pvc postgresql-data -n scenario-a-demo --force --grace-period=0
```

## 📝 Best Practices

### Prima del Deployment

1. **Backup completo** di tutti i componenti
2. **Documentare** la versione corrente
3. **Testare** la procedura di rollback in ambiente di test
4. **Pianificare** finestra di manutenzione
5. **Comunicare** agli stakeholder

### Durante il Rollback

1. **Monitorare** logs in tempo reale
2. **Verificare** ogni step prima di procedere
3. **Documentare** eventuali problemi
4. **Comunicare** progressi

### Dopo il Rollback

1. **Verificare** funzionalità end-to-end
2. **Analizzare** cause del problema
3. **Aggiornare** documentazione
4. **Pianificare** fix e re-deployment

## 📚 Riferimenti

- [OpenShift Rollback Documentation](https://docs.openshift.com/container-platform/4.18/applications/deployments/managing-deployment-processes.html)
- [PostgreSQL Backup and Restore](https://www.postgresql.org/docs/13/backup.html)
- [IBM ACE Rollback Procedures](https://www.ibm.com/docs/en/app-connect/13.0)

---

**Versione:** 1.0.0  
**Ultima modifica:** 2026-05-08  
**Maintainer:** IBM Cloud Pak for Integration Team