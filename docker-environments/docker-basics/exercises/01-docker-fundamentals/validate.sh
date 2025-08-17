#!/bin/bash

# Script de validation pour l'exercice Docker Fundamentals
# Vérifie que l'étudiant a correctement réalisé toutes les étapes

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Compteurs
TESTS_PASSED=0
TESTS_TOTAL=0

# Fonction pour afficher les messages
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
    ((TESTS_PASSED++))
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Fonction pour exécuter un test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    ((TESTS_TOTAL++))
    log_info "Test: $test_name"
    
    if eval "$test_command" > /dev/null 2>&1; then
        log_success "$test_name"
        return 0
    else
        log_error "$test_name"
        return 1
    fi
}

# Fonction pour vérifier qu'une commande retourne un résultat spécifique
check_command_output() {
    local test_name="$1"
    local command="$2"
    local expected_pattern="$3"
    
    ((TESTS_TOTAL++))
    log_info "Test: $test_name"
    
    local output
    output=$(eval "$command" 2>/dev/null || echo "")
    
    if echo "$output" | grep -q "$expected_pattern"; then
        log_success "$test_name"
        return 0
    else
        log_error "$test_name - Pattern '$expected_pattern' not found in output"
        return 1
    fi
}

echo "🐳 Validation de l'exercice Docker Fundamentals"
echo "=============================================="
echo ""

# Test 1: Vérifier que Docker fonctionne
log_info "Vérification de l'environnement Docker..."
run_test "Docker est installé et fonctionne" "docker --version"

# Test 2: Vérifier que l'image Alpine a été téléchargée
run_test "Image Alpine téléchargée" "docker images | grep -q alpine"

# Test 3: Vérifier la présence d'images dans le registry local
log_info "Vérification du registry local..."
if curl -s http://localhost:5000/v2/_catalog | grep -q "repositories"; then
    log_success "Registry local accessible"
    ((TESTS_PASSED++))
else
    log_error "Registry local non accessible"
fi
((TESTS_TOTAL++))

# Test 4: Vérifier qu'une image a été poussée vers le registry
if curl -s http://localhost:5000/v2/_catalog | grep -q "mon-alpine"; then
    log_success "Image poussée vers le registry local"
    ((TESTS_PASSED++))
else
    log_warning "Aucune image 'mon-alpine' trouvée dans le registry local"
fi
((TESTS_TOTAL++))

# Test 5: Vérifier la création de volumes
log_info "Vérification des volumes..."
if docker volume ls | grep -q "mon-volume"; then
    log_success "Volume 'mon-volume' créé"
    ((TESTS_PASSED++))
else
    log_warning "Volume 'mon-volume' non trouvé (peut avoir été nettoyé)"
fi
((TESTS_TOTAL++))

# Test 6: Vérifier la création de réseaux
log_info "Vérification des réseaux..."
if docker network ls | grep -q "mon-reseau"; then
    log_success "Réseau 'mon-reseau' créé"
    ((TESTS_PASSED++))
else
    log_warning "Réseau 'mon-reseau' non trouvé (peut avoir été nettoyé)"
fi
((TESTS_TOTAL++))

# Test 7: Vérifier que l'étudiant peut créer et exécuter un conteneur
log_info "Test de création de conteneur..."
if docker run --rm alpine:latest echo "Test validation" > /dev/null 2>&1; then
    log_success "Capable de créer et exécuter un conteneur"
    ((TESTS_PASSED++))
else
    log_error "Impossible de créer et exécuter un conteneur"
fi
((TESTS_TOTAL++))

# Test 8: Vérifier la compréhension des bind mounts
log_info "Vérification des bind mounts..."
if [ -d "$HOME/docker-lab/html" ]; then
    log_success "Répertoire de bind mount créé"
    ((TESTS_PASSED++))
else
    log_warning "Répertoire de bind mount non trouvé"
fi
((TESTS_TOTAL++))

# Test 9: Vérifier que les services du lab fonctionnent
log_info "Vérification des services du lab..."
services=("nodejs-app" "python-app" "go-app" "postgres" "redis")
services_ok=0

for service in "${services[@]}"; do
    if docker ps | grep -q "$service"; then
        ((services_ok++))
    fi
done

if [ $services_ok -ge 3 ]; then
    log_success "Services du lab opérationnels"
    ((TESTS_PASSED++))
else
    log_error "Certains services du lab ne fonctionnent pas"
fi
((TESTS_TOTAL++))

# Test 10: Vérifier la compréhension des commandes Docker
log_info "Test des connaissances pratiques..."

# Créer un conteneur de test pour validation
test_container="validation-test-$$"
if docker run -d --name "$test_container" nginx:alpine > /dev/null 2>&1; then
    sleep 2
    
    # Vérifier que le conteneur fonctionne
    if docker ps | grep -q "$test_container"; then
        log_success "Maîtrise de la création de conteneurs"
        ((TESTS_PASSED++))
    else
        log_error "Problème avec la création de conteneurs"
    fi
    
    # Nettoyer
    docker stop "$test_container" > /dev/null 2>&1
    docker rm "$test_container" > /dev/null 2>&1
else
    log_error "Impossible de créer un conteneur de test"
fi
((TESTS_TOTAL++))

echo ""
echo "=============================================="
echo "📊 Résultats de la validation"
echo "=============================================="
echo ""

# Calcul du pourcentage
percentage=$((TESTS_PASSED * 100 / TESTS_TOTAL))

echo "Tests réussis: $TESTS_PASSED/$TESTS_TOTAL ($percentage%)"
echo ""

if [ $percentage -ge 80 ]; then
    echo -e "${GREEN}🎉 Félicitations ! Exercice validé avec succès !${NC}"
    echo ""
    echo "Vous avez démontré une bonne maîtrise des concepts fondamentaux de Docker :"
    echo "✓ Manipulation des images et conteneurs"
    echo "✓ Gestion des volumes et de la persistance"
    echo "✓ Configuration des réseaux"
    echo "✓ Utilisation du registry local"
    echo ""
    echo "🚀 Vous pouvez maintenant passer à l'exercice suivant :"
    echo "   cd ../02-custom-images"
    echo ""
elif [ $percentage -ge 60 ]; then
    echo -e "${YELLOW}⚠️  Exercice partiellement validé${NC}"
    echo ""
    echo "Vous avez acquis les bases, mais quelques points nécessitent une révision."
    echo "Consultez les sections correspondant aux tests échoués et recommencez."
    echo ""
else
    echo -e "${RED}❌ Exercice non validé${NC}"
    echo ""
    echo "Il semble que plusieurs concepts n'aient pas été maîtrisés."
    echo "Nous vous recommandons de :"
    echo "1. Relire attentivement les instructions"
    echo "2. Recommencer l'exercice étape par étape"
    echo "3. Consulter la documentation Docker"
    echo "4. Demander de l'aide si nécessaire"
    echo ""
fi

echo "=============================================="

# Code de sortie basé sur le pourcentage de réussite
if [ $percentage -ge 80 ]; then
    exit 0
else
    exit 1
fi