# Exercice 2 : Custom Images

**Durée estimée :** 90 minutes  
**Niveau :** Intermédiaire  
**Prérequis :** Exercice 1 complété

## Objectifs

À la fin de cet exercice, vous serez capable de :
- Écrire des Dockerfiles optimisés et sécurisés
- Implémenter des multi-stage builds
- Appliquer les bonnes pratiques de construction d'images
- Optimiser la taille et les performances des images
- Gérer les layers et le cache Docker

## Contexte

Dans cet exercice, vous allez apprendre à créer vos propres images Docker personnalisées. Vous découvrirez les techniques d'optimisation et les bonnes pratiques pour créer des images efficaces et sécurisées.

## Prérequis Techniques

- Exercice 1 complété avec succès
- Environnement Docker Lab démarré
- Éditeur de texte pour créer les Dockerfiles

## Étapes de l'Exercice

### Étape 1 : Premier Dockerfile Simple (20 minutes)

#### 1.1 Application Web Simple
Créez un répertoire de travail et une application web basique :

```bash
mkdir -p ~/docker-lab/custom-images/simple-web
cd ~/docker-lab/custom-images/simple-web

# Créer une page HTML simple
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Mon App Docker</title>
    <style>
        body { font-family: Arial; text-align: center; margin-top: 50px; }
        .container { max-width: 600px; margin: 0 auto; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🐳 Mon Application Docker</h1>
        <p>Cette page est servie depuis un conteneur Docker personnalisé !</p>
        <p>Version: 1.0</p>
    </div>
</body>
</html>
EOF
```

#### 1.2 Premier Dockerfile
Créez votre premier Dockerfile :

```bash
cat > Dockerfile << 'EOF'
FROM nginx:alpine

# Copier notre page HTML
COPY index.html /usr/share/nginx/html/

# Exposer le port 80
EXPOSE 80

# La commande par défaut est déjà définie dans l'image nginx
EOF
```

#### 1.3 Construction et Test
```bash
# Construire l'image
docker build -t mon-app-web:v1 .

# Vérifier que l'image a été créée
docker images | grep mon-app-web

# Tester l'image
docker run -d --name test-web -p 8093:80 mon-app-web:v1

# Vérifier que ça fonctionne
curl http://localhost:8093

# Nettoyer
docker stop test-web && docker rm test-web
```

**Point de vérification :** Vous devriez voir votre page HTML personnalisée.

### Étape 2 : Dockerfile Optimisé (25 minutes)

#### 2.1 Application Node.js
Créez une application Node.js plus complexe :

```bash
mkdir -p ~/docker-lab/custom-images/nodejs-optimized
cd ~/docker-lab/custom-images/nodejs-optimized

# Créer package.json
cat > package.json << 'EOF'
{
  "name": "docker-optimized-app",
  "version": "1.0.0",
  "description": "Application Node.js optimisée pour Docker",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

# Créer l'application
cat > server.js << 'EOF'
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
    res.json({
        message: '🚀 Application Node.js Optimisée',
        version: '1.0.0',
        timestamp: new Date().toISOString(),
        hostname: require('os').hostname()
    });
});

app.get('/health', (req, res) => {
    res.json({ status: 'healthy', uptime: process.uptime() });
});

app.listen(PORT, () => {
    console.log(`Serveur démarré sur le port ${PORT}`);
});
EOF
```

#### 2.2 Dockerfile Non-Optimisé (à éviter)
```bash
cat > Dockerfile.bad << 'EOF'
FROM node:18

WORKDIR /app

# ❌ Mauvaise pratique : copier tout d'abord
COPY . .

# ❌ Mauvaise pratique : installer en tant que root
RUN npm install

EXPOSE 3000

CMD ["npm", "start"]
EOF
```

#### 2.3 Dockerfile Optimisé
```bash
cat > Dockerfile << 'EOF'
FROM node:18-alpine

# Créer un utilisateur non-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

# ✅ Bonne pratique : copier package.json d'abord pour optimiser le cache
COPY package*.json ./

# ✅ Installer les dépendances avant de copier le code
RUN npm ci --only=production && \
    npm cache clean --force

# ✅ Copier le code après l'installation des dépendances
COPY --chown=nodejs:nodejs . .

# ✅ Utiliser un utilisateur non-root
USER nodejs

EXPOSE 3000

# ✅ Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) }).on('error', () => process.exit(1))"

CMD ["node", "server.js"]
EOF
```

#### 2.4 Comparaison des Tailles
```bash
# Construire les deux versions
docker build -f Dockerfile.bad -t nodejs-bad:v1 .
docker build -f Dockerfile -t nodejs-optimized:v1 .

# Comparer les tailles
docker images | grep nodejs

# Tester la version optimisée
docker run -d --name nodejs-test -p 8094:3000 nodejs-optimized:v1
curl http://localhost:8094
curl http://localhost:8094/health

# Nettoyer
docker stop nodejs-test && docker rm nodejs-test
```

**Point de vérification :** L'image optimisée doit être plus petite et plus sécurisée.

### Étape 3 : Multi-Stage Build (25 minutes)

#### 3.1 Application Go avec Multi-Stage
```bash
mkdir -p ~/docker-lab/custom-images/go-multistage
cd ~/docker-lab/custom-images/go-multistage

# Créer go.mod
cat > go.mod << 'EOF'
module docker-multistage-app

go 1.21

require github.com/gin-gonic/gin v1.9.1
EOF

# Créer l'application Go
cat > main.go << 'EOF'
package main

import (
    "net/http"
    "os"
    "github.com/gin-gonic/gin"
)

func main() {
    r := gin.Default()
    
    r.GET("/", func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{
            "message": "🐹 Application Go Multi-Stage",
            "version": "1.0.0",
            "hostname": getHostname(),
        })
    })
    
    r.GET("/health", func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{"status": "healthy"})
    })
    
    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }
    
    r.Run(":" + port)
}

func getHostname() string {
    hostname, _ := os.Hostname()
    return hostname
}
EOF
```

#### 3.2 Dockerfile Multi-Stage
```bash
cat > Dockerfile << 'EOF'
# Stage 1: Build
FROM golang:1.21-alpine AS builder

# Installer les dépendances de build
RUN apk add --no-cache git ca-certificates tzdata

# Créer un utilisateur non-root
RUN adduser -D -g '' appuser

WORKDIR /build

# Copier les fichiers de dépendances
COPY go.mod go.sum ./

# Télécharger les dépendances
RUN go mod download

# Copier le code source
COPY . .

# Compiler l'application
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags='-w -s -extldflags "-static"' \
    -a -installsuffix cgo \
    -o app .

# Stage 2: Production
FROM scratch

# Copier les certificats CA
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copier les informations de timezone
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

# Copier les informations utilisateur
COPY --from=builder /etc/passwd /etc/passwd

# Copier l'exécutable
COPY --from=builder /build/app /app

# Utiliser l'utilisateur non-root
USER appuser

EXPOSE 8080

ENTRYPOINT ["/app"]
EOF
```

#### 3.3 Comparaison avec Build Simple
```bash
# Dockerfile simple (pour comparaison)
cat > Dockerfile.simple << 'EOF'
FROM golang:1.21-alpine

WORKDIR /app
COPY . .
RUN go mod download
RUN go build -o app .

EXPOSE 8080
CMD ["./app"]
EOF

# Construire les deux versions
docker build -f Dockerfile.simple -t go-simple:v1 .
docker build -f Dockerfile -t go-multistage:v1 .

# Comparer les tailles
docker images | grep go-

# Tester la version multi-stage
docker run -d --name go-test -p 8095:8080 go-multistage:v1
curl http://localhost:8095
curl http://localhost:8095/health

# Nettoyer
docker stop go-test && docker rm go-test
```

**Point de vérification :** L'image multi-stage doit être drastiquement plus petite (quelques MB vs centaines de MB).

### Étape 4 : Optimisation Avancée (20 minutes)

#### 4.1 Utilisation du .dockerignore
```bash
cd ~/docker-lab/custom-images/nodejs-optimized

# Créer un .dockerignore
cat > .dockerignore << 'EOF'
node_modules
npm-debug.log*
.git
.gitignore
README.md
Dockerfile*
.dockerignore
.nyc_output
coverage
.env
EOF

# Reconstruire avec .dockerignore
docker build -t nodejs-optimized:v2 .
```

#### 4.2 Optimisation des Layers
```bash
mkdir -p ~/docker-lab/custom-images/layer-optimization
cd ~/docker-lab/custom-images/layer-optimization

# Dockerfile avec trop de layers (à éviter)
cat > Dockerfile.bad << 'EOF'
FROM ubuntu:20.04

# ❌ Chaque RUN crée un layer
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y vim
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

COPY app.sh /app.sh
RUN chmod +x /app.sh

CMD ["/app.sh"]
EOF

# Dockerfile optimisé
cat > Dockerfile << 'EOF'
FROM ubuntu:20.04

# ✅ Un seul RUN pour minimiser les layers
RUN apt-get update && \
    apt-get install -y \
        curl \
        wget \
        vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY app.sh /app.sh
RUN chmod +x /app.sh

CMD ["/app.sh"]
EOF

# Créer un script simple
cat > app.sh << 'EOF'
#!/bin/bash
echo "Application optimisée pour les layers"
sleep 3600
EOF

# Construire et comparer
docker build -f Dockerfile.bad -t layer-bad:v1 .
docker build -f Dockerfile -t layer-optimized:v1 .

# Analyser les layers
docker history layer-bad:v1
echo "---"
docker history layer-optimized:v1
```

**Point de vérification :** La version optimisée doit avoir moins de layers.

## Validation

Exécutez le script de validation :

```bash
./validate.sh
```

## Défis Bonus (Optionnel)

### Défi 1 : Image Python Ultra-Légère
Créez une image Python avec une application Flask qui fait moins de 50MB.

### Défi 2 : Build Conditionnel
Créez un Dockerfile qui peut construire différentes versions (dev/prod) selon un argument de build.

### Défi 3 : Sécurité Avancée
Implémentez toutes les bonnes pratiques de sécurité dans un Dockerfile.

## Points Clés à Retenir

1. **Ordre des instructions** : Placez les instructions qui changent peu en premier
2. **Multi-stage builds** : Séparez la compilation de l'exécution
3. **Utilisateurs non-root** : Toujours utiliser un utilisateur dédié
4. **Cache des layers** : Optimisez pour réutiliser le cache Docker
5. **Taille des images** : Utilisez des images de base minimales
6. **Sécurité** : Scannez les vulnérabilités et appliquez les bonnes pratiques

## Prochaines Étapes

Une fois cet exercice validé, passez à l'exercice 3 : "Docker Compose" pour apprendre l'orchestration multi-conteneurs.

## Ressources Supplémentaires

- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/dockerfile_best-practices/)
- [Multi-stage Builds](https://docs.docker.com/develop/dev-best-practices/dockerfile_best-practices/#use-multi-stage-builds)
- [Docker Security](https://docs.docker.com/engine/security/)