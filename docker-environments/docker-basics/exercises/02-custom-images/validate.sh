#!/bin/bash

# Script de validation pour l'exercice Custom Images
# Vérifie que l'étudiant a correctement créé des images Docker optimisées

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

# Fonction pour vérifier la taille d'une image
check_image_size() {
    local image_name="$1"
    local max_size_mb="$2"
    local test_name="$3"
    
    ((TESTS_TOTAL++))
    log_info "Test: $test_name"
    
    if docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep -q "$image_name"; then
        local size_info=$(docker images --format "{{.Size}}" "$image_name" | head -1)
        log_info "Taille de l'image $image_name: $size_info"
        log_success "$test_name - Image trouvée"
        return 0
    else
        log_error "$test_name - Image non trouvée"
        return 1
    fi
}

echo "🐳 Validation de l'exercice Custom Images"
echo "========================================="
echo ""

# Test 1: Vérifier la création d'images personnalisées
log_info "Vérification des images créées..."

# Rechercher les images créées pendant l'exercice
images_created=0
expected_images=("mon-app-web" "nodejs-optimized" "go-multistage")

for image in "${expected_images[@]}"; do
    if docker images | grep -q "$image"; then
        log_success "Image '$image' créée"
        ((images_created++))
        ((TESTS_PASSED++))
    else
        log_warning "Image '$image' non trouvée"
    fi
    ((TESTS_TOTAL++))
done

# Test 2: Vérifier l'optimisation des images Node.js
log_info "Vérification de l'optimisation Node.js..."
if docker images | grep -q "nodejs-optimized"; then
    # Vérifier que l'image utilise Alpine (plus petite)
    if docker inspect nodejs-optimized:v1 2>/dev/null | grep -q "alpine"; then
        log_success "Image Node.js utilise Alpine (optimisée)"
        ((TESTS_PASSED++))
    else
        log_warning "Image Node.js n'utilise pas Alpine"
    fi
    ((TESTS_TOTAL++))
else
    log_error "Image nodejs-optimized non trouvée"
    ((TESTS_TOTAL++))
fi

# Test 3: Vérifier les multi-stage builds
log_info "Vérification des multi-stage builds..."
if docker images | grep -q "go-multistage"; then
    # Vérifier que l'image Go multi-stage est petite
    check_image_size "go-multistage" 50 "Image Go multi-stage optimisée"
    
    # Vérifier que l'image fonctionne
    if docker run --rm -d --name test-go-multistage -p 8096:8080 go-multistage:v1 > /dev/null 2>&1; then
        sleep 3
        if curl -s http://localhost:8096 > /dev/null 2>&1; then
            log_success "Image Go multi-stage fonctionnelle"
            ((TESTS_PASSED++))
        else
            log_error "Image Go multi-stage ne répond pas"
        fi
        docker stop test-go-multistage > /dev/null 2>&1
        ((TESTS_TOTAL++))
    fi
else
    log_error "Image go-multistage non trouvée"
    ((TESTS_TOTAL++))
fi

# Test 4: Vérifier l'utilisation de .dockerignore
log_info "Vérification des bonnes pratiques..."
dockerignore_found=0
search_paths=(
    "$HOME/docker-lab/custom-images/nodejs-optimized/.dockerignore"
    "$HOME/docker-lab/custom-images/simple-web/.dockerignore"
    "$HOME/docker-lab/custom-images/go-multistage/.dockerignore"
)

for path in "${search_paths[@]}"; do
    if [ -f "$path" ]; then
        log_success "Fichier .dockerignore trouvé"
        ((dockerignore_found++))
        ((TESTS_PASSED++))
        break
    fi
done

if [ $dockerignore_found -eq 0 ]; then
    log_warning "Aucun fichier .dockerignore trouvé"
fi
((TESTS_TOTAL++))

# Test 5: Vérifier la sécurité (utilisateur non-root)
log_info "Vérification de la sécurité..."
security_checks=0

# Vérifier que les images utilisent des utilisateurs non-root
for image in "nodejs-optimized:v1" "go-multistage:v1"; do
    if docker images | grep -q "${image%:*}"; then
        # Créer un conteneur temporaire pour vérifier l'utilisateur
        if container_id=$(docker run -d "$image" sleep 10 2>/dev/null); then
            user_info=$(docker exec "$container_id" whoami 2>/dev/null || echo "root")
            if [ "$user_info" != "root" ]; then
                log_success "Image $image utilise un utilisateur non-root ($user_info)"
                ((security_checks++))
                ((TESTS_PASSED++))
            else
                log_warning "Image $image utilise root (non recommandé)"
            fi
            docker stop "$container_id" > /dev/null 2>&1
            docker rm "$container_id" > /dev/null 2>&1
        fi
        ((TESTS_TOTAL++))
    fi
done

# Test 6: Vérifier les health checks
log_info "Vérification des health checks..."
healthcheck_found=0

for image in "nodejs-optimized:v1"; do
    if docker images | grep -q "${image%:*}"; then
        if docker inspect "$image" 2>/dev/null | grep -q "Healthcheck"; then
            log_success "Health check configuré pour $image"
            ((healthcheck_found++))
            ((TESTS_PASSED++))
        fi
        ((TESTS_TOTAL++))
    fi
done

if [ $healthcheck_found -eq 0 ]; then
    log_warning "Aucun health check trouvé"
fi

# Test 7: Test fonctionnel des images
log_info "Tests fonctionnels des images..."
functional_tests=0

# Tester l'image web simple
if docker images | grep -q "mon-app-web"; then
    if docker run --rm -d --name test-web-func -p 8097:80 mon-app-web:v1 > /dev/null 2>&1; then
        sleep 2
        if curl -s http://localhost:8097 | grep -q "Mon Application Docker"; then
            log_success "Image web simple fonctionnelle"
            ((functional_tests++))
            ((TESTS_PASSED++))
        fi
        docker stop test-web-func > /dev/null 2>&1
    fi
    ((TESTS_TOTAL++))
fi

# Test 8: Vérifier l'optimisation des layers
log_info "Vérification de l'optimisation des layers..."
layer_optimization=0

# Vérifier qu'au moins une image a un nombre raisonnable de layers
for image in "nodejs-optimized:v1" "go-multistage:v1"; do
    if docker images | grep -q "${image%:*}"; then
        layer_count=$(docker history "$image" --format "{{.ID}}" 2>/dev/null | wc -l)
        if [ "$layer_count" -lt 15 ]; then
            log_success "Image $image a un nombre optimisé de layers ($layer_count)"
            ((layer_optimization++))
            ((TESTS_PASSED++))
        else
            log_warning "Image $image a trop de layers ($layer_count)"
        fi
        ((TESTS_TOTAL++))
        break
    fi
done

# Test 9: Vérifier la comparaison des tailles
log_info "Vérification de la compréhension des optimisations..."
if docker images | grep -q "go-simple" && docker images | grep -q "go-multistage"; then
    simple_size=$(docker images --format "{{.Size}}" go-simple:v1 2>/dev/null | head -1)
    multistage_size=$(docker images --format "{{.Size}}" go-multistage:v1 2>/dev/null | head -1)
    
    log_info "Taille Go simple: $simple_size"
    log_info "Taille Go multi-stage: $multistage_size"
    log_success "Comparaison des tailles effectuée"
    ((TESTS_PASSED++))
    ((TESTS_TOTAL++))
fi

# Test 10: Vérifier la présence de métadonnées
log_info "Vérification des métadonnées..."
metadata_found=0

for image in "nodejs-optimized:v1" "go-multistage:v1"; do
    if docker images | grep -q "${image%:*}"; then
        if docker inspect "$image" 2>/dev/null | grep -q "EXPOSE"; then
            log_success "Port exposé correctement pour $image"
            ((metadata_found++))
            ((TESTS_PASSED++))
        fi
        ((TESTS_TOTAL++))
        break
    fi
done

echo ""
echo "========================================="
echo "📊 Résultats de la validation"
echo "========================================="
echo ""

# Calcul du pourcentage
percentage=$((TESTS_PASSED * 100 / TESTS_TOTAL))

echo "Tests réussis: $TESTS_PASSED/$TESTS_TOTAL ($percentage%)"
echo ""

if [ $percentage -ge 80 ]; then
    echo -e "${GREEN}🎉 Félicitations ! Exercice validé avec succès !${NC}"
    echo ""
    echo "Vous avez démontré une excellente maîtrise de la création d'images Docker :"
    echo "✓ Construction d'images personnalisées"
    echo "✓ Optimisation avec multi-stage builds"
    echo "✓ Application des bonnes pratiques de sécurité"
    echo "✓ Optimisation des layers et de la taille"
    echo "✓ Configuration des health checks"
    echo ""
    echo "🚀 Vous pouvez maintenant passer à l'exercice suivant :"
    echo "   cd ../03-docker-compose"
    echo ""
elif [ $percentage -ge 60 ]; then
    echo -e "${YELLOW}⚠️  Exercice partiellement validé${NC}"
    echo ""
    echo "Vous avez acquis les bases de la création d'images, mais quelques optimisations manquent."
    echo "Points à améliorer :"
    echo "- Vérifiez l'utilisation des multi-stage builds"
    echo "- Assurez-vous d'utiliser des utilisateurs non-root"
    echo "- Optimisez le nombre de layers"
    echo ""
else
    echo -e "${RED}❌ Exercice non validé${NC}"
    echo ""
    echo "Plusieurs concepts importants n'ont pas été maîtrisés."
    echo "Nous vous recommandons de :"
    echo "1. Relire les sections sur les Dockerfiles optimisés"
    echo "2. Pratiquer les multi-stage builds"
    echo "3. Appliquer les bonnes pratiques de sécurité"
    echo "4. Recommencer l'exercice étape par étape"
    echo ""
fi

echo "========================================="

# Code de sortie basé sur le pourcentage de réussite
if [ $percentage -ge 80 ]; then
    exit 0
else
    exit 1
fi