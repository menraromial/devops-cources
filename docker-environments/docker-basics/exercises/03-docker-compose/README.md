# Exercice 3 : Docker Compose

**Durée estimée :** 120 minutes  
**Niveau :** Intermédiaire  
**Prérequis :** Exercices 1 et 2 complétés

## Objectifs

À la fin de cet exercice, vous serez capable de :
- Créer des applications multi-conteneurs avec Docker Compose
- Configurer les réseaux et volumes avec Compose
- Gérer différents environnements (dev, test, prod)
- Implémenter le monitoring et la gestion des logs
- Orchestrer des services complexes

## Contexte

Docker Compose permet de définir et gérer des applications multi-conteneurs. Dans cet exercice, vous allez créer une stack complète avec frontend, backend, base de données et monitoring.

## Prérequis Techniques

- Exercices 1 et 2 complétés avec succès
- Environnement Docker Lab démarré
- Compréhension des concepts Docker de base

## Étapes de l'Exercice

### Étape 1 : Stack Web Complète (40 minutes)

Vous allez créer une application web complète avec :
- Frontend React
- Backend API Node.js
- Base de données PostgreSQL
- Cache Redis
- Reverse proxy Nginx

### Étape 2 : Environnements Multiples (30 minutes)

Configuration de différents environnements :
- Développement avec hot-reload
- Test avec données de test
- Production optimisée

### Étape 3 : Monitoring et Logs (30 minutes)

Intégration du monitoring :
- Prometheus pour les métriques
- Grafana pour la visualisation
- Centralisation des logs

### Étape 4 : Orchestration Avancée (20 minutes)

Fonctionnalités avancées :
- Health checks
- Dépendances entre services
- Scaling automatique
- Gestion des secrets

## Instructions Détaillées

[Les instructions complètes seront développées dans la suite de l'implémentation]

## Validation

```bash
./validate.sh
```

## Prochaines Étapes

Une fois validé, passez à l'exercice 4 : "Production Ready".