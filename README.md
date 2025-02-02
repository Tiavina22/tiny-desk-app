# TinyDesk

This software est conçue pour résoudre le problème de gestion quotidienne des commandes, des bouts de code et des notes fréquemment utilisés. L'objectif est de stocker et d'organiser des commandes (par exemple, des commandes terminal), des snippets de code, et des notes personnelles dans un espace dédié, facilement accessible, et synchronisable avec un serveur pour une utilisation optimale même en l'absence de connexion Internet.

# TODO (priorité) :
- [ ] Refactoriser le code
- [ ] Mettre le code en clean

## Features principales :

### Done

## Plus de features
Pour le moment, je n'ai pas d'idées précises, mais cela viendra dans le futur.

## Technologies utilisées

- **Flutter/Dart** : Framework pour le développement de l'application desktop.
- **SQLite** : Base de données locale pour le stockage des données en mode hors ligne.
- **Node** : Backend pour gérer l'authentification, la synchronisation et la gestion des données.
- **PostgreSQL** : Base de données pour le backend, utilisée pour l'authentification et la gestion des utilisateurs.

## Installation

1. **Prérequis**
   - Assurez-vous d'avoir installé Flutter et Dart sur votre machine.
   - Node.js et PostgreSQL doivent être installés pour la partie backend.
   - Dependance pour la plateforme desktop : sqflite_common_ffi et sqflite :
   ```bash
      sudo apt install sqlite3 libsqlite3-dev
   ```

2. **Installation du projet**
   - Clonez le projet depuis le repository :

     ```bash
     git clone https://github.com/Tiavina22/tiny-desk-app
     ```

   - Installez les dépendances Flutter :

     ```bash
     flutter pub get
     ```

   - Installez les dépendances backend (Node.js) :

     ```bash
     cd backend
     npm install
     ```

   - Configurez PostgreSQL et la base de données pour l'authentification.

3. **Lancement du projet**
   - Lancez l'application Flutter :

     ```bash
     flutter run
     ```

   - Assurez-vous que le backend Node.js est en cours d'exécution :

     ```bash
     npm start
     ```

4. **Configurer la base de données**
   - Créez une base de données PostgreSQL et assurez-vous que les tables nécessaires pour l'authentification sont créées.

## Utilisation

1. **Authentification** : Créez un compte ou connectez-vous pour accéder à l'application.
2. **Ajout de commandes, codes et notes** : Utilisez l'interface pour ajouter des commandes, des extraits de code et des notes avec un titre et une description.
3. **Recherche** : Utilisez la barre de recherche pour trouver rapidement des éléments spécifiques.
4. **Configuration** : Personnalisez l'interface en mode sombre ou clair, et configurez la synchronisation.
5. **Déconnexion** : Déconnectez-vous de votre compte lorsque vous avez terminé.

## Avenir du projet

- Ajout de fonctionnalités pour améliorer l'expérience utilisateur.
- Amélioration de la gestion des données offline et online.
- Optimisation de la synchronisation automatique.
