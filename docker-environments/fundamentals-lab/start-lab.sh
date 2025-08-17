#!/bin/bash

# Script de démarrage pour le laboratoire DevOps Fundamentals
# Ce script configure et démarre tous les services nécessaires

set -e

echo "🚀 Démarrage du Laboratoire DevOps Fundamentals"
echo "=============================================="

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Vérifier que Docker est installé et fonctionne
echo -e "\n${YELLOW}1. Vérification des prérequis${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker n'est pas installé ou n'est pas dans le PATH${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose n'est pas installé ou n'est pas dans le PATH${NC}"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker n'est pas démarré ou n'est pas accessible${NC}"
    exit 1
fi

echo -e "✅ ${GREEN}Docker et Docker Compose sont disponibles${NC}"

# Vérifier l'espace disque disponible
AVAILABLE_SPACE=$(df . | tail -1 | awk '{print $4}')
REQUIRED_SPACE=10485760  # 10GB en KB

if [ "$AVAILABLE_SPACE" -lt "$REQUIRED_SPACE" ]; then
    echo -e "${YELLOW}⚠️  Attention: Espace disque faible (moins de 10GB disponible)${NC}"
    echo -e "Le laboratoire peut nécessiter plus d'espace pour fonctionner correctement."
fi

# Nettoyer les ressources existantes si nécessaire
echo -e "\n${YELLOW}2. Nettoyage des ressources existantes${NC}"

if docker-compose ps | grep -q "Up"; then
    echo -e "🧹 Arrêt des services existants..."
    docker-compose down
fi

# Supprimer les containers orphelins
docker container prune -f > /dev/null 2>&1 || true

echo -e "✅ ${GREEN}Nettoyage terminé${NC}"

# Construire et démarrer les services
echo -e "\n${YELLOW}3. Construction et démarrage des services${NC}"

echo -e "📦 Construction des images personnalisées..."
docker-compose build --no-cache

echo -e "🚀 Démarrage des services..."
docker-compose up -d

# Attendre que les services soient prêts
echo -e "\n${YELLOW}4. Vérification de l'état des services${NC}"

echo -e "⏳ Attente du démarrage des services..."
sleep 30

# Fonction pour vérifier qu'un service répond
check_service() {
    local service_name="$1"
    local url="$2"
    local max_attempts=30
    local attempt=1
    
    echo -e "🔍 Vérification de $service_name..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s -f "$url" > /dev/null 2>&1; then
            echo -e "✅ ${GREEN}$service_name est prêt${NC}"
            return 0
        fi
        
        echo -e "⏳ Tentative $attempt/$max_attempts pour $service_name..."
        sleep 5
        attempt=$((attempt + 1))
    done
    
    echo -e "❌ ${RED}$service_name n'est pas accessible après $max_attempts tentatives${NC}"
    return 1
}

# Vérifier les services
SERVICES_OK=true

check_service "Jenkins" "http://localhost:8080" || SERVICES_OK=false
check_service "Gitea" "http://localhost:3000" || SERVICES_OK=false
check_service "Sample App" "http://localhost:8000/health" || SERVICES_OK=false

# Afficher l'état final
echo -e "\n${YELLOW}5. État final des services${NC}"
docker-compose ps

if [ "$SERVICES_OK" = true ]; then
    echo -e "\n🎉 ${GREEN}Laboratoire démarré avec succès !${NC}"
    
    echo -e "\n${BLUE}📋 Informations d'accès :${NC}"
    echo -e "┌─────────────────────────────────────────────────────────┐"
    echo -e "│ ${YELLOW}Service${NC}     │ ${YELLOW}URL${NC}                    │ ${YELLOW}Identifiants${NC}      │"
    echo -e "├─────────────────────────────────────────────────────────┤"
    echo -e "│ Jenkins     │ http://localhost:8080   │ admin/admin123    │"
    echo -e "│ Gitea       │ http://localhost:3000   │ À créer           │"
    echo -e "│ Sample App  │ http://localhost:8000   │ N/A               │"
    echo -e "│ PostgreSQL  │ localhost:5433          │ devops/devops123  │"
    echo -e "└─────────────────────────────────────────────────────────┘"
    
    echo -e "\n${BLUE}🎯 Prochaines étapes :${NC}"
    echo -e "1. Créer un compte sur Gitea (http://localhost:3000)"
    echo -e "2. Se connecter à Jenkins (http://localhost:8080)"
    echo -e "3. Commencer l'Exercice 1 : Git et Contrôle de Version"
    echo -e "   ${YELLOW}cd exercises/01-git-basics && cat README.md${NC}"
    
    echo -e "\n${BLUE}📚 Documentation :${NC}"
    echo -e "- README principal : ${YELLOW}cat README.md${NC}"
    echo -e "- Exercices : ${YELLOW}cat exercises/README.md${NC}"
    echo -e "- Aide : ${YELLOW}./help.sh${NC}"
    
else
    echo -e "\n❌ ${RED}Certains services ne sont pas accessibles${NC}"
    echo -e "Vérifiez les logs avec : ${YELLOW}docker-compose logs${NC}"
    echo -e "Redémarrez si nécessaire : ${YELLOW}docker-compose restart${NC}"
fi

echo -e "\n${YELLOW}💡 Commandes utiles :${NC}"
echo -e "- Voir les logs : ${YELLOW}docker-compose logs [service]${NC}"
echo -e "- Redémarrer : ${YELLOW}docker-compose restart [service]${NC}"
echo -e "- Arrêter : ${YELLOW}docker-compose down${NC}"
echo -e "- État : ${YELLOW}docker-compose ps${NC}"
echo -e "- Shell devtools : ${YELLOW}docker exec -it fundamentals-devtools bash${NC}"

echo -e "\n=============================================="
echo -e "🎓 ${GREEN}Bon apprentissage DevOps !${NC}"