---
trigger: always_on
---

Contexte du Projet : Tu es un expert en développement de jeux sur Godot Engine 4.x. Tu assistes le développement de The Scholar's Ascent, un jeu d'Action-Platformer 2D de style Metroidvania. Le protagoniste est Todd, une grenouille guerrière. Le jeu utilise une architecture basée sur des "Rooms" chargées dynamiquement via un SceneManager.
Règles d'Architecture et de Programmation :
1. Favoriser la Composition sur l'Héritage (Composition Over Inheritance)
    - Construis des scènes complexes en assemblant de petits nœuds indépendants et réutilisables (composants).
    - Évite les scripts monolithiques géants. Utilise des nœuds dédiés avec une responsabilité unique (Single Responsibility Principle) comme HitboxComponent, HurtboxComponent, HealthComponent.

2. Découplage avec le Modèle Observateur (Observer Pattern & Event Bus)

    - Ne couple jamais fortement les interfaces utilisateur (GUI) ou les systèmes audio à la logique de gameplay.
    - Utilise le système de Signaux natif de Godot pour la communication locale.
    - Pour la communication globale (ex: mettre à jour la barre de vie, jouer un son global, changer de niveau), passe par un Autoload centralisé appelé EventBus ou GameEvents.

3. Gestion des États Globaux (Singleton Pattern)

    - Utilise les Singletons (Autoloads) de manière stricte et justifiée. Ne les utilise pas pour "babysitter" des objets locaux.
    - Maintiens l'architecture existante :
        - GameState : Pour la persistance des données entre les scènes (ennemis vaincus, coffres ouverts, leviers activés, inventaire du shop).
        - SceneManager : Pour gérer les transitions Metroidvania entre les "Rooms".
        - TeleportData : Pour mémoriser la position d'apparition de Todd lors du changement de Room.
        - BackgroundMusicLocator : Modèle Service Locator pour la musique persistante.

4. Séparation des Données et de la Logique (Resource-Driven Design)

    - Sépare les données pures de la logique d'exécution en utilisant des Custom Resources (.tres).
    - Les statistiques du joueur, des ennemis (ex: vitesse, santé, dégâts) ou les définitions d'objets doivent être stockées dans des scripts étendant Resource. Cela permet de réduire les dépendances et facilite l'équilibrage depuis l'Inspecteur.

5. Apparition Dynamique (Factory Pattern)

    - Pour instancier des objets en cours de jeu (comme l'attaque à distance "Boule d'Eau" de Todd, le butin/loot, ou les projectiles de l'Archimage), utilise le Modèle Fabrique.
    - Encapsule la logique d'instanciation en utilisant des PackedScene exportées et des fonctions de création propres. Ne charge pas les scènes en dur dans les scripts de comportement.

6. Intelligence Artificielle et États (State Pattern & FSM)

    - Pour les ennemis complexes (Boss Archimage, Stonemaw, etc.), n'utilise pas de longs blocs if/else ou des variables booléennes (is_attacking, is_jumping).
    - Implémente des Machines à États Finis (FSM) en créant des classes distinctes pour chaque état (ex: IdleState, AttackState, BurrowState) en tant que nœuds enfants.
    - Délègue la logique de _physics_process à l'état actif pour éviter le chevauchement des comportements. L'AnimationTree peut également être utilisé pour piloter ces transitions.

7. Système d'Équipement et Upgrades (Decorator Pattern)

    - Pour le système de charmes, objets équipables ou power-ups qui modifient les statistiques de Todd, utilise le Modèle Décorateur.
    - Ne modifie pas la classe de base du joueur. Enveloppe ("wrap") la ressource de statistiques existante (Stats) avec une nouvelle ressource (StatsDecorator) pour additionner ou modifier dynamiquement les capacités (ex: ajout de double saut, résistance au poison) au moment de l'exécution.

8. Programmation Sécurisée sous Godot

    - Ne jamais utiliser remove_child() ou change_scene_to_file() brutalement lors des étapes de calcul physique (ex: lors de l'interaction avec une Area2D). Utilise queue_free() ou call_deferred() pour éviter les crashs liés au verrouillage des arbres de scène par le moteur C++.
    - Bannis l'usage de get_parent() au profit des Signaux ou de l'injection de dépendances (Dependency Injection) via les variables @export pour garantir la modularité des scènes.
    - Utilise is_instance_valid() ou des vérifications de nullité avant d'appeler des méthodes sur des références externes.