@echo off
REM ===========================
REM 🚀 Script de démarrage pour Windows
REM ===========================

echo ==================================
echo 🎯 API de Gestion des Tâches
echo    Swift + Vapor
echo ==================================
echo.

echo [INFO] Vérification des prérequis...

REM Vérifier Swift
swift --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Swift n'est pas installé ou n'est pas dans le PATH
    echo [ERROR] Veuillez installer Swift depuis https://swift.org
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('swift --version') do (
    echo [SUCCESS] Swift trouvé: %%i
    goto :swift_found
)
:swift_found

REM Vérifier la structure du projet
if not exist "Package.swift" (
    echo [ERROR] Package.swift non trouvé. Êtes-vous dans le bon répertoire ?
    pause
    exit /b 1
)

echo [SUCCESS] Structure du projet validée

REM Configuration de l'environnement
echo [INFO] Configuration de l'environnement...

if not exist ".env" (
    if exist ".env.example" (
        echo [INFO] Création du fichier .env depuis .env.example
        copy ".env.example" ".env" >nul
    )
)

REM Résolution des dépendances
echo [INFO] Résolution des dépendances Swift Package Manager...
swift package resolve
if errorlevel 1 (
    echo [ERROR] Échec de la résolution des dépendances
    pause
    exit /b 1
)
echo [SUCCESS] Dépendances résolues avec succès

REM Compilation
echo [INFO] Compilation du projet...
swift build
if errorlevel 1 (
    echo [ERROR] Échec de la compilation
    pause
    exit /b 1
)
echo [SUCCESS] Compilation réussie

REM Démarrage de l'application
echo [INFO] Démarrage de l'API...
echo [INFO] L'API sera disponible sur http://localhost:8080
echo [WARNING] Appuyez sur Ctrl+C pour arrêter le serveur
echo.

REM Petite pause pour que l'utilisateur puisse lire les messages
timeout /t 2 /nobreak >nul

REM Démarrage
swift run App serve --hostname 0.0.0.0 --port 8080
