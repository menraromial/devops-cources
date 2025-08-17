#!/bin/bash

# Docker Basics Lab - Aide et commandes utiles

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

show_help() {
    echo ""
    echo "🐳 Docker Basics Lab - Guide d'aide"
    echo "===================================="
    echo ""
    
    echo -e "${BLUE}📋 Gestion de l'environnement :${NC}"
    echo "  ./start-lab.sh              Démarrer l'environnement complet"
    echo "  docker-compose up -d        Démarrer tous les services"
    echo "  docker-compose down         Arrêter tous les services"
    echo "  docker-compose ps           Voir l'état des services"
    echo "  docker-compose logs         Voir tous les logs"
    echo "  docker-compose logs [service] Voir les logs d'un service"
    echo ""
    
    echo -e "${GREEN}🔧 Commandes Docker utiles :${NC}"
    echo "  docker ps                   Lister les conteneurs actifs"
    echo "  docker ps -a                Lister tous les conteneurs"
    echo "  docker images               Lister les images"
    echo "  docker exec -it [container] bash  Se connecter à un conteneur"
    echo "  docker logs [container]     Voir les logs d'un conteneur"
    echo "  docker stats                Voir l'utilisation des ressources"
    echo ""
    
    echo -e "${YELLOW}🏗️ Construction d'images :${NC}"
    echo "  docker build -t myapp .     Construire une image"
    echo "  docker build --no-cache .   Construire sans cache"
    echo "  docker tag myapp:latest localhost:5000/myapp:latest"
    echo "  docker push localhost:5000/myapp:latest"
    echo ""
    
    echo -e "${CYAN}🌐 Services et ports :${NC}"
    echo "  Node.js App    : http://localhost:3000"
    echo "  Python App     : http://localhost:5001"
    echo "  Go App         : http://localhost:8080"
    echo "  Nginx Proxy    : http://localhost"
    echo "  PostgreSQL     : localhost:5432"
    echo "  Redis          : localhost:6379"
    echo "  MongoDB        : localhost:27017"
    echo "  Prometheus     : http://localhost:9090"
    echo "  Grafana        : http://localhost:3001"
    echo "  cAdvisor       : http://localhost:8081"
    echo "  Registry       : http://localhost:5000"
    echo ""
    
    echo -e "${BLUE}💾 Connexions aux bases de données :${NC}"
    echo "  PostgreSQL:"
    echo "    docker exec -it postgres-db psql -U labuser -d labdb"
    echo "    Connexion externe: psql -h localhost -U labuser -d labdb"
    echo ""
    echo "  Redis:"
    echo "    docker exec -it redis-cache redis-cli"
    echo "    Connexion externe: redis-cli -h localhost"
    echo ""
    echo "  MongoDB:"
    echo "    docker exec -it mongodb mongo -u admin -p password"
    echo ""
    
    echo -e "${GREEN}🎯 Exercices disponibles :${NC}"
    echo "  cd exercises/01-docker-fundamentals  # Bases de Docker"
    echo "  cd exercises/02-custom-images        # Images personnalisées"
    echo "  cd exercises/03-docker-compose       # Orchestration"
    echo "  cd exercises/04-production-ready     # Production"
    echo ""
    
    echo -e "${YELLOW}🔍 Debugging et dépannage :${NC}"
    echo "  docker-compose logs [service]        Logs d'un service"
    echo "  docker exec -it [container] bash     Shell dans un conteneur"
    echo "  docker inspect [container]          Détails d'un conteneur"
    echo "  docker system df                    Utilisation de l'espace"
    echo "  docker system prune                 Nettoyer les ressources"
    echo ""
    
    echo -e "${RED}🧹 Nettoyage :${NC}"
    echo "  docker-compose down                 Arrêter les services"
    echo "  docker-compose down -v              Arrêter et supprimer les volumes"
    echo "  docker system prune -a              Nettoyer complètement"
    echo "  docker volume prune                 Supprimer les volumes inutilisés"
    echo ""
    
    echo -e "${CYAN}📊 Monitoring :${NC}"
    echo "  docker stats                        Utilisation des ressources en temps réel"
    echo "  docker-compose top                  Processus dans les conteneurs"
    echo "  curl http://localhost:9090          Prometheus metrics"
    echo "  curl http://localhost:8081/metrics  cAdvisor metrics"
    echo ""
    
    echo -e "${BLUE}🔐 Registry local :${NC}"
    echo "  # Tagger une image pour le registry local"
    echo "  docker tag myapp:latest localhost:5000/myapp:latest"
    echo ""
    echo "  # Pousser vers le registry local"
    echo "  docker push localhost:5000/myapp:latest"
    echo ""
    echo "  # Lister les images du registry"
    echo "  curl http://localhost:5000/v2/_catalog"
    echo ""
    
    echo "===================================="
    echo "Pour plus d'aide sur un exercice spécifique :"
    echo "cd exercises/[nom-exercice] && cat README.md"
    echo ""
}

# Fonction pour afficher les services actifs
show_services() {
    echo ""
    echo -e "${GREEN}📊 État des services :${NC}"
    echo "======================"
    docker-compose ps
    echo ""
}

# Fonction pour afficher les logs récents
show_recent_logs() {
    echo ""
    echo -e "${YELLOW}📝 Logs récents (dernières 20 lignes) :${NC}"
    echo "======================================="
    docker-compose logs --tail=20
    echo ""
}

# Fonction pour tester les connexions
test_connections() {
    echo ""
    echo -e "${CYAN}🔗 Test des connexions :${NC}"
    echo "========================"
    
    services=(
        "http://localhost:3000|Node.js App"
        "http://localhost:5001|Python App"
        "http://localhost:8080|Go App"
        "http://localhost:9090|Prometheus"
        "http://localhost:3001|Grafana"
        "http://localhost:8081|cAdvisor"
        "http://localhost:5000/v2/_catalog|Registry"
    )
    
    for service in "${services[@]}"; do
        url=$(echo $service | cut -d'|' -f1)
        name=$(echo $service | cut -d'|' -f2)
        
        if curl -s --max-time 3 "$url" > /dev/null 2>&1; then
            echo -e "  ✅ $name : ${GREEN}OK${NC}"
        else
            echo -e "  ❌ $name : ${RED}NOK${NC}"
        fi
    done
    echo ""
}

# Menu principal
case "${1:-help}" in
    "help"|"-h"|"--help")
        show_help
        ;;
    "services"|"ps")
        show_services
        ;;
    "logs")
        show_recent_logs
        ;;
    "test")
        test_connections
        ;;
    "all")
        show_help
        show_services
        show_recent_logs
        test_connections
        ;;
    *)
        echo "Usage: $0 [help|services|logs|test|all]"
        echo ""
        echo "Options:"
        echo "  help     - Afficher l'aide complète (défaut)"
        echo "  services - Afficher l'état des services"
        echo "  logs     - Afficher les logs récents"
        echo "  test     - Tester les connexions aux services"
        echo "  all      - Afficher toutes les informations"
        ;;
esac