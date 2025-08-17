#!/bin/bash

# Script de validation pour l'Exercice 1 : Git et Contrôle de Version
# Ce script vérifie que toutes les tâches ont été correctement réalisées

set -e

echo "🔍 Validation de l'Exercice 1 : Git et Contrôle de Version"
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
if [ ! -d "/workspace/mon-premier-projet" ]; then
    echo -e "${RED}❌ Erreur: Le dossier /workspace/mon-premier-projet n'existe pas${NC}"
    echo "Assurez-vous d'avoir suivi les instructions de l'exercice."
    exit 1
fi

cd /workspace/mon-premier-projet

echo -e "\n${YELLOW}1. Vérification de la configuration Git${NC}"

# Test 1: Configuration Git
git config user.name > /dev/null 2>&1
check_result "Configuration user.name" $?

git config user.email > /dev/null 2>&1
check_result "Configuration user.email" $?

echo -e "\n${YELLOW}2. Vérification du dépôt Git${NC}"

# Test 2: Dépôt Git initialisé
[ -d ".git" ]
check_result "Dépôt Git initialisé" $?

# Test 3: Fichier README existe
[ -f "README.md" ]
check_result "Fichier README.md existe" $?

# Test 4: Commits présents
COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
[ "$COMMIT_COUNT" -gt "0" ]
check_result "Au moins un commit présent" $?

echo -e "\n${YELLOW}3. Vérification des fichiers créés${NC}"

# Test 5: Fichier DOCUMENTATION.md
[ -f "DOCUMENTATION.md" ]
check_result "Fichier DOCUMENTATION.md existe" $?

# Test 6: Fichier config.yml
[ -f "config.yml" ]
check_result "Fichier config.yml existe" $?

# Test 7: Fichier .gitignore
[ -f ".gitignore" ]
check_result "Fichier .gitignore existe" $?

# Test 8: Fichier TESTS.md
[ -f "TESTS.md" ]
check_result "Fichier TESTS.md existe" $?

echo -e "\n${YELLOW}4. Vérification de l'historique Git${NC}"

# Test 9: Plusieurs commits
[ "$COMMIT_COUNT" -gt "3" ]
check_result "Au moins 4 commits présents" $?

# Test 10: Remote configuré
git remote get-url origin > /dev/null 2>&1
check_result "Remote origin configuré" $?

echo -e "\n${YELLOW}5. Vérification du contenu des fichiers${NC}"

# Test 11: README contient le titre
grep -q "Mon Premier Projet DevOps" README.md 2>/dev/null
check_result "README contient le titre correct" $?

# Test 12: DOCUMENTATION contient les sections attendues
grep -q "Installation" DOCUMENTATION.md 2>/dev/null
check_result "DOCUMENTATION contient la section Installation" $?

# Test 13: config.yml contient la configuration
grep -q "app:" config.yml 2>/dev/null
check_result "config.yml contient la configuration app" $?

# Test 14: .gitignore contient des patterns
grep -q "*.log" .gitignore 2>/dev/null
check_result ".gitignore contient des patterns de fichiers" $?

echo -e "\n${YELLOW}6. Tests avancés${NC}"

# Test 15: Vérifier qu'il y a eu des merges
MERGE_COUNT=$(git log --merges --oneline | wc -l)
[ "$MERGE_COUNT" -gt "0" ]
check_result "Au moins un merge effectué" $?

# Test 16: Vérifier la structure des commits
git log --oneline | grep -q "Initial commit" 2>/dev/null
check_result "Commit initial présent" $?

echo -e "\n=================================================="
echo -e "📊 ${YELLOW}Résultats de la validation${NC}"
echo -e "Tests réussis: ${GREEN}$TESTS_PASSED${NC}/$TESTS_TOTAL"

# Calcul du pourcentage
PERCENTAGE=$((TESTS_PASSED * 100 / TESTS_TOTAL))

if [ $TESTS_PASSED -eq $TESTS_TOTAL ]; then
    echo -e "🎉 ${GREEN}Félicitations ! Tous les tests sont passés avec succès !${NC}"
    echo -e "Vous avez maîtrisé les concepts de base de Git."
elif [ $PERCENTAGE -ge 80 ]; then
    echo -e "👍 ${YELLOW}Bon travail ! $PERCENTAGE% des tests sont passés.${NC}"
    echo -e "Quelques points à améliorer, mais vous êtes sur la bonne voie."
else
    echo -e "📚 ${RED}Il reste du travail. Seulement $PERCENTAGE% des tests sont passés.${NC}"
    echo -e "Relisez les instructions et réessayez."
fi

echo -e "\n${YELLOW}💡 Conseils pour la suite :${NC}"
echo "- Pratiquez les commandes Git régulièrement"
echo "- Explorez les workflows Git avancés (GitFlow, GitHub Flow)"
echo "- Apprenez à utiliser les outils graphiques Git"
echo "- Découvrez les hooks Git pour automatiser des tâches"

exit 0