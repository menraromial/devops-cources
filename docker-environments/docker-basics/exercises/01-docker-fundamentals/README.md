# Exercice 1 : Docker Fundamentals

**Durée estimée :** 60 minutes  
**Niveau :** Débutant  
**Prérequis :** Aucun

## Objectifs

À la fin de cet exercice, vous serez capable de :
- Utiliser les commandes Docker essentielles
- Comprendre la différence entre images et conteneurs
- Manipuler les volumes pour la persistance des données
- Configurer les réseaux Docker
- Utiliser un registry Docker local

## Contexte

Cet exercice vous fait découvrir les concepts fondamentaux de Docker à travers des manipulations pratiques. Vous allez apprendre à gérer des conteneurs, des images, des volumes et des réseaux.

## Prérequis Techniques

- Environnement Docker Lab démarré (`../start-lab.sh`)
- Accès au terminal
- Navigateur web pour tester les applications

## Étapes de l'Exercice

### Étape 1 : Découverte des Commandes de Base (15 minutes)

#### 1.1 Vérification de l'Installation
```bash
# Vérifier la version de Docker
docker --version

# Vérifier l'état du daemon Docker
docker info

# Lister les conteneurs en cours d'exécution
docker ps

# Lister tous les conteneurs (actifs et arrêtés)
docker ps -a
```

**Point de vérification :** Vous devriez voir plusieurs conteneurs du lab en cours d'exécution.

#### 1.2 Gestion des Images
```bash
# Lister les images locales
docker images

# Rechercher une image sur Docker Hub
docker search nginx

# Télécharger une image
docker pull alpine:latest

# Examiner les détails d'une image
docker inspect alpine:latest
```

**Point de vérification :** L'image Alpine doit apparaître dans la liste des images locales.

#### 1.3 Premier Conteneur
```bash
# Exécuter un conteneur simple
docker run hello-world

# Exécuter un conteneur interactif
docker run -it alpine:latest sh

# Dans le conteneur Alpine, exécuter quelques commandes
ls -la
cat /etc/os-release
exit
```

**Point de vérification :** Vous devez pouvoir interagir avec le shell Alpine et voir les informations du système.

### Étape 2 : Manipulation des Conteneurs (20 minutes)

#### 2.1 Conteneurs en Arrière-Plan
```bash
# Démarrer un serveur web Nginx en arrière-plan
docker run -d --name mon-nginx -p 8090:80 nginx:alpine

# Vérifier que le conteneur fonctionne
docker ps

# Tester l'accès au serveur web
curl http://localhost:8090
```

**Point de vérification :** Vous devriez voir la page d'accueil par défaut de Nginx.

#### 2.2 Gestion du Cycle de Vie
```bash
# Voir les logs du conteneur
docker logs mon-nginx

# Suivre les logs en temps réel (Ctrl+C pour arrêter)
docker logs -f mon-nginx

# Exécuter une commande dans un conteneur en cours
docker exec -it mon-nginx sh

# Dans le conteneur, modifier la page d'accueil
echo "<h1>Hello Docker Lab!</h1>" > /usr/share/nginx/html/index.html
exit

# Tester la modification
curl http://localhost:8090
```

**Point de vérification :** La page doit maintenant afficher "Hello Docker Lab!".

#### 2.3 Arrêt et Redémarrage
```bash
# Arrêter le conteneur
docker stop mon-nginx

# Vérifier l'état
docker ps -a

# Redémarrer le conteneur
docker start mon-nginx

# Tester à nouveau
curl http://localhost:8090
```

**Point de vérification :** La modification doit avoir été perdue (page par défaut de Nginx).

### Étape 3 : Volumes et Persistance (15 minutes)

#### 3.1 Volumes Nommés
```bash
# Créer un volume nommé
docker volume create mon-volume

# Lister les volumes
docker volume ls

# Inspecter le volume
docker volume inspect mon-volume

# Utiliser le volume avec un conteneur
docker run -d --name nginx-persistent -p 8091:80 -v mon-volume:/usr/share/nginx/html nginx:alpine
```

#### 3.2 Bind Mounts
```bash
# Créer un répertoire local
mkdir -p ~/docker-lab/html
echo "<h1>Page persistante avec bind mount</h1>" > ~/docker-lab/html/index.html

# Monter le répertoire local
docker run -d --name nginx-bind -p 8092:80 -v ~/docker-lab/html:/usr/share/nginx/html nginx:alpine

# Tester
curl http://localhost:8092

# Modifier le fichier local
echo "<h1>Modification depuis l'hôte</h1>" > ~/docker-lab/html/index.html

# Vérifier la modification
curl http://localhost:8092
```

**Point de vérification :** Les modifications du fichier local doivent être immédiatement visibles dans le conteneur.

### Étape 4 : Réseaux Docker (10 minutes)

#### 4.1 Réseaux par Défaut
```bash
# Lister les réseaux
docker network ls

# Inspecter le réseau bridge par défaut
docker network inspect bridge
```

#### 4.2 Réseau Personnalisé
```bash
# Créer un réseau personnalisé
docker network create mon-reseau

# Démarrer des conteneurs sur ce réseau
docker run -d --name app1 --network mon-reseau alpine:latest sleep 3600
docker run -d --name app2 --network mon-reseau alpine:latest sleep 3600

# Tester la communication entre conteneurs
docker exec app1 ping -c 3 app2
docker exec app2 ping -c 3 app1
```

**Point de vérification :** Les conteneurs doivent pouvoir se pinguer par leur nom.

### Étape 5 : Registry Local (10 minutes)

#### 5.1 Utilisation du Registry
```bash
# Le registry local est déjà démarré sur le port 5000
# Lister les images du registry (doit être vide initialement)
curl http://localhost:5000/v2/_catalog

# Taguer une image pour le registry local
docker tag alpine:latest localhost:5000/mon-alpine:v1

# Pousser l'image vers le registry local
docker push localhost:5000/mon-alpine:v1

# Vérifier que l'image est dans le registry
curl http://localhost:5000/v2/_catalog
```

#### 5.2 Récupération depuis le Registry
```bash
# Supprimer l'image locale
docker rmi localhost:5000/mon-alpine:v1

# Récupérer l'image depuis le registry local
docker pull localhost:5000/mon-alpine:v1

# Utiliser l'image récupérée
docker run --rm localhost:5000/mon-alpine:v1 echo "Image depuis le registry local !"
```

**Point de vérification :** L'image doit être récupérée depuis le registry local et fonctionner correctement.

## Nettoyage

```bash
# Arrêter et supprimer tous les conteneurs créés
docker stop mon-nginx nginx-persistent nginx-bind app1 app2
docker rm mon-nginx nginx-persistent nginx-bind app1 app2

# Supprimer le volume et le réseau
docker volume rm mon-volume
docker network rm mon-reseau

# Nettoyer les ressources inutilisées
docker system prune -f
```

## Validation

Exécutez le script de validation pour vérifier que vous avez correctement réalisé l'exercice :

```bash
./validate.sh
```

## Points Clés à Retenir

1. **Images vs Conteneurs** : Les images sont des templates, les conteneurs sont des instances en cours d'exécution
2. **Persistance** : Les données dans les conteneurs sont éphémères sauf si on utilise des volumes
3. **Réseaux** : Docker crée automatiquement des réseaux pour permettre la communication entre conteneurs
4. **Registry** : Permet de stocker et partager des images Docker
5. **Commandes essentielles** : `run`, `ps`, `logs`, `exec`, `stop`, `rm`

## Prochaines Étapes

Une fois cet exercice validé, vous pouvez passer à l'exercice 2 : "Custom Images" où vous apprendrez à créer vos propres images Docker avec des Dockerfiles.

## Ressources Supplémentaires

- [Documentation Docker - Get Started](https://docs.docker.com/get-started/)
- [Docker CLI Reference](https://docs.docker.com/engine/reference/commandline/cli/)
- [Docker Volumes](https://docs.docker.com/storage/volumes/)
- [Docker Networks](https://docs.docker.com/network/)