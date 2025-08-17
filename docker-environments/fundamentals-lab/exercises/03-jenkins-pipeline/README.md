# Exercice 3 : Pipeline CI/CD avec Jenkins

## Objectifs

À la fin de cet exercice, vous serez capable de :
- Configurer Jenkins pour l'intégration continue
- Créer des pipelines Jenkins avec Jenkinsfile
- Intégrer Git avec Jenkins pour déclencher des builds automatiques
- Implémenter des étapes de test et de déploiement
- Comprendre les concepts de CI/CD en pratique

## Durée Estimée
90 minutes

## Prérequis

- Exercices 1 (Git) et 2 (Docker) terminés
- Jenkins accessible sur http://localhost:8080
- Serveur Gitea accessible sur http://localhost:3000
- Connaissances de base en pipelines CI/CD

## Étape 1 : Configuration Initiale de Jenkins

### 1.1 Accès à Jenkins

1. Ouvrir http://localhost:8080 dans votre navigateur
2. Se connecter avec les identifiants : `admin` / `admin123`
3. Explorer l'interface Jenkins

### 1.2 Configuration des Outils

```bash
# Se connecter au container devtools pour préparer le projet
docker exec -it fundamentals-devtools bash

# Créer le workspace pour cet exercice
mkdir -p /workspace/03-jenkins-pipeline
cd /workspace/03-jenkins-pipeline

# Créer une application simple à tester
cat > app.py << 'EOF'
#!/usr/bin/env python3
"""
Application simple pour démonstration CI/CD
"""

def add(a, b):
    """Addition de deux nombres"""
    return a + b

def multiply(a, b):
    """Multiplication de deux nombres"""
    return a * b

def divide(a, b):
    """Division de deux nombres"""
    if b == 0:
        raise ValueError("Division par zéro impossible")
    return a / b

def get_app_info():
    """Retourne les informations de l'application"""
    return {
        "name": "Calculator App",
        "version": "1.0.0",
        "description": "Application de démonstration CI/CD"
    }

if __name__ == "__main__":
    print("Calculator App - Version 1.0.0")
    print(f"2 + 3 = {add(2, 3)}")
    print(f"4 * 5 = {multiply(4, 5)}")
    print(f"10 / 2 = {divide(10, 2)}")
EOF

# Créer des tests unitaires
cat > test_app.py << 'EOF'
#!/usr/bin/env python3
"""
Tests unitaires pour l'application Calculator
"""

import unittest
from app import add, multiply, divide, get_app_info

class TestCalculator(unittest.TestCase):
    
    def test_add(self):
        """Test de la fonction addition"""
        self.assertEqual(add(2, 3), 5)
        self.assertEqual(add(-1, 1), 0)
        self.assertEqual(add(0, 0), 0)
    
    def test_multiply(self):
        """Test de la fonction multiplication"""
        self.assertEqual(multiply(2, 3), 6)
        self.assertEqual(multiply(-2, 3), -6)
        self.assertEqual(multiply(0, 5), 0)
    
    def test_divide(self):
        """Test de la fonction division"""
        self.assertEqual(divide(6, 2), 3)
        self.assertEqual(divide(5, 2), 2.5)
        
        # Test de l'exception pour division par zéro
        with self.assertRaises(ValueError):
            divide(5, 0)
    
    def test_get_app_info(self):
        """Test des informations de l'application"""
        info = get_app_info()
        self.assertIn("name", info)
        self.assertIn("version", info)
        self.assertEqual(info["name"], "Calculator App")

if __name__ == '__main__':
    unittest.main()
EOF

# Créer un fichier requirements.txt
cat > requirements.txt << 'EOF'
# Pas de dépendances externes pour cette application simple
# En production, on aurait des dépendances comme Flask, requests, etc.
EOF

# Créer un script de build
cat > build.sh << 'EOF'
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
EOF

chmod +x build.sh

# Créer un script de déploiement
cat > deploy.sh << 'EOF'
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
EOF

chmod +x deploy.sh
```

## Étape 2 : Création d'un Dépôt Git

### 2.1 Initialiser le Dépôt Local

```bash
# Initialiser Git dans le projet
git init
git config user.name "DevOps Student"
git config user.email "student@devops-lab.com"

# Créer un .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
.venv/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Build artifacts
dist/
build/
*.egg-info/

# Logs
*.log

# Temporary files
*.tmp
EOF

# Ajouter tous les fichiers
git add .
git commit -m "Initial commit: Calculator app with CI/CD setup"
```

### 2.2 Créer le Dépôt sur Gitea

1. Aller sur http://localhost:3000
2. Se connecter (créer un compte si nécessaire)
3. Créer un nouveau dépôt appelé "calculator-cicd"
4. Copier l'URL du dépôt

```bash
# Ajouter le remote (remplacer USERNAME par votre nom d'utilisateur Gitea)
git remote add origin http://localhost:3000/USERNAME/calculator-cicd.git

# Pousser le code
git push -u origin main
```

## Étape 3 : Création du Pipeline Jenkins

### 3.1 Jenkinsfile Basique

```bash
# Créer un Jenkinsfile
cat > Jenkinsfile << 'EOF'
pipeline {
    agent any
    
    environment {
        APP_NAME = 'calculator-app'
        VERSION = '1.0.0'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '📥 Récupération du code source...'
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                echo '🔨 Construction de l\'application...'
                sh './build.sh'
            }
        }
        
        stage('Test') {
            steps {
                echo '🧪 Exécution des tests...'
                sh 'python3 -m unittest test_app.py -v'
            }
            post {
                always {
                    echo '📊 Archivage des résultats de tests...'
                    // En production, on utiliserait des plugins pour les rapports de tests
                }
            }
        }
        
        stage('Package') {
            steps {
                echo '📦 Création du package de déploiement...'
                sh '''
                    echo "Création de l'archive de déploiement..."
                    tar -czf ${APP_NAME}-${VERSION}.tar.gz dist/
                    ls -la *.tar.gz
                '''
            }
        }
        
        stage('Deploy to Staging') {
            steps {
                echo '🚀 Déploiement en staging...'
                sh './deploy.sh'
            }
        }
        
        stage('Integration Tests') {
            steps {
                echo '🔍 Tests d\'intégration...'
                sh '''
                    echo "Exécution des tests d'intégration..."
                    # Ici on pourrait avoir des tests d'intégration réels
                    python3 /tmp/deployed-app/app.py &
                    APP_PID=$!
                    sleep 2
                    kill $APP_PID || true
                    echo "Tests d'intégration terminés"
                '''
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                echo '🌟 Déploiement en production...'
                input message: 'Déployer en production?', ok: 'Déployer'
                sh '''
                    echo "Déploiement en production simulé..."
                    mkdir -p /tmp/production-app
                    cp -r dist/* /tmp/production-app/
                    echo "Application déployée en production!"
                '''
            }
        }
    }
    
    post {
        always {
            echo '🧹 Nettoyage...'
            sh '''
                rm -f *.tar.gz
                echo "Nettoyage terminé"
            '''
        }
        success {
            echo '✅ Pipeline exécuté avec succès!'
        }
        failure {
            echo '❌ Pipeline échoué!'
        }
    }
}
EOF

# Commiter le Jenkinsfile
git add Jenkinsfile
git commit -m "Add Jenkins pipeline configuration"
git push origin main
```

## Étape 4 : Configuration du Job Jenkins

### 4.1 Créer un Pipeline Job

1. Dans Jenkins, cliquer sur "New Item"
2. Entrer le nom : "calculator-cicd-pipeline"
3. Sélectionner "Pipeline" et cliquer "OK"
4. Dans la configuration :
   - **Description** : "Pipeline CI/CD pour l'application Calculator"
   - **Build Triggers** : Cocher "Poll SCM" et entrer `H/2 * * * *` (vérification toutes les 2 minutes)
   - **Pipeline** :
     - Definition : "Pipeline script from SCM"
     - SCM : "Git"
     - Repository URL : URL de votre dépôt Gitea
     - Branch : `*/main`
     - Script Path : `Jenkinsfile`

5. Cliquer "Save"

### 4.2 Exécuter le Pipeline

1. Cliquer sur "Build Now"
2. Observer l'exécution dans "Build History"
3. Cliquer sur le build en cours pour voir les détails
4. Explorer les différentes étapes dans "Pipeline Steps"

## Étape 5 : Pipeline Avancé avec Docker

### 5.1 Jenkinsfile avec Docker

```bash
# Créer un Jenkinsfile avancé
cat > Jenkinsfile.docker << 'EOF'
pipeline {
    agent any
    
    environment {
        APP_NAME = 'calculator-app'
        VERSION = "${BUILD_NUMBER}"
        DOCKER_IMAGE = "${APP_NAME}:${VERSION}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '📥 Récupération du code source...'
                checkout scm
            }
        }
        
        stage('Build & Test in Docker') {
            agent {
                docker {
                    image 'python:3.11-slim'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                echo '🐳 Build et tests dans un container Docker...'
                sh '''
                    python --version
                    python -m py_compile app.py
                    python -m unittest test_app.py -v
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo '🏗️ Construction de l\'image Docker...'
                script {
                    // Créer un Dockerfile pour l'application
                    writeFile file: 'Dockerfile', text: '''
FROM python:3.11-slim

WORKDIR /app

COPY app.py .
COPY requirements.txt .

RUN useradd --create-home --shell /bin/bash appuser && \\
    chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

CMD ["python", "app.py"]
'''
                    
                    // Construire l'image
                    def image = docker.build("${DOCKER_IMAGE}")
                    
                    // Tester l'image
                    image.inside {
                        sh 'python --version'
                        sh 'python app.py &'
                    }
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                echo '🔒 Scan de sécurité de l\'image...'
                sh '''
                    echo "Simulation d'un scan de sécurité..."
                    echo "✅ Aucune vulnérabilité critique détectée"
                '''
            }
        }
        
        stage('Deploy to Staging') {
            steps {
                echo '🚀 Déploiement en staging avec Docker...'
                script {
                    // Arrêter le container existant s'il existe
                    sh 'docker stop calculator-staging || true'
                    sh 'docker rm calculator-staging || true'
                    
                    // Démarrer le nouveau container
                    sh """
                        docker run -d --name calculator-staging \\
                            -p 8001:8000 \\
                            ${DOCKER_IMAGE}
                    """
                    
                    // Attendre que l'application démarre
                    sleep 5
                    
                    // Test de santé
                    sh 'curl -f http://localhost:8001 || echo "Health check failed"'
                }
            }
        }
        
        stage('Approval for Production') {
            when {
                branch 'main'
            }
            steps {
                script {
                    def userInput = input(
                        id: 'userInput',
                        message: 'Déployer en production?',
                        parameters: [
                            choice(
                                choices: ['Deploy', 'Abort'],
                                description: 'Choisir une action',
                                name: 'action'
                            )
                        ]
                    )
                    
                    if (userInput == 'Abort') {
                        error('Déploiement annulé par l\'utilisateur')
                    }
                }
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                echo '🌟 Déploiement en production...'
                script {
                    // Blue-Green deployment simulation
                    sh 'docker stop calculator-prod-blue || true'
                    sh 'docker rm calculator-prod-blue || true'
                    
                    sh """
                        docker run -d --name calculator-prod-blue \\
                            -p 8002:8000 \\
                            ${DOCKER_IMAGE}
                    """
                    
                    sleep 5
                    sh 'curl -f http://localhost:8002 || echo "Production health check failed"'
                    
                    echo '✅ Déploiement en production terminé!'
                }
            }
        }
    }
    
    post {
        always {
            echo '🧹 Nettoyage des ressources...'
            sh '''
                # Nettoyer les containers de test
                docker stop calculator-staging || true
                docker rm calculator-staging || true
                
                # Garder seulement les 3 dernières images
                docker images ${APP_NAME} --format "table {{.Tag}}" | tail -n +4 | xargs -r docker rmi ${APP_NAME}: || true
            '''
        }
        success {
            echo '✅ Pipeline Docker exécuté avec succès!'
            // En production, on enverrait des notifications
        }
        failure {
            echo '❌ Pipeline Docker échoué!'
            sh '''
                # Rollback en cas d'échec
                docker stop calculator-staging || true
                docker rm calculator-staging || true
            '''
        }
    }
}
EOF

# Commiter le nouveau Jenkinsfile
git add Jenkinsfile.docker
git commit -m "Add advanced Docker pipeline"
git push origin main
```

## Étape 6 : Webhooks et Déclenchement Automatique

### 6.1 Configuration des Webhooks Gitea

1. Dans Gitea, aller dans votre dépôt
2. Cliquer sur "Settings" > "Webhooks"
3. Cliquer "Add Webhook" > "Gitea"
4. Configurer :
   - **Target URL** : `http://jenkins:8080/gitea-webhook/post`
   - **HTTP Method** : POST
   - **POST Content Type** : application/json
   - **Trigger On** : Push events
5. Cliquer "Add Webhook"

### 6.2 Test du Déclenchement Automatique

```bash
# Faire un changement dans l'application
echo '
def subtract(a, b):
    """Soustraction de deux nombres"""
    return a - b
' >> app.py

# Ajouter un test pour la nouvelle fonction
echo '
    def test_subtract(self):
        """Test de la fonction soustraction"""
        self.assertEqual(subtract(5, 3), 2)
        self.assertEqual(subtract(0, 5), -5)
' >> test_app.py

# Commiter et pousser
git add .
git commit -m "Add subtract function with tests"
git push origin main

# Observer que Jenkins déclenche automatiquement un build
```

## Validation

Exécuter le script de validation pour vérifier que vous avez correctement réalisé l'exercice :

```bash
cd /workspace/03-jenkins-pipeline
./validate.sh
```

## Nettoyage

```bash
# Arrêter les containers de déploiement
docker stop calculator-staging calculator-prod-blue || true
docker rm calculator-staging calculator-prod-blue || true

# Supprimer les images créées
docker images | grep calculator-app | awk '{print $3}' | xargs docker rmi || true
```

## Points Clés à Retenir

1. **Pipeline as Code** : Jenkinsfile permet de versionner les pipelines
2. **Étapes du Pipeline** : Build, Test, Package, Deploy
3. **Agents Docker** : Isolation des environnements de build
4. **Déclenchement Automatique** : Webhooks pour CI/CD
5. **Approbations Manuelles** : Contrôle des déploiements critiques
6. **Post-Actions** : Nettoyage et notifications
7. **Blue-Green Deployment** : Stratégie de déploiement sans interruption

## Ressources Supplémentaires

- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Jenkinsfile Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Jenkins Docker Plugin](https://plugins.jenkins.io/docker-workflow/)
- [CI/CD Best Practices](https://docs.gitlab.com/ee/ci/pipelines/pipeline_efficiency.html)

## Conclusion

Vous avez maintenant une compréhension pratique des pipelines CI/CD avec Jenkins. Ces concepts sont fondamentaux pour l'automatisation DevOps et s'appliquent à d'autres outils comme GitLab CI, GitHub Actions, ou Azure DevOps.