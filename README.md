# TinyDesk

Cette application de bureau Flutter est conçue pour résoudre le problème de gestion quotidienne des commandes, des bouts de code et des notes fréquemment utilisés. L'objectif est de stocker et d'organiser des commandes (par exemple, des commandes terminal), des snippets de code, et des notes personnelles dans un espace dédié, facilement accessible, et synchronisable avec un serveur pour une utilisation optimale même en l'absence de connexion Internet.

## Features principales :
- [ ] **Authentification** :
    * [ ] Login
    * [ ] Inscription
    - Permet à l'utilisateur de créer un compte et de se connecter pour accéder à ses données personnelles.
    - Synchronisation des données entre plusieurs appareils via un serveur backend.

- [ ] **Ajout d'éléments** :
    * [ ] Commandes : Ajouter des commandes avec un titre, une description et la commande elle-même (peut être une ou plusieurs commandes).
    * [ ] Codes : Ajouter des extraits de code avec un titre, une description et le code à sauvegarder.
    * [ ] Notes : Ajouter des notes avec un titre et une description, pour stocker des informations importantes ou des rappels.

- [ ] **Catégories** :
    * [ ] Les éléments peuvent être classés en trois catégories : Commandes, Codes, et Notes, pour une meilleure organisation.

- **Recherche**
  - Permet à l'utilisateur de rechercher des commandes, des extraits de code ou des notes par titre ou description.

- **Configuration**
  - Mode sombre et mode clair pour personnaliser l'interface.
  - Option de synchronisation automatique des données lorsque la connexion est rétablie, ou synchronisation manuelle.

- **Déconnexion (Logout)**
  - Permet à l'utilisateur de se déconnecter de son compte.

- **Synchronisation en ligne**
  - La synchronisation des données avec un serveur en ligne est activée pour la sauvegarde des données et l'accès depuis différents appareils.

## Technologies utilisées

- **Flutter/Dart** : Framework pour le développement de l'application desktop.
- **SQLite** : Base de données locale pour le stockage des données en mode hors ligne.
- **Node** : Backend pour gérer l'authentification, la synchronisation et la gestion des données.
- **PostgreSQL** : Base de données pour le backend, utilisée pour l'authentification et la gestion des utilisateurs.

## Installation

1. **Prérequis**
   - Assurez-vous d'avoir installé Flutter et Dart sur votre machine.
   - Node.js et PostgreSQL doivent être installés pour la partie backend.

2. **Installation du projet**
   - Clonez le projet depuis le repository :

     ```bash
     git clone <lien-du-repository>
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

## Contributeurs

- **Tiavina Ramilison** : Software Engineer

## Licence

Ce projet est sous licence MIT.