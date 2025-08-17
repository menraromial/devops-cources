# Exercice 2 : Introduction à Docker

## Objectifs

À la fin de cet exercice, vous serez capable de :
- Comprendre les concepts fondamentaux des containers Docker
- Créer et manipuler des images Docker
- Gérer le cycle de vie des containers
- Utiliser Docker Compose pour orchestrer plusieurs services
- Appliquer les bonnes pratiques de containerisation

## Durée Estimée
60 minutes

## Prérequis

- Exercice 1 (Git) terminé
- Docker et Docker Compose installés et fonctionnels
- Accès au container devtools

## Étape 1 : Découverte de Docker

### 1.1 Vérification de l'Installation

```bash
# Se connecter au container devtools
docker exec -it fundamentals-devtools bash

# Installer Docker CLI dans le container (si nécessaire)
apt-get update && apt-get install -y docker.io

# Vérifier la version de Docker
docker --version

# Vérifier que Docker fonctionne
docker run hello-world
```

### 1.2 Exploration des Images Docker

```bash
# Lister les images disponibles localement
docker images

# Rechercher des images sur Docker Hub
docker search nginx

# Télécharger une image
docker pull nginx:alpine

# Examiner les détails d'une image
docker inspect nginx:alpine

# Voir l'historique des layers d'une image
docker history nginx:alpine
```

## Étape 2 : Manipulation des Containers

### 2.1 Créer et Gérer des Containers

```bash
# Créer un workspace pour cet exercice
mkdir -p /workspace/02-docker-intro
cd /workspace/02-docker-intro

# Lancer un container nginx en mode détaché
docker run -d --name mon-nginx -p 8080:80 nginx:alpine

# Vérifier que le container fonctionne
docker ps

# Tester l'accès au serveur web
curl http://localhost:8080

# Voir les logs du container
docker logs mon-nginx

# Exécuter une commande dans le container
docker exec -it mon-nginx sh

# Dans le container nginx, explorer le système de fichiers
ls -la /usr/share/nginx/html/
cat /usr/share/nginx/html/index.html
exit

# Arrêter et supprimer le container
docker stop mon-nginx
docker rm mon-nginx
```

### 2.2 Volumes et Persistance des Données

```bash
# Créer un dossier pour le contenu web
mkdir -p html-content
echo "<h1>Mon Site DevOps</h1><p>Exercice Docker Fundamentals</p>" > html-content/index.html

# Lancer nginx avec un volume monté
docker run -d --name nginx-avec-volume \
  -p 8080:80 \
  -v $(pwd)/html-content:/usr/share/nginx/html:ro \
  nginx:alpine

# Tester le contenu personnalisé
curl http://localhost:8080

# Modifier le contenu et voir les changements
echo "<h1>Site Mis à Jour</h1><p>Les volumes permettent la persistance!</p>" > html-content/index.html
curl http://localhost:8080

# Nettoyer
docker stop nginx-avec-volume
docker rm nginx-avec-volume
```

## Étape 3 : Création d'Images Docker

### 3.1 Dockerfile Simple

```bash
# Créer une application Python simple
cat > app.py << 'EOF'
#!/usr/bin/env python3
from http.server import HTTPServer, SimpleHTTPRequestHandler
import json
import os
from datetime import datetime

class CustomHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            response = {
                'message': 'Hello from Docker!',
                'timestamp': datetime.now().isoformat(),
                'hostname': os.getenv('HOSTNAME', 'unknown'),
                'version': '1.0.0'
            }
            
            self.wfile.write(json.dumps(response, indent=2).encode())
        else:
            super().do_GET()

if __name__ == '__main__':
    port = int(os.getenv('PORT', 8000))
    server = HTTPServer(('0.0.0.0', port), CustomHandler)
    print(f'Server running on port {port}')
    server.serve_forever()
EOF

# Créer un Dockerfile
cat > Dockerfile << 'EOF'
# Utiliser une image de base Python officielle
FROM python:3.11-slim

# Définir le répertoire de travail
WORKDIR /app

# Copier l'application
COPY app.py .

# Créer un utilisateur non-root pour la sécurité
RUN useradd --create-home --shell /bin/bash appuser && \
    chown -R appuser:appuser /app

# Changer vers l'utilisateur non-root
USER appuser

# Exposer le port
EXPOSE 8000

# Définir les variables d'environnement
ENV PORT=8000
ENV PYTHONUNBUFFERED=1

# Commande par défaut
CMD ["python", "app.py"]
EOF

# Construire l'image
docker build -t mon-app-python:1.0 .

# Vérifier que l'image a été créée
docker images | grep mon-app-python
```

### 3.2 Tester l'Image Créée

```bash
# Lancer un container avec notre image
docker run -d --name test-app -p 8001:8000 mon-app-python:1.0

# Tester l'application
curl http://localhost:8001

# Voir les logs
docker logs test-app

# Nettoyer
docker stop test-app
docker rm test-app
```

## Étape 4 : Docker Compose

### 4.1 Application Multi-Services

```bash
# Créer un fichier docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # Application web
  web:
    build: .
    ports:
      - "8001:8000"
    environment:
      - PORT=8000
      - DB_HOST=redis
    depends_on:
      - redis
    networks:
      - app-network

  # Base de données Redis
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      - app-network

  # Nginx comme reverse proxy
  nginx:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - web
    networks:
      - app-network

volumes:
  redis-data:

networks:
  app-network:
    driver: bridge
EOF

# Créer la configuration Nginx
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream app {
        server web:8000;
    }

    server {
        listen 80;
        
        location / {
            proxy_pass http://app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF
```

### 4.2 Déployer avec Docker Compose

```bash
# Construire et démarrer tous les services
docker-compose up -d

# Vérifier l'état des services
docker-compose ps

# Voir les logs de tous les services
docker-compose logs

# Tester l'application via Nginx
curl http://localhost:8080

# Tester le health check
curl http://localhost:8080/health

# Voir les logs d'un service spécifique
docker-compose logs web

# Redémarrer un service
docker-compose restart web
```

## Étape 5 : Bonnes Pratiques Docker

### 5.1 Optimisation des Images

```bash
# Créer un Dockerfile optimisé
cat > Dockerfile.optimized << 'EOF'
# Multi-stage build pour réduire la taille
FROM python:3.11-slim as builder

# Installer les dépendances de build
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Stage final
FROM python:3.11-slim

# Installer seulement les dépendances runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Créer un utilisateur non-root
RUN useradd --create-home --shell /bin/bash --uid 1000 appuser

# Définir le répertoire de travail
WORKDIR /app

# Copier l'application
COPY --chown=appuser:appuser app.py .

# Changer vers l'utilisateur non-root
USER appuser

# Exposer le port
EXPOSE 8000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# Variables d'environnement
ENV PORT=8000 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Commande par défaut
CMD ["python", "app.py"]
EOF

# Construire l'image optimisée
docker build -f Dockerfile.optimized -t mon-app-python:optimized .

# Comparer les tailles
docker images | grep mon-app-python
```

### 5.2 Sécurité et .dockerignore

```bash
# Créer un fichier .dockerignore
cat > .dockerignore << 'EOF'
# Git
.git
.gitignore

# Documentation
README.md
*.md

# Logs
*.log

# Temporary files
*.tmp
*.swp
*.swo

# IDE files
.vscode/
.idea/

# Python
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/

# Docker
Dockerfile*
docker-compose*.yml
.dockerignore

# OS files
.DS_Store
Thumbs.db
EOF

# Reconstruire avec .dockerignore
docker build -t mon-app-python:secure .
```

## Étape 6 : Monitoring et Debugging

### 6.1 Inspection et Debugging

```bash
# Inspecter un container en cours d'exécution
docker inspect web

# Voir les statistiques d'utilisation des ressources
docker stats

# Voir les processus dans un container
docker exec web ps aux

# Copier des fichiers depuis/vers un container
echo "Debug info" > debug.txt
docker cp debug.txt web:/tmp/
docker exec web cat /tmp/debug.txt

# Voir l'utilisation de l'espace disque
docker system df

# Nettoyer les ressources inutilisées
docker system prune -f
```

### 6.2 Logs et Monitoring

```bash
# Suivre les logs en temps réel
docker-compose logs -f web

# Voir les logs avec timestamps
docker-compose logs -t web

# Limiter le nombre de lignes de logs
docker-compose logs --tail=50 web

# Exporter les logs
docker-compose logs web > app.log
```

## Validation

Exécuter le script de validation pour vérifier que vous avez correctement réalisé l'exercice :

```bash
cd /workspace/02-docker-intro
./validate.sh
```

## Nettoyage

```bash
# Arrêter et supprimer tous les services
docker-compose down -v

# Supprimer les images créées (optionnel)
docker rmi mon-app-python:1.0 mon-app-python:optimized mon-app-python:secure
```

## Points Clés à Retenir

1. **Images vs Containers** : Les images sont des templates, les containers sont des instances
2. **Layers** : Docker utilise un système de layers pour optimiser le stockage
3. **Volumes** : Utilisez des volumes pour la persistance des données
4. **Multi-stage builds** : Optimisez la taille des images
5. **Sécurité** : Utilisez des utilisateurs non-root et des images de base minimales
6. **Docker Compose** : Orchestrez des applications multi-services
7. **Monitoring** : Surveillez les ressources et les logs

## Ressources Supplémentaires

- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Best Practices](https://docs.docker.com/develop/best-practices/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)

## Prochaine Étape

Une fois cet exercice terminé, passez à l'Exercice 3 : Pipeline CI/CD avec Jenkins.