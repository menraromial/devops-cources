#!/bin/bash
set -e

echo "🔨 Début du build de l'application Calculator"

# Vérifier la syntaxe Python
echo "📝 Vérification de la syntaxe Python..."
python3 -m py_compile app.py
python3 -m py_compile test_app.py

# Exécuter les tests unitaires
echo "🧪 Exécution des tests unitaires..."
python3 -m unittest test_app.py -v

# Créer un package de l'application
echo "📦 Création du package..."
mkdir -p dist
cp app.py dist/
cp requirements.txt dist/

echo "✅ Build terminé avec succès!"
echo "📊 Résumé:"
echo "  - Tests: PASSED"
echo "  - Package: dist/"
