# Laboratoire Fondamentaux DevOps

Ce laboratoire fournit un environnement Docker simple pour découvrir les outils de base DevOps et pratiquer les concepts fondamentaux.

## Contenu du Laboratoire

### Exercice 1 : Découverte de Git et Contrôle de Version
- Container avec Git configuré
- Dépôt d'exemple pour pratiquer les commandes de base
- Scripts de validation des opérations Git

### Exercice 2 : Introduction aux Containers Docker
- Environnement pour créer et manipuler des containers
- Exemples d'applications simples à containeriser
- Pratique des commandes Docker essentielles

### Exercice 3 : Pipeline CI/CD Basique
- Environnement Jenkins local
- Configuration d'un pipeline simple
- Intégration avec Git pour déclencher les builds

## Prérequis

- Docker et Docker Compose installés
- Accès à Internet pour télécharger les images
- 4GB de RAM disponible
- 10GB d'espace disque libre

## Démarrage Rapide

```bash
# Cloner le dépôt et naviguer vers le laboratoire
cd docker-environments/fundamentals-lab

# Démarrer tous les services
docker-compose up -d

# Vérifier que tous les services sont actifs
docker-compose ps

# Accéder aux services
# - Jenkins: http://localhost:8080
# - Git Server: http://localhost:3000
# - Application d'exemple: http://localhost:8000
```

## Nettoyage

```bash
# Arrêter et supprimer tous les containers
docker-compose down -v

# Supprimer les images (optionnel)
docker-compose down --rmi all -v
```

## Structure des Exercices

Chaque exercice est organisé dans son propre dossier avec :
- `README.md` : Instructions détaillées
- `validate.sh` : Script de validation automatique
- Fichiers de configuration et exemples nécessaires

## Support

En cas de problème, consultez la section de dépannage dans chaque exercice ou référez-vous à la documentation principale du cours.