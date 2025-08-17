# Exercices Pratiques - Fondamentaux DevOps

Ce dossier contient les exercices pratiques pour le module Fondamentaux DevOps. Chaque exercice est conçu pour vous faire découvrir les outils et concepts essentiels du DevOps.

## Structure des Exercices

### Exercice 1 : Git et Contrôle de Version
**Durée estimée :** 45 minutes  
**Objectif :** Maîtriser les commandes Git de base et comprendre les workflows de développement collaboratif.

### Exercice 2 : Introduction à Docker
**Durée estimée :** 60 minutes  
**Objectif :** Comprendre les containers, créer des images Docker et manipuler des containers.

### Exercice 3 : Pipeline CI/CD avec Jenkins
**Durée estimée :** 90 minutes  
**Objectif :** Configurer un pipeline d'intégration continue basique avec Jenkins.

## Prérequis

Avant de commencer les exercices, assurez-vous que :
1. L'environnement Docker est démarré (`docker-compose up -d`)
2. Tous les services sont actifs (`docker-compose ps`)
3. Vous avez accès aux interfaces web :
   - Jenkins : http://localhost:8080 (admin/admin123)
   - Gitea : http://localhost:3000
   - Sample App : http://localhost:8000

## Ordre Recommandé

Il est recommandé de suivre les exercices dans l'ordre :
1. **Git et Contrôle de Version** - Base pour tous les autres exercices
2. **Introduction à Docker** - Compréhension des containers
3. **Pipeline CI/CD** - Intégration des concepts précédents

## Validation

Chaque exercice contient un script `validate.sh` qui vérifie automatiquement que vous avez correctement réalisé les tâches demandées.

## Support

En cas de difficulté :
1. Consultez les logs des containers : `docker-compose logs [service-name]`
2. Vérifiez l'état des services : `docker-compose ps`
3. Redémarrez un service si nécessaire : `docker-compose restart [service-name]`

## Nettoyage

Après avoir terminé tous les exercices :
```bash
# Arrêter tous les services
docker-compose down

# Supprimer les volumes (optionnel - supprime toutes les données)
docker-compose down -v
```