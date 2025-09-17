// swift-tools-version:5.9
import PackageDescription

let package = Package(
name: "TaskAPI",
platforms: [
.macOS(.v13)
],
dependencies: [
// 💧 Vapor : Le framework web principal
.package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
// 🗄️ Fluent : ORM pour la gestion de base de données
.package(url: "https://github.com/vapor/fluent.git", from: "4.8.0"),
// 📦 Fluent SQLite : Driver SQLite pour Fluent
.package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
],
targets: [
// 👇 App devient une librairie
.target(
name: "App",
dependencies: [
.product(name: "Fluent", package: "fluent"),
.product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
.product(name: "Vapor", package: "vapor")
],
path: "Sources/App"
),
// 👇 Run devient l'exécutable (le point d'entrée avec @main)
.executableTarget(
name: "Run",
dependencies: [
.target(name: "App")
],
path: "Sources/Run"
),
// 👇 Tests
.testTarget(
name: "AppTests",
dependencies: [
.target(name: "App"),
.product(name: "XCTVapor", package: "vapor"),
],
path: "Tests/AppTests"
)
]
)
