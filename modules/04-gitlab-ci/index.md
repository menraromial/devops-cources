---
layout: module
module_id: "04-gitlab-ci"
permalink: /modules/04-gitlab-ci/
---

## GitLab CI/CD - Intégration et Déploiement Continus

GitLab CI/CD est une plateforme intégrée qui permet d'automatiser les tests, la construction et le déploiement de vos applications à travers des pipelines configurables.

### Pourquoi GitLab CI/CD ?

- **Intégré** : Directement dans GitLab, pas d'outil externe
- **Flexible** : Pipelines configurables avec YAML
- **Scalable** : Runners distribués et auto-scaling
- **Sécurisé** : Gestion fine des permissions et secrets

### Contenu du Module

1. **Concepts de Base**
   - Pipelines, Jobs et Stages
   - Fichier .gitlab-ci.yml
   - Runners et Executors
   - Variables et secrets

2. **Pipelines Avancés**
   - Conditions et règles
   - Artifacts et cache
   - Pipelines parallèles
   - Déclencheurs et schedules

3. **Stratégies de Déploiement**
   - Environnements et déploiements
   - Blue/Green deployment
   - Canary releases
   - Rollback automatique

4. **Intégration avec l'Écosystème**
   - Docker Registry intégré
   - Kubernetes integration
   - Monitoring et alerting
   - Security scanning

### Exercices Pratiques

Vous apprendrez à :
- Configurer un GitLab Runner local
- Créer des pipelines de test et build
- Déployer automatiquement avec différentes stratégies
- Intégrer la sécurité dans vos pipelines

### Environnement de Lab

L'environnement inclut :
- GitLab CE en container Docker
- GitLab Runner configuré
- Registry Docker local
- Environnements de staging et production simulés