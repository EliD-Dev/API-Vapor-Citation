# Citation App iOS

Une application iOS en SwiftUI qui se connecte à l'API Vapor Citation pour afficher des citations inspirantes.

## Fonctionnalités

### Page d'Accueil
- Logo de l'application avec un design moderne
- 3 boutons principaux avec des gradients colorés :
  - **Citation du Jour** : Affiche la citation quotidienne
  - **Citation Aléatoire** : Génère une citation au hasard
  - **Toutes les Citations** : Liste complète des citations

### Citation du Jour
- Affichage de la date actuelle en français (format complet)
- Animation du soleil avec effet de pulsation
- Citation quotidienne récupérée depuis l'endpoint `/quotes/daily`
- Bouton de rechargement pour actualiser
- Design avec gradient orange/rose

### Citation Aléatoire  
- Animation de shuffle avec rotation continue
- Citation aléatoire récupérée depuis l'endpoint `/quotes/random`
- Bouton "Nouvelle Citation" pour en générer une autre
- Design avec gradient violet/bleu

### Toutes les Citations
- Liste défilable de toutes les citations disponibles
- Interface avec pull-to-refresh
- Chaque citation affichée dans une carte avec ombre
- Numérotation des citations
- Design avec gradient vert/menthe

## Architecture Technique

### Structure du Projet
```
CitationApp/
├── Models/
│   └── Quote.swift              # Modèle de données
├── Services/
│   └── QuoteService.swift       # Service réseau avec URLSession
├── Views/
│   ├── HomeView.swift          # Page d'accueil
│   ├── DailyQuoteView.swift    # Citation du jour
│   ├── RandomQuoteView.swift   # Citation aléatoire
│   └── AllQuotesView.swift     # Liste des citations
├── ContentView.swift           # Vue racine
└── CitationApp.swift          # Point d'entrée de l'app
```

### Technologies Utilisées
- **SwiftUI** : Interface utilisateur moderne et déclarative
- **async/await** : Gestion asynchrone des appels réseau
- **ObservableObject** : Pattern MVVM pour la réactivité
- **URLSession** : Communication avec l'API REST
- **NavigationView** : Navigation native iOS

### API Endpoints
- `GET /quotes/daily` : Citation du jour
- `GET /quotes/random` : Citation aléatoire  
- `GET /quotes` : Toutes les citations

## Configuration

### Prérequis
- Xcode 15.0+
- iOS 17.0+
- API Vapor Citation en cours d'exécution sur `localhost:8080`

### Installation
1. Ouvrir `CitationApp.xcodeproj` dans Xcode
2. S'assurer que l'API Vapor est démarrée (voir README principal)
3. Sélectionner un simulateur iOS ou un appareil
4. Appuyer sur ⌘+R pour compiler et lancer

### Réseau
L'application se connecte par défaut à `http://localhost:8080`. Pour utiliser un autre serveur, modifier la propriété `baseURL` dans `QuoteService.swift`.

## Design

### Couleurs et Thèmes
- **Citation du Jour** : Orange/Jaune (soleil, chaleur)
- **Citation Aléatoire** : Violet/Bleu (mystère, surprise)  
- **Toutes les Citations** : Vert/Menthe (croissance, collection)

### Animations
- Pulsation du soleil pour Citation du Jour
- Rotation continue pour Citation Aléatoire
- Transitions fluides entre les vues
- Pull-to-refresh pour la liste complète

### Responsive Design
- Support iPhone et iPad
- Adaptation automatique aux différentes tailles d'écran
- Mode sombre/clair automatique
- Polices et espacements adaptatifs

## Gestion d'Erreurs

L'application gère intelligemment :
- Erreurs de connexion réseau
- Données manquantes ou corrompues
- Timeouts de requêtes
- États de chargement avec indicateurs visuels
- Messages d'erreur localisés en français