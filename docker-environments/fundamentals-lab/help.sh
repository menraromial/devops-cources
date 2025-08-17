#!/bin/bash

# Script d'aide pour le laboratoire DevOps Fundamentals

echo "🆘 Aide - Laboratoire DevOps Fundamentals"
echo "========================================"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "\n${BLUE}📋 Commandes principales :${NC}"
echo -e "┌─────────────────────────────────────────────────────────────┐"
echo -e "│ ${YELLOW}Commande${NC}                    │ ${YELLOW}Description${NC}                     │"
echo -e "├─────────────────────────────────────────────────────────────┤"
echo -e "│ ./start-lab.sh              │ Démarrer le laboratoire         │"
echo -e "│ docker-compose up -d        │ Démarrer les services           │"
echo -e "│ docker-compose down         │ Arrêter les services            │"
echo -e "│ docker-compose ps           │ État des services               │"
echo -e "│ docker-compose logs         │ Voir tous les logs              │"
echo -e "│ docker-compose logs [svc]   │ Logs d'un service spécifique    │"
echo -e "│ docker-compose restart      │ Redémarrer tous les services    │"
echo -e "│ docker-compose restart [svc]│ Redémarrer un service           │"
echo -e "└─────────────────────────────────────────────────────────────┘"

echo -e "\n${BLUE}🐳 Accès aux containers :${NC}"
echo -e "┌─────────────────────────────────────────────────────────────┐"
echo -e "│ ${YELLOW}Container${NC}                   │ ${YELLOW}Commande d'accès${NC}                │"
echo -e "├─────────────────────────────────────────────────────────────┤"
echo -e "│ DevTools                    │ docker exec -it fundamentals-devtools bash │"
echo -e "│ Jenkins                     │ docker exec -it fundamentals-jenkins bash  │"
echo -e "│ Gitea                       │ docker exec -it fundamentals-git-server sh │"
echo -e "│ PostgreSQL                  │ docker exec -it fundamentals-postgres psql │"
echo -e "└─────────────────────────────────────────────────────────────┘"

echo -e "\n${BLUE}🌐 Services web :${NC}"
echo -e "┌─────────────────────────────────────────────────────────────┐"
echo -e "│ ${YELLOW}Service${NC}                     │ ${YELLOW}URL${NC}                            │"
echo -e "├─────────────────────────────────────────────────────────────┤"
echo -e "│ Jenkins                     │ http://localhost:8080           │"
echo -e "│ Gitea                       │ http://localhost:3000           │"
echo -e "│ Sample App                  │ http://localhost:8000           │"
echo -e "└─────────────────────────────────────────────────────────────┘"

echo -e "\n${BLUE}📚 Structure des exercices :${NC}"
echo -e "exercises/"
echo -e "├── 01-git-basics/          # Git et contrôle de version"
echo -e "│   ├── README.md            # Instructions détaillées"
echo -e "│   └── validate.sh          # Script de validation"
echo -e "├── 02-docker-intro/        # Introduction à Docker"
echo -e "│   ├── README.md            # Instructions détaillées"
echo -e "│   └── validate.sh          # Script de validation"
echo -e "└── 03-jenkins-pipeline/    # Pipeline CI/CD Jenkins"
echo -e "    ├── README.md            # Instructions détaillées"
echo -e "    └── validate.sh          # Script de validation"

echo -e "\n${BLUE}🔧 Dépannage courant :${NC}"

echo -e "\n${YELLOW}Problème : Services ne démarrent pas${NC}"
echo -e "Solutions :"
echo -e "1. Vérifier Docker : ${GREEN}docker info${NC}"
echo -e "2. Libérer les ports : ${GREEN}sudo lsof -i :8080,3000,8000${NC}"
echo -e "3. Nettoyer : ${GREEN}docker system prune -f${NC}"
echo -e "4. Redémarrer : ${GREEN}./start-lab.sh${NC}"

echo -e "\n${YELLOW}Problème : Jenkins ne répond pas${NC}"
echo -e "Solutions :"
echo -e "1. Vérifier les logs : ${GREEN}docker-compose logs jenkins${NC}"
echo -e "2. Redémarrer : ${GREEN}docker-compose restart jenkins${NC}"
echo -e "3. Attendre 2-3 minutes (démarrage lent)"

echo -e "\n${YELLOW}Problème : Gitea ne répond pas${NC}"
echo -e "Solutions :"
echo -e "1. Vérifier les logs : ${GREEN}docker-compose logs gitea${NC}"
echo -e "2. Redémarrer : ${GREEN}docker-compose restart gitea${NC}"
echo -e "3. Vérifier l'espace disque disponible"

echo -e "\n${YELLOW}Problème : Erreurs de permissions${NC}"
echo -e "Solutions :"
echo -e "1. Vérifier les permissions : ${GREEN}ls -la${NC}"
echo -e "2. Corriger si nécessaire : ${GREEN}chmod +x *.sh${NC}"
echo -e "3. Utiliser sudo si requis pour Docker"

echo -e "\n${BLUE}📊 Monitoring et logs :${NC}"
echo -e "- État des containers : ${GREEN}docker-compose ps${NC}"
echo -e "- Utilisation ressources : ${GREEN}docker stats${NC}"
echo -e "- Espace disque Docker : ${GREEN}docker system df${NC}"
echo -e "- Logs en temps réel : ${GREEN}docker-compose logs -f [service]${NC}"

echo -e "\n${BLUE}🧹 Nettoyage :${NC}"
echo -e "- Arrêter tout : ${GREEN}docker-compose down -v${NC}"
echo -e "- Nettoyer images : ${GREEN}docker image prune -f${NC}"
echo -e "- Nettoyer système : ${GREEN}docker system prune -f${NC}"
echo -e "- Reset complet : ${GREEN}docker-compose down -v --rmi all${NC}"

echo -e "\n${BLUE}🎯 Ordre recommandé des exercices :${NC}"
echo -e "1. ${YELLOW}Exercice 1${NC} : Git et Contrôle de Version (45 min)"
echo -e "   ${GREEN}cd exercises/01-git-basics && cat README.md${NC}"
echo -e ""
echo -e "2. ${YELLOW}Exercice 2${NC} : Introduction à Docker (60 min)"
echo -e "   ${GREEN}cd exercises/02-docker-intro && cat README.md${NC}"
echo -e ""
echo -e "3. ${YELLOW}Exercice 3${NC} : Pipeline CI/CD avec Jenkins (90 min)"
echo -e "   ${GREEN}cd exercises/03-jenkins-pipeline && cat README.md${NC}"

echo -e "\n${BLUE}✅ Validation des exercices :${NC}"
echo -e "Chaque exercice contient un script ${YELLOW}validate.sh${NC} pour vérifier votre travail :"
echo -e "- ${GREEN}cd exercises/[nom-exercice]${NC}"
echo -e "- ${GREEN}./validate.sh${NC}"

echo -e "\n${BLUE}📞 Support supplémentaire :${NC}"
echo -e "- Documentation Docker : https://docs.docker.com/"
echo -e "- Documentation Jenkins : https://www.jenkins.io/doc/"
echo -e "- Documentation Git : https://git-scm.com/doc"
echo -e "- Cours DevOps complet : Consultez les autres modules"

echo -e "\n========================================"
echo -e "💡 ${GREEN}Conseil${NC} : Commencez toujours par lire le README.md de chaque exercice !"