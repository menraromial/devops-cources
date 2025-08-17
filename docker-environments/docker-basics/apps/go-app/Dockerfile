# Dockerfile pour l'application Go
# Exemple d'optimisation avec multi-stage build

# Stage 1: Build
FROM golang:1.21-alpine AS builder

# Métadonnées du stage de build
LABEL stage=builder

# Installer les dépendances nécessaires pour la compilation
RUN apk add --no-cache git ca-certificates tzdata

# Créer un utilisateur non-root pour la compilation
RUN adduser -D -g '' appuser

# Définir le répertoire de travail
WORKDIR /build

# Copier les fichiers de dépendances Go
COPY go.mod go.sum ./

# Télécharger les dépendances
RUN go mod download
RUN go mod verify

# Copier le code source
COPY . .

# Compiler l'application avec optimisations
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags='-w -s -extldflags "-static"' \
    -a -installsuffix cgo \
    -o app .

# Stage 2: Production
FROM scratch AS production

# Métadonnées
LABEL maintainer="docker-lab@example.com"
LABEL version="1.0.0"
LABEL description="Application Go pour le Docker Lab"

# Copier les certificats CA pour les connexions HTTPS
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copier les informations de timezone
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

# Copier les informations utilisateur
COPY --from=builder /etc/passwd /etc/passwd

# Copier l'exécutable
COPY --from=builder /build/app /app

# Utiliser l'utilisateur non-root
USER appuser

# Exposer le port
EXPOSE 8080

# Variables d'environnement
ENV GIN_MODE=release
ENV PORT=8080

# Health check (nécessite un shell, donc on utilise une approche différente)
# Le health check sera géré par l'orchestrateur ou l'application elle-même

# Point d'entrée
ENTRYPOINT ["/app"]