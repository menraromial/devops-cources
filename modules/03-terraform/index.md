---
layout: module
module_id: "03-terraform"
permalink: /modules/03-terraform/
---

## Terraform - Infrastructure as Code

Terraform est un outil d'Infrastructure as Code (IaC) qui permet de définir, provisionner et gérer l'infrastructure cloud de manière déclarative et versionnée.

### Avantages de l'Infrastructure as Code

- **Reproductibilité** : Infrastructure identique à chaque déploiement
- **Versioning** : Historique des changements d'infrastructure
- **Collaboration** : Revue de code pour l'infrastructure
- **Automatisation** : Intégration dans les pipelines CI/CD

### Contenu du Module

1. **Concepts Fondamentaux**
   - Syntaxe HCL (HashiCorp Configuration Language)
   - Providers et Resources
   - State management
   - Plan et Apply

2. **Gestion de l'État**
   - Local vs Remote state
   - State locking
   - Backends (S3, Consul, etc.)
   - Import de ressources existantes

3. **Modules et Réutilisabilité**
   - Création de modules
   - Module registry
   - Versioning des modules
   - Composition d'architectures

4. **Workspaces et Collaboration**
   - Terraform Cloud/Enterprise
   - Workspaces pour les environnements
   - Variables et secrets
   - Policy as Code

### Exercices Pratiques

Vous apprendrez à :
- Créer votre première infrastructure avec le provider Docker
- Gérer l'état Terraform
- Développer des modules réutilisables
- Orchestrer des architectures complexes

### Environnement de Lab

Les exercices utilisent :
- Provider Docker pour la simplicité
- Provider local pour les fichiers
- Exemples avec AWS (simulation)
- Backend local pour l'apprentissage