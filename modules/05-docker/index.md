---
layout: module
module_id: "05-docker"
permalink: /modules/05-docker/
---

# Module 5 - Docker - Conteneurisation

## Objectifs d'Apprentissage

À la fin de ce module, vous serez capable de :
- Comprendre les concepts fondamentaux de la conteneurisation avec Docker
- Créer et optimiser des images Docker personnalisées
- Orchestrer des applications multi-conteneurs avec Docker Compose
- Appliquer les bonnes pratiques de sécurité et de performance
- Préparer des applications conteneurisées pour la production

## Prérequis

- Connaissances de base en ligne de commande Linux
- Compréhension des concepts réseau de base
- Familiarité avec les processus et services système
- Module "Fondamentaux DevOps" complété

## Introduction à Docker

Docker a révolutionné le monde du déploiement d'applications en introduisant la conteneurisation légère. Cette technologie permet de packager une application avec toutes ses dépendances dans un conteneur portable, résolvant définitivement le problème du "ça marche sur ma machine".

## 1. Concepts Fondamentaux

### Qu'est-ce que la Conteneurisation ?

La conteneurisation est une méthode de virtualisation au niveau du système d'exploitation qui permet d'exécuter des applications dans des environnements isolés appelés conteneurs.

#### Conteneurs vs Machines Virtuelles

| Aspect | Conteneurs | Machines Virtuelles |
|--------|------------|-------------------|
| **Isolation** | Processus et namespaces | Hardware virtuel complet |
| **Overhead** | Minimal (MB) | Important (GB) |
| **Démarrage** | Secondes | Minutes |
| **Densité** | Très élevée | Limitée |
| **Portabilité** | Excellente | Bonne |

#### Architecture Docker

```
┌─────────────────────────────────────────┐
│           Applications                   │
├─────────────────────────────────────────┤
│         Docker Engine                   │
├─────────────────────────────────────────┤
│       Host Operating System            │
├─────────────────────────────────────────┤
│           Infrastructure                │
└─────────────────────────────────────────┘
```

### Images et Conteneurs

#### Images Docker
- **Définition** : Template en lecture seule pour créer des conteneurs
- **Composition** : Système de fichiers en couches (layers)
- **Immutabilité** : Une fois créée, une image ne change pas
- **Réutilisabilité** : Une image peut créer plusieurs conteneurs

#### Conteneurs Docker
- **Définition** : Instance exécutable d'une image
- **État** : Peut être démarré, arrêté, supprimé
- **Isolation** : Processus isolé avec son propre système de fichiers
- **Éphémère** : Les données sont perdues à la suppression (sauf volumes)

#### Cycle de Vie

```
Dockerfile → Build → Image → Run → Container
     ↑                              ↓
     └──────── Commit ←──────────────┘
```

### Registries et Repositories

#### Docker Hub
- **Registry public** : Hub central pour les images Docker
- **Images officielles** : Maintenues par Docker Inc.
- **Images communautaires** : Créées par la communauté
- **Images privées** : Stockage sécurisé pour les entreprises

#### Registries Privés
- **Docker Registry** : Solution open source
- **Harbor** : Registry enterprise avec sécurité avancée
- **Cloud Registries** : AWS ECR, Google GCR, Azure ACR

## 2. Installation et Configuration

### Installation Docker

#### Linux (Ubuntu/Debian)
```bash
# Mise à jour des paquets
sudo apt update

# Installation des dépendances
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release

# Ajout de la clé GPG Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Ajout du repository Docker
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installation Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io

# Ajout de l'utilisateur au groupe docker
sudo usermod -aG docker $USER
```

#### Configuration Post-Installation
```bash
# Démarrage automatique
sudo systemctl enable docker
sudo systemctl start docker

# Vérification de l'installation
docker --version
docker run hello-world
```

### Docker Compose

```bash
# Installation Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Vérification
docker-compose --version
```

## 3. Commandes Docker Essentielles

### Gestion des Images

```bash
# Rechercher une image
docker search nginx

# Télécharger une image
docker pull nginx:latest

# Lister les images locales
docker images

# Supprimer une image
docker rmi nginx:latest

# Construire une image
docker build -t myapp:1.0 .

# Taguer une image
docker tag myapp:1.0 myregistry/myapp:1.0

# Pousser une image
docker push myregistry/myapp:1.0
```

### Gestion des Conteneurs

```bash
# Exécuter un conteneur
docker run -d --name webserver -p 80:80 nginx

# Lister les conteneurs actifs
docker ps

# Lister tous les conteneurs
docker ps -a

# Arrêter un conteneur
docker stop webserver

# Démarrer un conteneur
docker start webserver

# Redémarrer un conteneur
docker restart webserver

# Supprimer un conteneur
docker rm webserver

# Exécuter une commande dans un conteneur
docker exec -it webserver bash

# Voir les logs
docker logs webserver

# Suivre les logs en temps réel
docker logs -f webserver
```

### Gestion des Volumes et Réseaux

```bash
# Créer un volume
docker volume create mydata

# Lister les volumes
docker volume ls

# Inspecter un volume
docker volume inspect mydata

# Créer un réseau
docker network create mynetwork

# Lister les réseaux
docker network ls

# Connecter un conteneur à un réseau
docker network connect mynetwork webserver
```

## 4. Dockerfile - Construction d'Images

### Structure d'un Dockerfile

```dockerfile
# Image de base
FROM node:16-alpine

# Métadonnées
LABEL maintainer="dev@example.com"
LABEL version="1.0"
LABEL description="Application Node.js"

# Variables d'environnement
ENV NODE_ENV=production
ENV PORT=3000

# Répertoire de travail
WORKDIR /app

# Copie des fichiers de dépendances
COPY package*.json ./

# Installation des dépendances
RUN npm ci --only=production && \
    npm cache clean --force

# Copie du code source
COPY . .

# Exposition du port
EXPOSE 3000

# Utilisateur non-root
USER node

# Point d'entrée
ENTRYPOINT ["node"]
CMD ["server.js"]
```

### Instructions Dockerfile Principales

#### FROM
```dockerfile
# Image de base officielle
FROM ubuntu:20.04

# Image multi-stage
FROM node:16 AS builder
FROM nginx:alpine AS runtime
```

#### RUN
```dockerfile
# Commande simple
RUN apt-get update

# Commandes multiples (recommandé)
RUN apt-get update && \
    apt-get install -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

#### COPY vs ADD
```dockerfile
# COPY (recommandé pour les fichiers locaux)
COPY src/ /app/src/

# ADD (pour URLs et archives)
ADD https://example.com/file.tar.gz /tmp/
```

#### ENV et ARG
```dockerfile
# Variables d'environnement (runtime)
ENV DATABASE_URL=postgresql://localhost/mydb

# Arguments de build
ARG BUILD_VERSION=1.0
ENV VERSION=$BUILD_VERSION
```

### Bonnes Pratiques Dockerfile

#### 1. Optimisation des Layers
```dockerfile
# ❌ Mauvais : Chaque RUN crée un layer
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y vim

# ✅ Bon : Un seul layer
RUN apt-get update && \
    apt-get install -y curl vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

#### 2. Ordre des Instructions
```dockerfile
# ✅ Instructions qui changent peu en premier
FROM node:16-alpine
WORKDIR /app

# Dépendances (changent rarement)
COPY package*.json ./
RUN npm ci --only=production

# Code source (change souvent)
COPY . .

# Configuration finale
EXPOSE 3000
CMD ["npm", "start"]
```

#### 3. Multi-Stage Builds
```dockerfile
# Stage de build
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage de production
FROM node:16-alpine AS production
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY --from=builder /app/dist ./dist
EXPOSE 3000
CMD ["npm", "start"]
```

#### 4. Sécurité
```dockerfile
# Utilisateur non-root
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs

# Réduction de la surface d'attaque
FROM node:16-alpine
RUN apk add --no-cache dumb-init
ENTRYPOINT ["dumb-init", "--"]

# Scan de vulnérabilités
# docker scan myimage:latest
```

## 5. Docker Compose - Orchestration Multi-Conteneurs

### Introduction à Docker Compose

Docker Compose permet de définir et gérer des applications multi-conteneurs à l'aide d'un fichier YAML.

#### Avantages
- **Simplicité** : Configuration déclarative
- **Reproductibilité** : Environnements identiques
- **Isolation** : Réseaux et volumes dédiés
- **Scalabilité** : Mise à l'échelle facile

### Structure docker-compose.yml

```yaml
version: '3.8'

services:
  # Service web
  web:
    build: 
      context: .
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://postgres:password@db:5432/myapp
    volumes:
      - .:/app
      - /app/node_modules
    depends_on:
      - db
      - redis
    networks:
      - app-network

  # Service base de données
  db:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - app-network

  # Service cache
  redis:
    image: redis:6-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - app-network

  # Service reverse proxy
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - web
    networks:
      - app-network

volumes:
  postgres_data:
  redis_data:

networks:
  app-network:
    driver: bridge
```

### Commandes Docker Compose

```bash
# Démarrer tous les services
docker-compose up

# Démarrer en arrière-plan
docker-compose up -d

# Construire et démarrer
docker-compose up --build

# Arrêter tous les services
docker-compose down

# Arrêter et supprimer les volumes
docker-compose down -v

# Voir les logs
docker-compose logs

# Suivre les logs d'un service
docker-compose logs -f web

# Exécuter une commande
docker-compose exec web bash

# Mise à l'échelle
docker-compose up --scale web=3

# Voir l'état des services
docker-compose ps
```

### Environnements Multiples

#### Structure des Fichiers
```
project/
├── docker-compose.yml          # Base
├── docker-compose.dev.yml      # Développement
├── docker-compose.prod.yml     # Production
└── docker-compose.test.yml     # Tests
```

#### docker-compose.yml (Base)
```yaml
version: '3.8'
services:
  web:
    build: .
    environment:
      - NODE_ENV=${NODE_ENV:-development}
  db:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp
```

#### docker-compose.dev.yml (Override)
```yaml
version: '3.8'
services:
  web:
    volumes:
      - .:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    environment:
      - DEBUG=true
  db:
    ports:
      - "5432:5432"
```

#### Utilisation
```bash
# Développement
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
```

## 6. Networking Docker

### Types de Réseaux

#### Bridge (par défaut)
```bash
# Créer un réseau bridge
docker network create --driver bridge mybridge

# Utiliser le réseau
docker run --network mybridge nginx
```

#### Host
```bash
# Utiliser le réseau de l'hôte
docker run --network host nginx
```

#### None
```bash
# Aucun réseau
docker run --network none alpine
```

#### Overlay (Swarm)
```bash
# Réseau multi-hôtes
docker network create --driver overlay myoverlay
```

### Communication Inter-Conteneurs

```yaml
# docker-compose.yml
version: '3.8'
services:
  frontend:
    image: nginx
    networks:
      - web-tier
  
  backend:
    image: node:16
    networks:
      - web-tier
      - db-tier
  
  database:
    image: postgres
    networks:
      - db-tier

networks:
  web-tier:
  db-tier:
```

### Configuration Réseau Avancée

```yaml
networks:
  custom:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
          ip_range: 172.20.240.0/20
          gateway: 172.20.0.1
    driver_opts:
      com.docker.network.bridge.name: custom-bridge
```

## 7. Volumes et Persistance des Données

### Types de Volumes

#### Named Volumes
```bash
# Créer un volume nommé
docker volume create mydata

# Utiliser le volume
docker run -v mydata:/data nginx
```

#### Bind Mounts
```bash
# Monter un répertoire hôte
docker run -v /host/path:/container/path nginx

# Avec docker-compose
volumes:
  - ./host-dir:/container-dir
```

#### tmpfs Mounts
```bash
# Volume en mémoire
docker run --tmpfs /tmp nginx
```

### Stratégies de Sauvegarde

#### Sauvegarde de Volumes
```bash
# Créer une sauvegarde
docker run --rm -v mydata:/data -v $(pwd):/backup alpine tar czf /backup/backup.tar.gz -C /data .

# Restaurer une sauvegarde
docker run --rm -v mydata:/data -v $(pwd):/backup alpine tar xzf /backup/backup.tar.gz -C /data
```

#### Sauvegarde de Base de Données
```bash
# PostgreSQL
docker exec postgres pg_dump -U user dbname > backup.sql

# MySQL
docker exec mysql mysqldump -u user -p dbname > backup.sql
```

## 8. Sécurité Docker

### Bonnes Pratiques de Sécurité

#### 1. Images de Base Sécurisées
```dockerfile
# Utiliser des images officielles
FROM node:16-alpine

# Scanner les vulnérabilités
# docker scan myimage:latest

# Utiliser des images distroless
FROM gcr.io/distroless/nodejs:16
```

#### 2. Utilisateurs Non-Root
```dockerfile
# Créer un utilisateur dédié
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Changer de propriétaire
COPY --chown=nextjs:nodejs . .

# Utiliser l'utilisateur
USER nextjs
```

#### 3. Réduction de la Surface d'Attaque
```dockerfile
# Image minimale
FROM alpine:3.14

# Supprimer les outils inutiles
RUN apk add --no-cache nodejs npm && \
    apk del --no-cache build-dependencies
```

#### 4. Secrets Management
```bash
# Utiliser Docker secrets (Swarm)
echo "mysecret" | docker secret create db_password -

# Avec docker-compose
secrets:
  db_password:
    file: ./db_password.txt
```

### Configuration Sécurisée

#### Daemon Docker
```json
// /etc/docker/daemon.json
{
  "icc": false,
  "userland-proxy": false,
  "no-new-privileges": true,
  "seccomp-profile": "/etc/docker/seccomp.json"
}
```

#### Runtime Security
```bash
# Limiter les capacités
docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE nginx

# Mode read-only
docker run --read-only nginx

# Limiter les ressources
docker run --memory=512m --cpus=1 nginx
```

## 9. Monitoring et Logging

### Logging Docker

#### Configuration des Logs
```bash
# Configurer le driver de logs
docker run --log-driver=json-file --log-opt max-size=10m nginx

# Voir les logs
docker logs container_name

# Logs en temps réel
docker logs -f container_name
```

#### Centralisation des Logs
```yaml
# docker-compose.yml avec ELK
version: '3.8'
services:
  app:
    image: myapp
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
  
  logstash:
    image: logstash:7.15.0
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
```

### Monitoring des Conteneurs

#### Métriques de Base
```bash
# Statistiques en temps réel
docker stats

# Utilisation des ressources
docker system df

# Événements Docker
docker events
```

#### Monitoring avec Prometheus
```yaml
# docker-compose.yml
version: '3.8'
services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
  
  cadvisor:
    image: gcr.io/cadvisor/cadvisor
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:rw
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
```

### Health Checks

#### Dockerfile Health Check
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

#### Docker Compose Health Check
```yaml
services:
  web:
    image: nginx
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## 10. Optimisation des Performances

### Optimisation des Images

#### Réduction de la Taille
```dockerfile
# Multi-stage build
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force
COPY --from=builder /app/dist ./dist
CMD ["npm", "start"]
```

#### Cache des Layers
```dockerfile
# Optimiser l'ordre des instructions
FROM node:16-alpine

# Copier d'abord les fichiers qui changent peu
COPY package*.json ./
RUN npm ci --only=production

# Copier le code en dernier
COPY . .
```

### Optimisation Runtime

#### Limites de Ressources
```yaml
services:
  web:
    image: myapp
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

#### Configuration JVM (Java)
```dockerfile
ENV JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC"
```

## Conclusion

Docker a transformé la façon dont nous développons, testons et déployons les applications. La maîtrise de cette technologie est essentielle pour tout professionnel DevOps moderne.

Les concepts et pratiques couverts dans ce module vous donnent les bases solides nécessaires pour :
- Conteneuriser efficacement vos applications
- Orchestrer des environnements complexes
- Appliquer les bonnes pratiques de sécurité
- Optimiser les performances en production

## Exercices Pratiques

Ce module comprend des exercices pratiques progressifs qui vous permettront de maîtriser Docker de manière concrète.

### Environnement de Laboratoire

Les exercices utilisent un environnement Docker complet avec :
- **Registry local** : Pour stocker vos images
- **Applications d'exemple** : Node.js, Python, Go
- **Bases de données** : PostgreSQL, Redis, MongoDB
- **Outils de monitoring** : Prometheus, Grafana
- **Reverse proxy** : Nginx avec SSL

### Exercice 1 : Premiers Pas avec Docker
**Durée :** 60 minutes  
**Objectifs :**
- Manipuler les commandes Docker de base
- Créer et gérer des conteneurs
- Comprendre les images et les layers
- Utiliser les volumes et réseaux

### Exercice 2 : Construction d'Images Personnalisées
**Durée :** 90 minutes  
**Objectifs :**
- Écrire des Dockerfiles optimisés
- Implémenter des multi-stage builds
- Appliquer les bonnes pratiques de sécurité
- Optimiser la taille des images

### Exercice 3 : Orchestration avec Docker Compose
**Durée :** 120 minutes  
**Objectifs :**
- Créer des applications multi-conteneurs
- Configurer les réseaux et volumes
- Gérer les environnements multiples
- Implémenter le monitoring et les logs

### Exercice 4 : Application Web Complète
**Durée :** 150 minutes  
**Objectifs :**
- Déployer une stack complète (frontend, backend, database)
- Configurer un reverse proxy avec SSL
- Implémenter les health checks
- Mettre en place le monitoring

### Démarrage des Exercices

Pour commencer les exercices pratiques :

```bash
# Naviguer vers le laboratoire Docker
cd docker-environments/docker-basics

# Démarrer l'environnement
./start-lab.sh

# Consulter l'aide
./help.sh

# Commencer le premier exercice
cd exercises/01-docker-fundamentals
cat README.md
```

### Validation

Chaque exercice inclut des scripts de validation automatique qui vérifient :
- La création correcte des images et conteneurs
- La configuration des réseaux et volumes
- Le fonctionnement des applications
- L'application des bonnes pratiques

## Prochaines Étapes

Dans le module suivant, nous explorerons Kubernetes, la plateforme d'orchestration de conteneurs qui étend les concepts Docker à l'échelle de clusters de production.

{% include references.html module_id="05-docker" %}