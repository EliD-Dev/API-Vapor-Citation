# Dockerfile pour l'API de gestion des tâches Vapor
# Ce fichier permet de containeriser l'application pour un déploiement facile

# ===========================
# 📦 Stage 1: Build
# ===========================
FROM swift:5.9-jammy as build

# Installation des dépendances système
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y\
    && rm -rf /var/lib/apt/lists/*

# Création de l'utilisateur vapor pour la sécurité
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

# Définition du répertoire de travail
WORKDIR /app

# Copie des fichiers de configuration Swift Package Manager
COPY Package.* ./

# Résolution des dépendances (séparée pour optimiser le cache Docker)
RUN swift package resolve

# Copie du code source
COPY . .

# Compilation en mode release pour optimiser les performances
RUN swift build --enable-test-discovery -c release

# ===========================
# 📦 Stage 2: Run
# ===========================
FROM swift:5.9-jammy-slim

# Installation des dépendances runtime uniquement
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install -y \
      ca-certificates \
      tzdata \
    && rm -rf /var/lib/apt/lists/*

# Création de l'utilisateur vapor dans l'image finale
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

# Définition du répertoire de travail
WORKDIR /app

# Copie de l'exécutable depuis le stage de build
COPY --from=build --chown=vapor:vapor /app/.build/release/Run /app/Run

# Copie des ressources nécessaires
COPY --from=build --chown=vapor:vapor /app/Public /app/Public

# Basculement vers l'utilisateur vapor pour la sécurité
USER vapor:vapor

# Exposition du port 8080 (port par défaut de Vapor)
EXPOSE 8080

# Point d'entrée de l'application
ENTRYPOINT ["./Run"]

# Commande par défaut
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
