# 📘 Développement d'une API REST avec Swift & Vapor

Bienvenue dans ce cours pratique sur le développement d'une API REST avec Swift et Vapor ! Ce projet vous guide pas à pas dans la création d'une API de gestion de tâches complète.

## 🎯 Objectifs pédagogiques

À la fin de ce cours, vous saurez :

- ✅ Comprendre les bases de Swift côté serveur
- ✅ Découvrir le framework Vapor et son écosystème
- ✅ Développer une API REST complète avec opérations CRUD
- ✅ Structurer correctement un projet Vapor (routes, contrôleurs, modèles, migrations)
- ✅ Manipuler une base de données SQLite avec Fluent ORM
- ✅ Tester une API avec des outils comme curl ou Postman
- ✅ Comprendre les concepts de validation de données et gestion d'erreurs

---

## API Vapor - Citation 

### Prérequis

Avant de commencer, assurez-vous d'avoir :

- **Swift 5.9+** installé sur votre système
- **Xcode** (sur macOS) ou **Swift for Windows/Linux**
- Un éditeur de code (VS Code, Xcode, etc.)
- **Git** pour la gestion de version

### Installation de Swift

#### Sur macOS :
```bash
# Swift est inclus avec Xcode
xcode-select --install

# Vérifiez l'installation
swift --version
```

#### Sur Windows :
1. Téléchargez Swift depuis [swift.org](https://swift.org/download/)
2. Suivez les instructions d'installation
3. Vérifiez avec `swift --version`

#### Sur Linux (Ubuntu) :
```bash
# Installation des dépendances
sudo apt-get update
sudo apt-get install clang libicu-dev

# Téléchargement et installation de Swift
wget https://swift.org/builds/swift-5.9-release/ubuntu2004/swift-5.9-RELEASE/swift-5.9-RELEASE-ubuntu20.04.tar.gz
tar xzf swift-5.9-RELEASE-ubuntu20.04.tar.gz
sudo mv swift-5.9-RELEASE-ubuntu20.04 /opt/swift
echo 'export PATH=/opt/swift/usr/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

### Installation de Vapor Toolbox (Optionnel)

Vapor Toolbox facilite la création de nouveaux projets :

```bash
# Installation via Homebrew (macOS)
brew install vapor

# Ou installation manuelle
git clone https://github.com/vapor/toolbox.git
cd toolbox
swift build -c release
sudo mv .build/release/vapor /usr/local/bin
```

### Création du projet
 
Notre projet est déjà configuré ! Voici comment il a été structuré :

1. **Package.swift** : Configuration des dépendances
2. **Sources/App/** : Code source principal
3. **Base de données** : SQLite configurée automatiquement

### Premier lancement

#### macOS / Linux

Dans le terminal, naviguez vers le dossier du projet et lancez :

```bash
# Compilation du projet
swift build

# Lancement du serveur
swift run

# Ou avec migrations automatiques
swift run Run serve --auto-migrate
```

#### Windows 11

Sur Windows, il est recommandé d'utiliser Docker pour éviter les problèmes de compilation avec SSL :

```powershell
# Vérifier que Docker et Docker Compose sont installés
docker --version
docker-compose --version

# Lancer tous les services avec Docker Compose
docker-compose up -d

# Vérifier les logs
docker-compose logs taskapi

# Suivre les logs en temps réel
docker-compose logs -f taskapi

# Arrêter tous les services
docker-compose down

# Redémarrer les services
docker-compose restart

# Reconstruire et relancer si des modifications ont été faites
docker-compose up -d --build
```

**Alternative avec compilation native (si Swift compile correctement) :**
```powershell
# Dans PowerShell
swift build
swift run Run serve --auto-migrate
```

### Commandes de migration

#### Exécuter les migrations manuellement

**macOS / Linux :**
```bash
# Exécuter toutes les migrations
swift run Run migrate

# Revenir en arrière (rollback)
swift run Run migrate --revert

# Voir le statut des migrations
swift run Run migrate --dry-run
```

**Windows (avec Docker Compose) :**
```powershell
# Exécuter les migrations
docker-compose exec taskapi ./Run migrate

# Revenir en arrière (rollback)
docker-compose exec taskapi ./Run migrate --revert

# Voir le statut des migrations
docker-compose exec taskapi ./Run migrate --dry-run

# Alternative : exécuter dans un container temporaire
docker-compose run --rm taskapi ./Run migrate
```

**Windows (compilation native) :**
```powershell
# Exécuter toutes les migrations
swift run Run migrate

# Revenir en arrière (rollback)  
swift run Run migrate --revert
```

Le serveur démarre sur `http://localhost:8080`

## 🌐 Routes disponibles

Une fois l'API lancée, vous pouvez accéder aux endpoints suivants :

### Endpoints principaux

| Méthode | Route | Description |
|---------|-------|-------------|
| GET | `/quotes` | Récupère toutes les citations |
| GET | `/quotes/random` | Récupère une citation aléatoire |
| GET | `/quotes/daily` | Récupère la citation du jour |
