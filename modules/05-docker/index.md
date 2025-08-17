---
layout: module
module_id: "05-docker"
permalink: /modules/05-docker/
---

## Docker - Conteneurisation

Docker révolutionne le déploiement d'applications en permettant de packager une application et ses dépendances dans un conteneur léger et portable.

### Avantages de la Conteneurisation

- **Portabilité** : "Fonctionne sur ma machine" devient réalité partout
- **Isolation** : Applications isolées les unes des autres
- **Efficacité** : Partage du kernel, démarrage rapide
- **Scalabilité** : Orchestration et mise à l'échelle simplifiées

### Contenu du Module

1. **Concepts Fondamentaux**
   - Images vs Conteneurs
   - Dockerfile et layers
   - Registries et repositories
   - Networking et volumes

2. **Construction d'Images**
   - Bonnes pratiques Dockerfile
   - Multi-stage builds
   - Optimisation de la taille
   - Sécurité des images

3. **Docker Compose**
   - Orchestration multi-conteneurs
   - Services et networks
   - Volumes et configurations
   - Environnements de développement

4. **Production et Monitoring**
   - Logging et monitoring
   - Health checks
   - Resource limits
   - Sécurité en production

### Exercices Pratiques

Vous apprendrez à :
- Créer vos premières images Docker
- Orchestrer des applications multi-services
- Optimiser les performances et la sécurité
- Préparer des applications pour la production

### Environnement de Lab

Les exercices couvrent :
- Applications web (Node.js, Python, Go)
- Bases de données (PostgreSQL, Redis)
- Reverse proxy (Nginx)
- Monitoring (Prometheus, Grafana)