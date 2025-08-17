# Dockerfile pour l'application Python Flask
# Exemple d'optimisation avec multi-stage build

# Stage 1: Build dependencies
FROM python:3.11-slim AS dependencies
LABEL stage=dependencies

# Installer les dépendances système nécessaires
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copier les requirements
COPY requirements.txt .

# Installer les dépendances Python
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Production image
FROM python:3.11-slim AS production

# Métadonnées
LABEL maintainer="docker-lab@example.com"
LABEL version="1.0.0"
LABEL description="Application Python Flask pour le Docker Lab"

# Installer les dépendances runtime
RUN apt-get update && apt-get install -y \
    libpq5 \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Créer un utilisateur non-root
RUN groupadd -r flask && useradd -r -g flask flask

# Créer le répertoire de l'application
WORKDIR /app

# Copier les dépendances Python du stage précédent
COPY --from=dependencies /root/.local /home/flask/.local

# Copier le code de l'application
COPY --chown=flask:flask . .

# Rendre le script exécutable
RUN chmod +x app.py

# Changer vers l'utilisateur non-root
USER flask

# Ajouter le répertoire local au PATH
ENV PATH=/home/flask/.local/bin:$PATH

# Variables d'environnement
ENV FLASK_APP=app.py
ENV FLASK_ENV=production
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1

# Exposer le port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:5000/health', timeout=3)" || exit 1

# Commande par défaut avec Gunicorn pour la production
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--timeout", "30", "app:app"]