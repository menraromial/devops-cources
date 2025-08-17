---
layout: module
module_id: "02-ansible"
permalink: /modules/02-ansible/
---

## Ansible - Automatisation de Configuration

Ansible est un outil d'automatisation open-source qui permet de gérer la configuration, le déploiement d'applications et l'orchestration de tâches sur de multiples machines.

### Pourquoi Ansible ?

- **Simple** : Syntaxe YAML lisible
- **Agentless** : Pas d'agent à installer sur les machines cibles
- **Idempotent** : Exécution sûre et répétable
- **Extensible** : Large écosystème de modules

### Contenu du Module

1. **Installation et Configuration**
   - Installation d'Ansible
   - Configuration SSH
   - Fichier de configuration ansible.cfg

2. **Inventaires et Variables**
   - Gestion des inventaires statiques et dynamiques
   - Variables d'hôte et de groupe
   - Vault pour les données sensibles

3. **Playbooks et Modules**
   - Structure des playbooks
   - Modules essentiels
   - Handlers et notifications

4. **Rôles et Templates**
   - Organisation avec les rôles
   - Templates Jinja2
   - Galaxy et réutilisabilité

### Exercices Pratiques

Vous apprendrez à :
- Configurer un lab multi-nœuds avec Docker
- Écrire vos premiers playbooks
- Gérer des configurations complexes avec les rôles
- Déployer une application complète

### Environnement de Lab

Tous les exercices utilisent un environnement Docker avec :
- 1 nœud de contrôle Ansible
- 3 nœuds cibles (CentOS, Ubuntu, Alpine)
- Configuration SSH automatique