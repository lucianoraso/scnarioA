# Kubernetes/OpenShift Deployment Manifests

Manifest YAML per il deployment dello Scenario A su RedHat OpenShift 4.18 con IBM Cloud Pak for Integration 16.1.3.

## 📋 Contenuto

| File | Descrizione |
|------|-------------|
| `postgresql-statefulset.yaml` | PostgreSQL database con persistent storage |
| `erp-service-deployment.yaml` | ERP mock service deployment |
| `mes-service-deployment.yaml` | MES mock service deployment |
| `qms-service-deployment.yaml` | QMS mock service deployment |

## 🏗️ Architettura Deployment

```
scenario-a-demo namespace
├── PostgreSQL StatefulSet (1 replica)
│   ├── Service: postgresql (ClusterIP)
│   ├── PVC: 10Gi persistent storage
│   └── Init scripts via ConfigMap
├── ERP Service Deployment (2-5 replicas)
│   ├── Service: erp-service (ClusterIP)
│   ├── Route: HTTPS external access
│   └── HPA: CPU/Memory based autoscaling
├── MES Service Deployment (2-5 replicas)
│   ├── Service: mes-service (ClusterIP)
│   ├── Route: HTTPS external access
│   └── HPA: CPU/Memory based autoscaling
└── QMS Service Deployment (2-5 replicas)
    ├── Service: qms-service (ClusterIP)
    ├── Route: HTTPS external access
    └── HPA: CPU/Memory based autoscaling
```

## 🚀 Deployment Completo

### Prerequisiti

1. **Cluster OpenShift 4.18** con accesso admin
2. **oc CLI** installato e configurato
3. **Docker images** build e push al registry:
   ```bash
   # Build images
   docker build -t <registry>/erp-service:1.0.0 backend-mocks/erp-service/
   docker build -t <registry>/mes-service:1.0.0 backend-mocks/mes-service/
   docker build -t <registry>/qms-service:1.0.0 backend-mocks/qms-service/
   
   # Push to registry
   docker push <registry>/erp-service:1.0.0
   docker push <registry>/mes-service:1.0.0
   docker push <registry>/qms-service:1.0.0
   ```

### Step 1: Login a OpenShift

```bash
# Login al cluster
oc login --token=<your-token> --server=https://api.cluster.example.com:6443

# Verifica accesso
oc whoami
oc version
```

### Step 2: Deploy PostgreSQL Database

```bash
# Crea namespace e deploy PostgreSQL
oc apply -f kubernetes/postgresql-statefulset.yaml

# Verifica deployment
oc get statefulset -n scenario-a-demo
oc get pods -n scenario-a-demo -l app=postgresql
oc get pvc -n scenario-a-demo

# Attendi che PostgreSQL sia ready
oc wait --for=condition=ready pod -l app=postgresql -n scenario-a-demo --timeout=300s
```

### Step 3: Inizializza Database

```bash
# Crea ConfigMap con gli script SQL
oc create configmap postgresql-init-data \
  --from-file=database/init-scripts/01-create-schemas.sql \
  --from-file=database/init-scripts/02-seed-orders.sql \
  --from-file=database/init-scripts/03-seed-production-steps.sql \
  --from-file=database/init-scripts/04-seed-quality-checks.sql \
  -n scenario-a-demo

# Esegui gli script SQL
POD_NAME=$(oc get pod -n scenario-a-demo -l app=postgresql -o jsonpath='{.items[0].metadata.name}')

oc exec -n scenario-a-demo $POD_NAME -- psql -U postgres -d production_orders -c "\dt"

# Copia e esegui script
for script in 01-create-schemas.sql 02-seed-orders.sql 03-seed-production-steps.sql 04-seed-quality-checks.sql; do
  echo "Executing $script..."
  oc exec -n scenario-a-demo $POD_NAME -- psql -U postgres -d production_orders < database/init-scripts/$script
done

# Verifica dati
oc exec -n scenario-a-demo $POD_NAME -- psql -U postgres -d production_orders -c "SELECT COUNT(*) FROM orders;"
oc exec -n scenario-a-demo $POD_NAME -- psql -U postgres -d production_orders -c "SELECT COUNT(*) FROM production_steps;"
oc exec -n scenario-a-demo $POD_NAME -- psql -U postgres -d production_orders -c "SELECT COUNT(*) FROM quality_checks;"
```

### Step 4: Deploy Backend Services

```bash
# Deploy ERP Service
oc apply -f kubernetes/erp-service-deployment.yaml

# Deploy MES Service
oc apply -f kubernetes/mes-service-deployment.yaml

# Deploy QMS Service
oc apply -f kubernetes/qms-service-deployment.yaml

# Verifica deployments
oc get deployments -n scenario-a-demo
oc get pods -n scenario-a-demo
oc get services -n scenario-a-demo
oc get routes -n scenario-a-demo
```

### Step 5: Verifica Health

```bash
# Check pod status
oc get pods -n scenario-a-demo -w

# Check logs
oc logs -n scenario-a-demo -l app=erp-service --tail=50
oc logs -n scenario-a-demo -l app=mes-service --tail=50
oc logs -n scenario-a-demo -l app=qms-service --tail=50

# Test health endpoints
ERP_ROUTE=$(oc get route erp-service -n scenario-a-demo -o jsonpath='{.spec.host}')
MES_ROUTE=$(oc get route mes-service -n scenario-a-demo -o jsonpath='{.spec.host}')
QMS_ROUTE=$(oc get route qms-service -n scenario-a-demo -o jsonpath='{.spec.host}')

curl https://$ERP_ROUTE/health
curl https://$MES_ROUTE/health
curl https://$QMS_ROUTE/health
```

## 🧪 Testing

### Test ERP Service

```bash
ERP_ROUTE=$(oc get route erp-service -n scenario-a-demo -o jsonpath='{.spec.host}')

# Get all orders
curl https://$ERP_ROUTE/api/v1/orders

# Get specific order
curl https://$ERP_ROUTE/api/v1/orders/ORD-2026-001

# Get statistics
curl https://$ERP_ROUTE/api/v1/orders/statistics
```

### Test MES Service

```bash
MES_ROUTE=$(oc get route mes-service -n scenario-a-demo -o jsonpath='{.spec.host}')

# Get production steps for order
curl "https://$MES_ROUTE/api/v1/production-steps?orderId=ORD-2026-001"

# Get specific step
curl https://$MES_ROUTE/api/v1/production-steps/1

# Get statistics
curl https://$MES_ROUTE/api/v1/production-steps/statistics
```

### Test QMS Service

```bash
QMS_ROUTE=$(oc get route qms-service -n scenario-a-demo -o jsonpath='{.spec.host}')

# Get quality checks for steps
curl "https://$QMS_ROUTE/api/v1/quality-checks?stepIds=1,2,3"

# Get specific check
curl https://$QMS_ROUTE/api/v1/quality-checks/1

# Get statistics
curl https://$QMS_ROUTE/api/v1/quality-checks/statistics
```

## 📊 Monitoring

### View Logs

```bash
# Tail logs in real-time
oc logs -n scenario-a-demo -l app=erp-service -f
oc logs -n scenario-a-demo -l app=mes-service -f
oc logs -n scenario-a-demo -l app=qms-service -f

# View logs from all pods
oc logs -n scenario-a-demo --all-containers=true -l app.kubernetes.io/part-of=scenario-a-demo
```

### View Metrics

```bash
# Pod metrics
oc adm top pods -n scenario-a-demo

# Node metrics
oc adm top nodes

# HPA status
oc get hpa -n scenario-a-demo
oc describe hpa erp-service-hpa -n scenario-a-demo
```

### View Events

```bash
# Recent events
oc get events -n scenario-a-demo --sort-by='.lastTimestamp'

# Watch events
oc get events -n scenario-a-demo -w
```

## 🔧 Configurazione

### Modifica Configurazione

```bash
# Edit ConfigMap
oc edit configmap erp-service-config -n scenario-a-demo

# Edit Secret
oc edit secret erp-service-secret -n scenario-a-demo

# Restart pods per applicare modifiche
oc rollout restart deployment/erp-service -n scenario-a-demo
```

### Scaling Manuale

```bash
# Scale up
oc scale deployment erp-service --replicas=5 -n scenario-a-demo

# Scale down
oc scale deployment erp-service --replicas=2 -n scenario-a-demo

# Verifica
oc get deployment erp-service -n scenario-a-demo
```

### Abilitare Autenticazione OAuth2

```bash
# Modifica ConfigMap
oc patch configmap erp-service-config -n scenario-a-demo \
  --type merge -p '{"data":{"AUTH_ENABLED":"true"}}'

# Restart deployment
oc rollout restart deployment/erp-service -n scenario-a-demo
```

## 🔄 Update e Rollback

### Rolling Update

```bash
# Update image
oc set image deployment/erp-service erp-service=<registry>/erp-service:1.1.0 -n scenario-a-demo

# Watch rollout
oc rollout status deployment/erp-service -n scenario-a-demo

# Verifica history
oc rollout history deployment/erp-service -n scenario-a-demo
```

### Rollback

```bash
# Rollback to previous version
oc rollout undo deployment/erp-service -n scenario-a-demo

# Rollback to specific revision
oc rollout undo deployment/erp-service --to-revision=2 -n scenario-a-demo
```

## 🗑️ Cleanup

### Rimuovi Singolo Servizio

```bash
# Delete ERP service
oc delete -f kubernetes/erp-service-deployment.yaml
```

### Rimuovi Tutto

```bash
# Delete all resources
oc delete -f kubernetes/qms-service-deployment.yaml
oc delete -f kubernetes/mes-service-deployment.yaml
oc delete -f kubernetes/erp-service-deployment.yaml
oc delete -f kubernetes/postgresql-statefulset.yaml

# Delete namespace (rimuove tutto)
oc delete namespace scenario-a-demo
```

## 🔒 Security Best Practices

### Secrets Management

```bash
# Crea secret da file
oc create secret generic db-credentials \
  --from-literal=username=postgres \
  --from-literal=password=$(openssl rand -base64 32) \
  -n scenario-a-demo

# Usa sealed secrets per GitOps
kubeseal --format yaml < secret.yaml > sealed-secret.yaml
```

### Network Policies

```bash
# Crea network policy per isolare i servizi
cat <<EOF | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-services-policy
  namespace: scenario-a-demo
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/component: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: cp4i-ace
    ports:
    - protocol: TCP
      port: 3001
    - protocol: TCP
      port: 3002
    - protocol: TCP
      port: 3003
EOF
```

## 📈 Performance Tuning

### Resource Limits

```bash
# Aumenta resource limits
oc set resources deployment erp-service \
  --requests=cpu=200m,memory=512Mi \
  --limits=cpu=1000m,memory=1Gi \
  -n scenario-a-demo
```

### HPA Tuning

```bash
# Modifica HPA thresholds
oc patch hpa erp-service-hpa -n scenario-a-demo \
  --type merge -p '{"spec":{"metrics":[{"type":"Resource","resource":{"name":"cpu","target":{"type":"Utilization","averageUtilization":60}}}]}}'
```

## 🐛 Troubleshooting

### Pod non si avvia

```bash
# Describe pod
oc describe pod <pod-name> -n scenario-a-demo

# Check events
oc get events -n scenario-a-demo --field-selector involvedObject.name=<pod-name>

# Check logs
oc logs <pod-name> -n scenario-a-demo --previous
```

### Database connection issues

```bash
# Test connectivity from pod
oc exec -n scenario-a-demo <pod-name> -- nc -zv postgresql 5432

# Check PostgreSQL logs
oc logs -n scenario-a-demo -l app=postgresql
```

### Service non raggiungibile

```bash
# Check service endpoints
oc get endpoints -n scenario-a-demo

# Test service from another pod
oc run test-pod --image=curlimages/curl -it --rm -n scenario-a-demo -- \
  curl http://erp-service:3001/health
```

## 📚 Riferimenti

- [OpenShift Documentation](https://docs.openshift.com/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [IBM Cloud Pak for Integration](https://www.ibm.com/docs/en/cloud-paks/cp-integration)

---

**Versione:** 1.0.0  
**Ultima modifica:** 2026-05-08  
**Maintainer:** IBM Cloud Pak for Integration Team