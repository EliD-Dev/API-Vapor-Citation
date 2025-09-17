#!/bin/bash

# ===========================
# 🚀 Script de démarrage pour l'API Vapor
# ===========================

set -e  # Arrêt en cas d'erreur

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher des messages colorés
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Banner
echo "=================================="
echo "🎯 API de Gestion des Tâches"
echo "   Swift + Vapor"
echo "=================================="
echo ""

# Vérification des prérequis
print_status "Vérification des prérequis..."

# Vérifier Swift
if ! command -v swift &> /dev/null; then
    print_error "Swift n'est pas installé. Veuillez installer Swift depuis https://swift.org"
    exit 1
fi

SWIFT_VERSION=$(swift --version | head -n1)
print_success "Swift trouvé: $SWIFT_VERSION"

# Vérifier la structure du projet
if [ ! -f "Package.swift" ]; then
    print_error "Package.swift non trouvé. Êtes-vous dans le bon répertoire ?"
    exit 1
fi

print_success "Structure du projet validée"

# Configuration de l'environnement
print_status "Configuration de l'environnement..."

# Copier le fichier d'environnement si nécessaire
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    print_status "Création du fichier .env depuis .env.example"
    cp .env.example .env
fi

# Résolution des dépendances
print_status "Résolution des dépendances Swift Package Manager..."
if swift package resolve; then
    print_success "Dépendances résolues avec succès"
else
    print_error "Échec de la résolution des dépendances"
    exit 1
fi

# Compilation
print_status "Compilation du projet..."
if swift build; then
    print_success "Compilation réussie"
else
    print_error "Échec de la compilation"
    exit 1
fi

# Fonction pour arrêter proprement l'application
cleanup() {
    print_warning "Arrêt de l'application..."
    exit 0
}

# Capture des signaux pour un arrêt propre
trap cleanup SIGINT SIGTERM

# Démarrage de l'application
print_status "Démarrage de l'API..."
print_status "L'API sera disponible sur http://localhost:8080"
print_warning "Appuyez sur Ctrl+C pour arrêter le serveur"
echo ""

# Petite pause pour que l'utilisateur puisse lire les messages
sleep 2

# Démarrage
swift run App serve --hostname 0.0.0.0 --port 8080
