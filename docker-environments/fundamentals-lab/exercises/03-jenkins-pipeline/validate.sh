#!/bin/bash

# Script de validation pour l'Exercice 3 : Pipeline CI/CD avec Jenkins
# Ce script vérifie que toutes les tâches ont été correctement réalisées

set -e

echo "🚀 Validation de l'Exercice 3 : Pipeline CI/CD avec Jenkins"
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
if [ ! -d "/workspace/03-jenkins-pipeline" ]; then
    echo -e "${RED}❌ Erreur: Le dossier /workspace/03-jenkins-pipeline n'existe pas${NC}"
    echo "Assurez-vous d'avoir suivi les instructions de l'exercice."
    exit 1
fi

cd /workspace/03-jenkins-pipeline

echo -e "\n${YELLOW}1. Vérification des fichiers de l'application${NC}"

# Test 1: Fichier app.py existe
[ -f "app.py" ]
check_result "Fichier app.py existe" $?

# Test 2: Fichier test_app.py existe
[ -f "test_app.py" ]
check_result "Fichier test_app.py existe" $?

# Test 3: Fichier requirements.txt existe
[ -f "requirements.txt" ]
check_result "Fichier requirements.txt existe" $?

# Test 4: Script build.sh existe et est exécutable
[ -f "build.sh" ] && [ -x "build.sh" ]
check_result "Script build.sh existe et est exécutable" $?

# Test 5: Script deploy.sh existe et est exécutable
[ -f "deploy.sh" ] && [ -x "deploy.sh" ]
check_result "Script deploy.sh existe et est exécutable" $?

echo -e "\n${YELLOW}2. Vérification des fichiers CI/CD${NC}"

# Test 6: Jenkinsfile existe
[ -f "Jenkinsfile" ]
check_result "Jenkinsfile existe" $?

# Test 7: .gitignore existe
[ -f ".gitignore" ]
check_result ".gitignore existe" $?

# Test 8: Jenkinsfile.docker existe (bonus)
[ -f "Jenkinsfile.docker" ]
check_result "Jenkinsfile.docker existe (bonus)" $?

echo -e "\n${YELLOW}3. Vérification du contenu de l'application${NC}"

# Test 9: app.py contient des fonctions
grep -q "def add" app.py 2>/dev/null
check_result "app.py contient la fonction add" $?

grep -q "def multiply" app.py 2>/dev/null
check_result "app.py contient la fonction multiply" $?

grep -q "def divide" app.py 2>/dev/null
check_result "app.py contient la fonction divide" $?

# Test 10: test_app.py contient des tests
grep -q "class TestCalculator" test_app.py 2>/dev/null
check_result "test_app.py contient une classe de test" $?

grep -q "def test_add" test_app.py 2>/dev/null
check_result "test_app.py contient un test pour add" $?

echo -e "\n${YELLOW}4. Vérification du Jenkinsfile${NC}"

# Test 11: Jenkinsfile contient une pipeline
grep -q "pipeline" Jenkinsfile 2>/dev/null
check_result "Jenkinsfile contient une définition de pipeline" $?

# Test 12: Jenkinsfile contient des stages
grep -q "stages" Jenkinsfile 2>/dev/null
check_result "Jenkinsfile contient des stages" $?

# Test 13: Jenkinsfile contient un stage Build
grep -q "stage.*Build" Jenkinsfile 2>/dev/null
check_result "Jenkinsfile contient un stage Build" $?

# Test 14: Jenkinsfile contient un stage Test
grep -q "stage.*Test" Jenkinsfile 2>/dev/null
check_result "Jenkinsfile contient un stage Test" $?

# Test 15: Jenkinsfile contient un stage Deploy
grep -q "stage.*Deploy" Jenkinsfile 2>/dev/null
check_result "Jenkinsfile contient un stage Deploy" $?

echo -e "\n${YELLOW}5. Tests fonctionnels${NC}"

# Test 16: L'application Python peut être compilée
python3 -m py_compile app.py 2>/dev/null
check_result "app.py peut être compilé" $?

python3 -m py_compile test_app.py 2>/dev/null
check_result "test_app.py peut être compilé" $?

# Test 17: Les tests unitaires passent
python3 -m unittest test_app.py > /dev/null 2>&1
check_result "Tests unitaires passent" $?

# Test 18: Le script build.sh fonctionne
./build.sh > /dev/null 2>&1
check_result "Script build.sh s'exécute sans erreur" $?

# Test 19: Le dossier dist est créé par le build
[ -d "dist" ]
check_result "Dossier dist créé par le build" $?

echo -e "\n${YELLOW}6. Vérification Git${NC}"

# Test 20: Dépôt Git initialisé
[ -d ".git" ]
check_result "Dépôt Git initialisé" $?

# Test 21: Commits présents
COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
[ "$COMMIT_COUNT" -gt "0" ]
check_result "Au moins un commit présent" $?

# Test 22: Remote configuré
git remote get-url origin > /dev/null 2>&1
check_result "Remote origin configuré" $?

echo -e "\n${YELLOW}7. Tests avancés${NC}"

# Test 23: .gitignore contient des patterns Python
grep -q "__pycache__" .gitignore 2>/dev/null
check_result ".gitignore contient des patterns Python" $?

# Test 24: Jenkinsfile contient des post-actions
grep -q "post" Jenkinsfile 2>/dev/null
check_result "Jenkinsfile contient des post-actions" $?

# Test 25: Jenkinsfile.docker contient des références Docker
if [ -f "Jenkinsfile.docker" ]; then
    grep -q "docker" Jenkinsfile.docker 2>/dev/null
    check_result "Jenkinsfile.docker contient des références Docker" $?
else
    echo -e "⏭️  ${YELLOW}SKIP${NC}: Jenkinsfile.docker contient des références Docker (fichier absent)"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
fi

echo -e "\n${YELLOW}8. Vérification de la structure du projet${NC}"

# Test 26: Structure de projet cohérente
EXPECTED_FILES=("app.py" "test_app.py" "build.sh" "deploy.sh" "Jenkinsfile" "requirements.txt" ".gitignore")
MISSING_FILES=0

for file in "${EXPECTED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

[ "$MISSING_FILES" -eq "0" ]
check_result "Tous les fichiers essentiels sont présents" $?

echo -e "\n=================================================="
echo -e "📊 ${YELLOW}Résultats de la validation${NC}"
echo -e "Tests réussis: ${GREEN}$TESTS_PASSED${NC}/$TESTS_TOTAL"

# Calcul du pourcentage
PERCENTAGE=$((TESTS_PASSED * 100 / TESTS_TOTAL))

if [ $TESTS_PASSED -eq $TESTS_TOTAL ]; then
    echo -e "🎉 ${GREEN}Félicitations ! Tous les tests sont passés avec succès !${NC}"
    echo -e "Vous maîtrisez les concepts fondamentaux des pipelines CI/CD."
elif [ $PERCENTAGE -ge 80 ]; then
    echo -e "👍 ${YELLOW}Bon travail ! $PERCENTAGE% des tests sont passés.${NC}"
    echo -e "Quelques points à améliorer, mais vous êtes sur la bonne voie."
else
    echo -e "📚 ${RED}Il reste du travail. Seulement $PERCENTAGE% des tests sont passés.${NC}"
    echo -e "Relisez les instructions et réessayez."
fi

echo -e "\n${YELLOW}💡 Conseils pour la suite :${NC}"
echo "- Explorez les plugins Jenkins pour différents outils"
echo "- Apprenez d'autres outils CI/CD (GitLab CI, GitHub Actions)"
echo "- Découvrez les stratégies de déploiement avancées"
echo "- Pratiquez l'intégration avec des outils de monitoring"

echo -e "\n${YELLOW}🔧 Commandes utiles pour Jenkins :${NC}"
echo "- Accès Jenkins: http://localhost:8080 (admin/admin123)"
echo "- Logs Jenkins: docker logs fundamentals-jenkins"
echo "- Restart Jenkins: docker restart fundamentals-jenkins"

echo -e "\n${YELLOW}📚 Concepts clés maîtrisés :${NC}"
echo "- Pipeline as Code avec Jenkinsfile"
echo "- Intégration Git et déclenchement automatique"
echo "- Tests automatisés dans le pipeline"
echo "- Déploiement automatisé avec validation"
echo "- Gestion des artefacts et nettoyage"

# Nettoyage des fichiers temporaires créés par les tests
rm -rf dist/ __pycache__/ *.pyc 2>/dev/null || true

exit 0