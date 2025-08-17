---
layout: module
module_id: "06-kubernetes"
permalink: /modules/06-kubernetes/
---

## Kubernetes - Orchestration de Conteneurs

Kubernetes est la plateforme d'orchestration de conteneurs de référence, permettant de déployer, gérer et faire évoluer des applications conteneurisées à grande échelle.

### Pourquoi Kubernetes ?

- **Orchestration** : Gestion automatisée des conteneurs
- **Haute Disponibilité** : Self-healing et réplication
- **Scalabilité** : Auto-scaling horizontal et vertical
- **Écosystème** : Large communauté et outils intégrés

### Contenu du Module

1. **Architecture et Concepts**
   - Cluster, Nodes et Pods
   - Control Plane et Worker Nodes
   - API Server et etcd
   - Kubelet et kube-proxy

2. **Objets Kubernetes Essentiels**
   - Deployments et ReplicaSets
   - Services et Ingress
   - ConfigMaps et Secrets
   - Persistent Volumes

3. **Gestion des Applications**
   - Rolling updates et rollbacks
   - Health checks et probes
   - Resource management
   - Namespaces et RBAC

4. **Monitoring et Observabilité**
   - Metrics server
   - Logging centralisé
   - Distributed tracing
   - Alerting et dashboards

### Exercices Pratiques

Vous apprendrez à :
- Déployer un cluster Kubernetes local (kind/minikube)
- Déployer et gérer des applications
- Configurer l'ingress et les services
- Mettre en place le monitoring

### Environnement de Lab

L'environnement utilise :
- Kind (Kubernetes in Docker) pour le cluster local
- Applications d'exemple (microservices)
- Ingress Controller (Nginx)
- Stack de monitoring (Prometheus/Grafana)