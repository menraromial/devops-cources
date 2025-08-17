# Docker Basics Lab Environment

Ce laboratoire Docker fournit un environnement complet pour apprendre et pratiquer Docker avec des exercices progressifs.

## Architecture du Lab

```
docker-basics/
├── docker-compose.yml          # Orchestration des services
├── start-lab.sh               # Script de démarrage
├── help.sh                    # Aide et commandes utiles
├── registry/                  # Registry Docker local
├── apps/                      # Applications d'exemple
│   ├── nodejs-app/
│   ├── python-app/
│   └── go-app/
├── nginx/                     # Configuration reverse proxy
└── exercises/                 # Exercices pratiques
    ├── 01-docker-fundamentals/
    ├── 02-custom-images/
    ├── 03-docker-compose/
    └── 04-production-ready/
```

## Services Inclus

### Registry Docker Local
- **Port** : 5000
- **Interface** : http://localhost:5000
- **Usage** : Stockage local des images Docker

### Applications d'Exemple
- **Node.js App** : Application web moderne avec Express
- **Python App** : API Flask avec base de données
- **Go App** : Microservice haute performance

### Base de Données
- **PostgreSQL** : Base de données principale
- **Redis** : Cache et sessions
- **MongoDB** : Base NoSQL pour les exemples

### Monitoring
- **Prometheus** : Collecte de métriques
- **Grafana** : Visualisation des métriques
- **cAdvisor** : Métriques des conteneurs

### Reverse Proxy
- **Nginx** : Load balancer et SSL termination

## Démarrage Rapide

```bash
# Démarrer l'environnement complet
./start-lab.sh

# Voir l'aide
./help.sh

# Commencer les exercices
cd exercises/01-docker-fundamentals
cat README.md
```

## Ports Utilisés

| Service | Port | Description |
|---------|------|-------------|
| Registry | 5000 | Docker Registry local |
| Node.js App | 3000 | Application web Node.js |
| Python App | 5000 | API Flask |
| Go App | 8080 | Microservice Go |
| PostgreSQL | 5432 | Base de données |
| Redis | 6379 | Cache Redis |
| MongoDB | 27017 | Base NoSQL |
| Nginx | 80, 443 | Reverse proxy |
| Prometheus | 9090 | Métriques |
| Grafana | 3001 | Dashboards |
| cAdvisor | 8081 | Métriques conteneurs |

## Prérequis

- Docker 20.10+
- Docker Compose 1.29+
- 4GB RAM disponible
- 10GB espace disque

## Exercices Disponibles

1. **Docker Fundamentals** (60 min)
   - Commandes de base
   - Images et conteneurs
   - Volumes et réseaux

2. **Custom Images** (90 min)
   - Écriture de Dockerfiles
   - Multi-stage builds
   - Optimisation des images

3. **Docker Compose** (120 min)
   - Orchestration multi-conteneurs
   - Réseaux et volumes
   - Environnements multiples

4. **Production Ready** (150 min)
   - Sécurité et monitoring
   - Health checks
   - Déploiement complet

## Nettoyage

```bash
# Arrêter tous les services
docker-compose down

# Supprimer les volumes (attention : perte de données)
docker-compose down -v

# Nettoyer complètement
docker system prune -a
```

## Support

En cas de problème :
1. Vérifiez que Docker est démarré
2. Consultez les logs : `docker-compose logs`
3. Redémarrez l'environnement : `./start-lab.sh`