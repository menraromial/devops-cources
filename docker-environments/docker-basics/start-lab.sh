#!/bin/bash

# Docker Basics Lab - Script de démarrage
# Ce script initialise l'environnement Docker complet pour les exercices

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérification des prérequis
check_prerequisites() {
    log_info "Vérification des prérequis..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker n'est pas installé. Veuillez installer Docker avant de continuer."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose n'est pas installé. Veuillez installer Docker Compose avant de continuer."
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker n'est pas démarré. Veuillez démarrer Docker avant de continuer."
        exit 1
    fi
    
    log_success "Prérequis vérifiés avec succès"
}

# Nettoyage des ressources existantes
cleanup_existing() {
    log_info "Nettoyage des ressources existantes..."
    
    # Arrêter les conteneurs existants
    docker-compose down --remove-orphans 2>/dev/null || true
    
    # Supprimer les images orphelines
    docker image prune -f 2>/dev/null || true
    
    log_success "Nettoyage terminé"
}

# Construction des images personnalisées
build_images() {
    log_info "Construction des images Docker personnalisées..."
    
    # Construire toutes les images en parallèle
    docker-compose build --parallel
    
    log_success "Images construites avec succès"
}

# Démarrage des services
start_services() {
    log_info "Démarrage des services Docker..."
    
    # Démarrer les services de base d'abord
    log_info "Démarrage des services de base (bases de données, registry)..."
    docker-compose up -d registry postgres redis mongodb
    
    # Attendre que les bases de données soient prêtes
    log_info "Attente de la disponibilité des bases de données..."
    sleep 10
    
    # Démarrer les applications
    log_info "Démarrage des applications..."
    docker-compose up -d nodejs-app python-app go-app
    
    # Démarrer le monitoring
    log_info "Démarrage du monitoring..."
    docker-compose up -d prometheus grafana cadvisor
    
    # Démarrer le reverse proxy
    log_info "Démarrage du reverse proxy..."
    docker-compose up -d nginx
    
    log_success "Tous les services sont démarrés"
}

# Vérification de l'état des services
check_services() {
    log_info "Vérification de l'état des services..."
    
    # Attendre que tous les services soient prêts
    sleep 15
    
    # Vérifier les services critiques
    services=("registry" "postgres" "redis" "nodejs-app" "python-app" "go-app")
    
    for service in "${services[@]}"; do
        if docker-compose ps | grep -q "$service.*Up"; then
            log_success "$service est opérationnel"
        else
            log_warning "$service n'est pas encore prêt"
        fi
    done
}

# Affichage des informations de connexion
show_connection_info() {
    echo ""
    echo "=================================="
    echo "🐳 Docker Basics Lab - Prêt ! 🐳"
    echo "=================================="
    echo ""
    echo "📋 Services disponibles :"
    echo ""
    echo "🔧 Applications :"
    echo "  • Node.js App    : http://localhost:3000"
    echo "  • Python App     : http://localhost:5001"
    echo "  • Go App         : http://localhost:8080"
    echo "  • Nginx Proxy    : http://localhost"
    echo ""
    echo "💾 Bases de données :"
    echo "  • PostgreSQL     : localhost:5432 (labuser/labpass)"
    echo "  • Redis          : localhost:6379"
    echo "  • MongoDB        : localhost:27017 (admin/password)"
    echo ""
    echo "📊 Monitoring :"
    echo "  • Prometheus     : http://localhost:9090"
    echo "  • Grafana        : http://localhost:3001 (admin/admin)"
    echo "  • cAdvisor       : http://localhost:8081"
    echo ""
    echo "🏪 Registry :"
    echo "  • Docker Registry: http://localhost:5000"
    echo ""
    echo "📚 Commandes utiles :"
    echo "  • Voir les logs  : docker-compose logs [service]"
    echo "  • État services  : docker-compose ps"
    echo "  • Arrêter tout   : docker-compose down"
    echo "  • Aide complète  : ./help.sh"
    echo ""
    echo "🎯 Commencer les exercices :"
    echo "  cd exercises/01-docker-fundamentals"
    echo "  cat README.md"
    echo ""
    echo "=================================="
}

# Fonction principale
main() {
    echo "🚀 Démarrage du Docker Basics Lab..."
    echo ""
    
    check_prerequisites
    cleanup_existing
    build_images
    start_services
    check_services
    show_connection_info
    
    log_success "Environnement Docker Basics Lab prêt à l'utilisation !"
}

# Gestion des signaux pour un arrêt propre
trap 'log_warning "Arrêt du script..."; docker-compose down; exit 1' INT TERM

# Exécution du script principal
main "$@"