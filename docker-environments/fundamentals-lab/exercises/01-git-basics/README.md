# Exercice 1 : Git et Contrôle de Version

## Objectifs

À la fin de cet exercice, vous serez capable de :
- Configurer Git avec vos informations personnelles
- Créer et cloner des dépôts Git
- Effectuer des commits, des branches et des merges
- Collaborer avec d'autres développeurs via un serveur Git
- Comprendre les workflows Git de base

## Durée Estimée
45 minutes

## Prérequis

- Environnement Docker démarré
- Accès au serveur Gitea sur http://localhost:3000
- Container devtools actif

## Étape 1 : Configuration Initiale de Git

### 1.1 Accéder au Container de Développement

```bash
# Se connecter au container devtools
docker exec -it fundamentals-devtools bash

# Installer Git et les outils nécessaires
apt-get update && apt-get install -y git curl vim nano

# Configurer Git avec vos informations
git config --global user.name "Votre Nom"
git config --global user.email "votre.email@example.com"
git config --global init.defaultBranch main

# Vérifier la configuration
git config --list
```

### 1.2 Créer un Dépôt Local

```bash
# Créer un nouveau dossier pour le projet
mkdir -p /workspace/mon-premier-projet
cd /workspace/mon-premier-projet

# Initialiser un dépôt Git
git init

# Créer un fichier README
echo "# Mon Premier Projet DevOps" > README.md
echo "Ce projet fait partie du laboratoire DevOps Fundamentals." >> README.md

# Ajouter et commiter le fichier
git add README.md
git commit -m "Initial commit: Add README"

# Vérifier l'historique
git log --oneline
```

## Étape 2 : Travailler avec des Branches

### 2.1 Créer et Utiliser des Branches

```bash
# Créer une nouvelle branche pour une fonctionnalité
git checkout -b feature/add-documentation

# Créer un fichier de documentation
cat > DOCUMENTATION.md << EOF
# Documentation du Projet

## Installation

1. Cloner le dépôt
2. Suivre les instructions du README

## Utilisation

Ce projet démontre les concepts Git de base.

## Contribution

1. Créer une branche feature
2. Faire vos modifications
3. Créer une pull request
EOF

# Ajouter et commiter les changements
git add DOCUMENTATION.md
git commit -m "Add project documentation"

# Voir les branches disponibles
git branch -a
```

### 2.2 Merger les Branches

```bash
# Retourner sur la branche main
git checkout main

# Merger la branche feature
git merge feature/add-documentation

# Vérifier l'historique
git log --oneline --graph

# Supprimer la branche feature (optionnel)
git branch -d feature/add-documentation
```

## Étape 3 : Travailler avec un Serveur Git Distant

### 3.1 Configurer le Serveur Gitea

1. Ouvrir http://localhost:3000 dans votre navigateur
2. Créer un compte utilisateur (ex: devops/devops123)
3. Créer un nouveau dépôt appelé "fundamentals-lab"

### 3.2 Pousser vers le Serveur Distant

```bash
# Ajouter le remote origin (remplacer USERNAME par votre nom d'utilisateur Gitea)
git remote add origin http://localhost:3000/USERNAME/fundamentals-lab.git

# Pousser la branche main
git push -u origin main

# Vérifier les remotes configurés
git remote -v
```

### 3.3 Simuler la Collaboration

```bash
# Créer une nouvelle branche pour simuler un autre développeur
git checkout -b feature/add-config

# Créer un fichier de configuration
cat > config.yml << EOF
# Configuration de l'application
app:
  name: "Fundamentals Lab"
  version: "1.0.0"
  environment: "development"

database:
  host: "postgres"
  port: 5432
  name: "sampleapp"

logging:
  level: "info"
  format: "json"
EOF

# Commiter les changements
git add config.yml
git commit -m "Add application configuration"

# Pousser la branche
git push origin feature/add-config
```

## Étape 4 : Gestion des Conflits

### 4.1 Créer un Conflit Intentionnel

```bash
# Retourner sur main et modifier le README
git checkout main
echo "" >> README.md
echo "## Configuration" >> README.md
echo "Voir le fichier config.yml pour la configuration." >> README.md

git add README.md
git commit -m "Update README with configuration info"

# Retourner sur la branche feature et modifier le même fichier
git checkout feature/add-config
echo "" >> README.md
echo "## Setup" >> README.md
echo "Configuration disponible dans config.yml" >> README.md

git add README.md
git commit -m "Add setup section to README"
```

### 4.2 Résoudre le Conflit

```bash
# Essayer de merger (cela créera un conflit)
git checkout main
git merge feature/add-config

# Le conflit sera affiché, éditer le fichier README.md pour résoudre
# Utiliser nano ou vim pour éditer le fichier et résoudre le conflit

# Après résolution, marquer comme résolu et commiter
git add README.md
git commit -m "Resolve merge conflict in README.md"

# Pousser les changements
git push origin main
```

## Étape 5 : Bonnes Pratiques Git

### 5.1 Commits Atomiques et Messages Descriptifs

```bash
# Créer plusieurs petits commits plutôt qu'un gros
echo "# Tests" > TESTS.md
git add TESTS.md
git commit -m "Add tests documentation file"

echo "## Unit Tests" >> TESTS.md
git add TESTS.md
git commit -m "Add unit tests section to documentation"

echo "## Integration Tests" >> TESTS.md
git add TESTS.md
git commit -m "Add integration tests section to documentation"
```

### 5.2 Utiliser .gitignore

```bash
# Créer un fichier .gitignore
cat > .gitignore << EOF
# Logs
*.log
logs/

# Dependencies
node_modules/
__pycache__/
*.pyc

# Environment variables
.env
.env.local

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Build artifacts
dist/
build/
*.egg-info/
EOF

git add .gitignore
git commit -m "Add .gitignore file"
```

## Validation

Exécuter le script de validation pour vérifier que vous avez correctement réalisé l'exercice :

```bash
cd /workspace/01-git-basics
./validate.sh
```

## Points Clés à Retenir

1. **Configuration Git** : Toujours configurer user.name et user.email
2. **Commits fréquents** : Faire des commits petits et fréquents
3. **Messages descriptifs** : Écrire des messages de commit clairs
4. **Branches** : Utiliser des branches pour les fonctionnalités
5. **Résolution de conflits** : Savoir identifier et résoudre les conflits
6. **Bonnes pratiques** : Utiliser .gitignore, commits atomiques

## Ressources Supplémentaires

- [Pro Git Book](https://git-scm.com/book)
- [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)
- [Interactive Git Tutorial](https://learngitbranching.js.org/)

## Prochaine Étape

Une fois cet exercice terminé, passez à l'Exercice 2 : Introduction à Docker.