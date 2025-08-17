# Exercices Docker Basics

Ce répertoire contient une série d'exercices progressifs pour maîtriser Docker et la conteneurisation.

## Structure des Exercices

Chaque exercice est organisé dans son propre répertoire avec :
- `README.md` : Instructions détaillées de l'exercice
- `validate.sh` : Script de validation automatique
- Fichiers d'exemple et templates selon les besoins

## Exercices Disponibles

### 1. Docker Fundamentals (60 minutes)
**Répertoire :** `01-docker-fundamentals/`
**Objectifs :**
- Maîtriser les commandes Docker de base
- Comprendre les concepts d'images et conteneurs
- Manipuler les volumes et réseaux
- Utiliser le registry local

**Prérequis :** Aucun (exercice d'introduction)

### 2. Custom Images (90 minutes)
**Répertoire :** `02-custom-images/`
**Objectifs :**
- Écrire des Dockerfiles optimisés
- Implémenter des multi-stage builds
- Appliquer les bonnes pratiques de sécurité
- Optimiser la taille des images

**Prérequis :** Exercice 1 complété

### 3. Docker Compose (120 minutes)
**Répertoire :** `03-docker-compose/`
**Objectifs :**
- Créer des applications multi-conteneurs
- Configurer les réseaux et volumes
- Gérer les environnements multiples
- Implémenter le monitoring et les logs

**Prérequis :** Exercices 1 et 2 complétés

### 4. Production Ready (150 minutes)
**Répertoire :** `04-production-ready/`
**Objectifs :**
- Déployer une stack complète
- Configurer un reverse proxy avec SSL
- Implémenter les health checks
- Mettre en place le monitoring

**Prérequis :** Tous les exercices précédents complétés

## Comment Utiliser les Exercices

### 1. Démarrer l'Environnement
```bash
# Depuis le répertoire docker-basics/
./start-lab.sh
```

### 2. Choisir un Exercice
```bash
cd exercises/01-docker-fundamentals
cat README.md
```

### 3. Suivre les Instructions
Chaque exercice contient des instructions détaillées avec :
- Contexte et objectifs
- Étapes à suivre
- Commandes à exécuter
- Points de vérification

### 4. Valider les Résultats
```bash
# Dans le répertoire de l'exercice
./validate.sh
```

### 5. Passer à l'Exercice Suivant
Une fois la validation réussie, vous pouvez passer à l'exercice suivant.

## Conseils Généraux

### Bonnes Pratiques
- Lisez entièrement les instructions avant de commencer
- Testez chaque étape avant de passer à la suivante
- Utilisez les scripts de validation pour vérifier votre travail
- N'hésitez pas à consulter l'aide : `../help.sh`

### En Cas de Problème
1. Vérifiez les logs : `docker-compose logs [service]`
2. Consultez l'état des services : `docker-compose ps`
3. Redémarrez si nécessaire : `docker-compose restart [service]`
4. Utilisez l'aide : `../help.sh`

### Ressources Utiles
- Documentation Docker : https://docs.docker.com/
- Docker Compose : https://docs.docker.com/compose/
- Bonnes pratiques : https://docs.docker.com/develop/dev-best-practices/

## Progression Recommandée

```
01-docker-fundamentals → 02-custom-images → 03-docker-compose → 04-production-ready
```

Chaque exercice s'appuie sur les connaissances acquises dans les précédents. Il est recommandé de les suivre dans l'ordre.

## Support

Si vous rencontrez des difficultés :
1. Consultez le README de l'exercice spécifique
2. Vérifiez que l'environnement est correctement démarré
3. Utilisez les outils de debugging disponibles
4. Consultez les logs des services concernés

Bon apprentissage ! 🐳