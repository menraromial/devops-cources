# Dockerfile pour l'application Node.js
# Exemple d'image optimisée avec multi-stage build

# Stage 1: Build dependencies
FROM node:18-alpine AS dependencies
LABEL stage=dependencies

WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer toutes les dépendances (dev + prod)
RUN npm ci --include=dev

# Stage 2: Build application
FROM node:18-alpine AS builder
LABEL stage=builder

WORKDIR /app

# Copier les dépendances du stage précédent
COPY --from=dependencies /app/node_modules ./node_modules
COPY package*.json ./

# Copier le code source
COPY . .

# Nettoyer les dépendances de développement
RUN npm prune --production

# Stage 3: Production image
FROM node:18-alpine AS production

# Métadonnées
LABEL maintainer="docker-lab@example.com"
LABEL version="1.0.0"
LABEL description="Application Node.js pour le Docker Lab"

# Installer dumb-init pour une gestion propre des signaux
RUN apk add --no-cache dumb-init

# Créer un utilisateur non-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers nécessaires avec les bonnes permissions
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/package*.json ./
COPY --chown=nodejs:nodejs . .

# Créer le répertoire public s'il n'existe pas
RUN mkdir -p public && chown nodejs:nodejs public

# Changer vers l'utilisateur non-root
USER nodejs

# Exposer le port
EXPOSE 3000

# Variables d'environnement par défaut
ENV NODE_ENV=production
ENV PORT=3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) }).on('error', () => process.exit(1))"

# Point d'entrée avec dumb-init
ENTRYPOINT ["dumb-init", "--"]

# Commande par défaut
CMD ["node", "server.js"]