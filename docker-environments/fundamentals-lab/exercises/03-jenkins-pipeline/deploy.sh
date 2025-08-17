#!/bin/bash
set -e

echo "🚀 Début du déploiement de l'application Calculator"

# Vérifier que le package existe
if [ ! -d "dist" ]; then
    echo "❌ Erreur: Le dossier dist/ n'existe pas. Exécutez d'abord build.sh"
    exit 1
fi

# Simuler le déploiement
echo "📋 Vérification des prérequis de déploiement..."
echo "🔄 Déploiement en cours..."

# Créer un dossier de déploiement simulé
mkdir -p /tmp/deployed-app
cp -r dist/* /tmp/deployed-app/

# Tester l'application déployée
echo "🧪 Test de l'application déployée..."
cd /tmp/deployed-app
python3 app.py

echo "✅ Déploiement terminé avec succès!"
echo "📍 Application déployée dans: /tmp/deployed-app"
