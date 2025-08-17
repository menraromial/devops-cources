#!/bin/bash

# Script de validation pour l'Exercice 2 : Introduction à Docker
# Ce script vérifie que toutes les tâches ont été correctement réalisées

set -e

echo "🐳 Validation de l'Exercice 2 : Introduction à Docker"
echo "=================================================="

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Compteurs
TESTS_PASSED=0
TESTS_TOTAL=0

# Fonction pour afficher les résultats
check_result() {
    local test_name="$1"
    local result="$2"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    if [ "$result" = "0" ]; then
        echo -e "✅ ${GREEN}PASS${NC}: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "❌ ${RED}FAIL${NC}: $test_name"
    fi
}

# Vérifier que nous sommes dans le bon répertoire
if [ ! -d "/workspace/02-docker-intro" ]; then
    echo -e "${RED}❌ Erreur: Le dossier /workspace/02-docker-intro n'existe pas${NC}"
    echo "Assurez-vous d'avoir suivi les instructions de l'exercice."
    exit 1
fi

cd /workspace/02-docker-intro

echo -e "\n${YELLOW}1. Vérification des fichiers créés${NC}"

# Test 1: Fichier app.py existe
[ -f "app.py" ]
check_result "Fichier app.py existe" $?

# Test 2: Dockerfile existe
[ -f "Dockerfile" ]
check_result "Dockerfile existe" $?

# Test 3: docker-compose.yml existe
[ -f "docker-compose.yml" ]
check_result "docker-compose.yml existe" $?

# Test 4: nginx.conf existe
[ -f "nginx.conf" ]
check_result "nginx.conf existe" $?

# Test 5: .dockerignore existe
[ -f ".dockerignore" ]
check_result ".dockerignore existe" $?

echo -e "\n${YELLOW}2. Vérification du contenu des fichiers${NC}"

# Test 6: app.py contient du code Python
grep -q "python" app.py 2>/dev/null
check_result "app.py contient du code Python" $?

# Test 7: Dockerfile utilise une image Python
grep -q "FROM python" Dockerfile 2>/dev/null
check_result "Dockerfile utilise une image Python" $?

# Test 8: docker-compose.yml définit des services
grep -q "services:" docker-compose.yml 2>/dev/null
check_result "docker-compose.yml définit des services" $?

# Test 9: nginx.conf contient une configuration
grep -q "server" nginx.conf 2>/dev/null
check_result "nginx.conf contient une configuration serveur" $?

echo -e "\n${YELLOW}3. Vérification des bonnes pratiques Docker${NC}"

# Test 10: Dockerfile utilise un utilisateur non-root
grep -q "USER" Dockerfile 2>/dev/null
check_result "Dockerfile utilise un utilisateur non-root" $?

# Test 11: Dockerfile expose un port
grep -q "EXPOSE" Dockerfile 2>/dev/null
check_result "Dockerfile expose un port" $?

# Test 12: .dockerignore contient des patterns
grep -q "*.log" .dockerignore 2>/dev/null
check_result ".dockerignore contient des patterns de fichiers" $?

# Test 13: docker-compose.yml utilise des volumes
grep -q "volumes:" docker-compose.yml 2>/dev/null
check_result "docker-compose.yml utilise des volumes" $?

# Test 14: docker-compose.yml utilise des networks
grep -q "networks:" docker-compose.yml 2>/dev/null
check_result "docker-compose.yml utilise des networks" $?

echo -e "\n${YELLOW}4. Tests de construction d'images${NC}"

# Test 15: Vérifier si l'image peut être construite
docker build -t test-validation . > /dev/null 2>&1
check_result "Image Docker peut être construite" $?

# Test 16: Vérifier si l'image existe
docker images | grep -q "test-validation" 2>/dev/null
check_result "Image test-validation existe" $?

echo -e "\n${YELLOW}5. Tests de docker-compose${NC}"

# Test 17: docker-compose.yml est valide
docker-compose config > /dev/null 2>&1
check_result "docker-compose.yml est syntaxiquement valide" $?

# Test 18: Vérifier les services définis
docker-compose config --services | grep -q "web" 2>/dev/null
check_result "Service 'web' défini dans docker-compose.yml" $?

docker-compose config --services | grep -q "redis" 2>/dev/null
check_result "Service 'redis' défini dans docker-compose.yml" $?

docker-compose config --services | grep -q "nginx" 2>/dev/null
check_result "Service 'nginx' défini dans docker-compose.yml" $?

echo -e "\n${YELLOW}6. Tests avancés${NC}"

# Test 19: Vérifier la structure du Dockerfile
grep -q "WORKDIR" Dockerfile 2>/dev/null
check_result "Dockerfile définit un WORKDIR" $?

# Test 20: Vérifier les variables d'environnement
grep -q "ENV" Dockerfile 2>/dev/null
check_result "Dockerfile définit des variables d'environnement" $?

# Test 21: Vérifier si Dockerfile.optimized existe
[ -f "Dockerfile.optimized" ]
check_result "Dockerfile.optimized existe (bonus)" $?

echo -e "\n${YELLOW}7. Nettoyage des ressources de test${NC}"

# Nettoyer l'image de test
docker rmi test-validation > /dev/null 2>&1 || true

echo -e "\n=================================================="
echo -e "📊 ${YELLOW}Résultats de la validation${NC}"
echo -e "Tests réussis: ${GREEN}$TESTS_PASSED${NC}/$TESTS_TOTAL"

# Calcul du pourcentage
PERCENTAGE=$((TESTS_PASSED * 100 / TESTS_TOTAL))

if [ $TESTS_PASSED -eq $TESTS_TOTAL ]; then
    echo -e "🎉 ${GREEN}Félicitations ! Tous les tests sont passés avec succès !${NC}"
    echo -e "Vous maîtrisez les concepts fondamentaux de Docker."
elif [ $PERCENTAGE -ge 80 ]; then
    echo -e "👍 ${YELLOW}Bon travail ! $PERCENTAGE% des tests sont passés.${NC}"
    echo -e "Quelques points à améliorer, mais vous êtes sur la bonne voie."
else
    echo -e "📚 ${RED}Il reste du travail. Seulement $PERCENTAGE% des tests sont passés.${NC}"
    echo -e "Relisez les instructions et réessayez."
fi

echo -e "\n${YELLOW}💡 Conseils pour la suite :${NC}"
echo "- Explorez les registries Docker (Docker Hub, ECR, etc.)"
echo "- Apprenez Docker Swarm pour l'orchestration"
echo "- Découvrez les outils de sécurité Docker (Clair, Trivy)"
echo "- Pratiquez les patterns de déploiement avec Docker"

echo -e "\n${YELLOW}🔧 Commandes utiles pour déboguer :${NC}"
echo "- docker logs <container>     : Voir les logs d'un container"
echo "- docker exec -it <container> sh : Se connecter à un container"
echo "- docker system df            : Voir l'utilisation de l'espace"
echo "- docker system prune         : Nettoyer les ressources inutilisées"

exit 0