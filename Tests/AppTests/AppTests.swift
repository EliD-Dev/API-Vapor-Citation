@testable import App
import XCTVapor

/**
 * AppTests.swift - Tests principaux de l'application
 * 
 * Ce fichier contient les tests de base pour vérifier que l'application
 * fonctionne correctement. Les tests sont essentiels pour :
 * - Vérifier que le code fonctionne comme attendu
 * - Éviter les régressions lors des modifications
 * - Documenter le comportement attendu
 */

final class AppTests: XCTestCase {
    
    // Instance de l'application pour les tests
    var app: Application!
    
    /**
     * Configuration avant chaque test
     * 
     * Cette méthode est appelée avant chaque test individual.
     * Elle configure une instance propre de l'application.
     */
    override func setUp() async throws {
        // Création de l'application en mode test
        app = Application(.testing)
        
        // Configuration de l'application (DB, routes, etc.)
        try await configure(app)
        
        // Application des migrations pour créer les tables
        try await app.autoMigrate()
    }
    
    /**
     * Nettoyage après chaque test
     * 
     * Cette méthode est appelée après chaque test pour nettoyer
     * les ressources et éviter les fuites mémoire.
     */
    override func tearDown() async throws {
        // Annulation des migrations (suppression des tables)
        try await app.autoRevert()
        
        // Arrêt propre de l'application
        app.shutdown()
    }
    
    // MARK: - Tests des routes de base
    
    /**
     * Test de la route d'accueil
     * 
     * Vérifie que GET / retourne bien le message de bienvenue
     */
    func testHomePage() async throws {
        try await app.test(.GET, "/") { req in
            // Pas de configuration spéciale pour cette requête
        } afterResponse: { res in
            // Vérification du code de statut
            XCTAssertEqual(res.status, .ok)
            
            // Vérification du contenu JSON
            let response = try res.content.decode([String: AnyCodable].self)
            XCTAssertEqual(response["message"]?.value as? String, 
                          "🎯 Bienvenue sur l'API de gestion des tâches !")
        }
    }
    
    /**
     * Test de la route hello
     * 
     * Vérifie que GET /hello retourne le bon message
     */
    func testHello() async throws {
        try await app.test(.GET, "/hello") { req in
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, 
                          "👋 Salut depuis Vapor ! L'API fonctionne parfaitement.")
        }
    }
    
    /**
     * Test de la route hello avec nom
     * 
     * Vérifie que GET /hello/:name personnalise le message
     */
    func testHelloWithName() async throws {
        try await app.test(.GET, "/hello/Etudiant") { req in
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, 
                          "👋 Salut Etudiant ! Bienvenue sur notre API Vapor.")
        }
    }
    
    /**
     * Test de la route de santé
     * 
     * Vérifie que GET /health retourne les informations de santé
     */
    func testHealthCheck() async throws {
        try await app.test(.GET, "/health") { req in
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            
            let health = try res.content.decode([String: AnyCodable].self)
            XCTAssertEqual(health["status"]?.value as? String, "healthy")
            XCTAssertEqual(health["version"]?.value as? String, "1.0.0")
        }
    }
    
    // MARK: - Tests des opérations CRUD sur les tâches
    
    /**
     * Test de création d'une tâche
     * 
     * Vérifie que POST /tasks crée bien une nouvelle tâche
     */
    func testCreateTask() async throws {
        let taskData = ["title": "Tâche de test", "isCompleted": false] as [String : Any]
        
        try await app.test(.POST, "/tasks") { req in
            req.headers.contentType = .json
            try req.content.encode(taskData)
        } afterResponse: { res in
            // Vérification du statut de création réussie
            XCTAssertEqual(res.status, .ok)
            
            // Vérification des données de la tâche créée
            let task = try res.content.decode(Task.self)
            XCTAssertEqual(task.title, "Tâche de test")
            XCTAssertFalse(task.isCompleted)
            XCTAssertNotNil(task.id)
            XCTAssertNotNil(task.createdAt)
        }
    }
    
    /**
     * Test de validation lors de la création
     * 
     * Vérifie que la validation empêche la création de tâches invalides
     */
    func testCreateTaskValidation() async throws {
        let invalidTaskData = ["title": "", "isCompleted": false] as [String : Any]
        
        try await app.test(.POST, "/tasks") { req in
            req.headers.contentType = .json
            try req.content.encode(invalidTaskData)
        } afterResponse: { res in
            // Doit retourner une erreur de validation
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    /**
     * Test de récupération de toutes les tâches
     * 
     * Vérifie que GET /tasks retourne la liste des tâches
     */
    func testGetAllTasks() async throws {
        // Création de tâches de test
        let task1 = Task(title: "Première tâche", isCompleted: false)
        let task2 = Task(title: "Deuxième tâche", isCompleted: true)
        
        try await task1.save(on: app.db)
        try await task2.save(on: app.db)
        
        try await app.test(.GET, "/tasks") { req in
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            
            let tasks = try res.content.decode([Task].self)
            XCTAssertEqual(tasks.count, 2)
            
            // Vérification que nos tâches sont présentes
            let titles = tasks.map { $0.title }
            XCTAssertTrue(titles.contains("Première tâche"))
            XCTAssertTrue(titles.contains("Deuxième tâche"))
        }
    }
    
    /**
     * Test de récupération d'une tâche spécifique
     * 
     * Vérifie que GET /tasks/:id retourne la bonne tâche
     */
    func testGetSpecificTask() async throws {
        // Création d'une tâche de test
        let task = Task(title: "Tâche spécifique", isCompleted: false)
        try await task.save(on: app.db)
        
        guard let taskId = task.id?.uuidString else {
            XCTFail("La tâche devrait avoir un ID")
            return
        }
        
        try await app.test(.GET, "/tasks/\(taskId)") { req in
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            
            let retrievedTask = try res.content.decode(Task.self)
            XCTAssertEqual(retrievedTask.title, "Tâche spécifique")
            XCTAssertFalse(retrievedTask.isCompleted)
            XCTAssertEqual(retrievedTask.id, task.id)
        }
    }
    
    /**
     * Test de récupération d'une tâche inexistante
     * 
     * Vérifie que GET /tasks/:id retourne 404 pour un ID inexistant
     */
    func testGetNonExistentTask() async throws {
        let fakeId = UUID().uuidString
        
        try await app.test(.GET, "/tasks/\(fakeId)") { req in
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        }
    }
    
    /**
     * Test de modification d'une tâche
     * 
     * Vérifie que PUT /tasks/:id modifie correctement une tâche
     */
    func testUpdateTask() async throws {
        // Création d'une tâche de test
        let task = Task(title: "Tâche à modifier", isCompleted: false)
        try await task.save(on: app.db)
        
        guard let taskId = task.id?.uuidString else {
            XCTFail("La tâche devrait avoir un ID")
            return
        }
        
        let updateData = ["title": "Tâche modifiée", "isCompleted": true] as [String : Any]
        
        try await app.test(.PUT, "/tasks/\(taskId)") { req in
            req.headers.contentType = .json
            try req.content.encode(updateData)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            
            let updatedTask = try res.content.decode(Task.self)
            XCTAssertEqual(updatedTask.title, "Tâche modifiée")
            XCTAssertTrue(updatedTask.isCompleted)
            XCTAssertEqual(updatedTask.id, task.id)
        }
    }
    
    /**
     * Test de suppression d'une tâche
     * 
     * Vérifie que DELETE /tasks/:id supprime correctement une tâche
     */
    func testDeleteTask() async throws {
        // Création d'une tâche de test
        let task = Task(title: "Tâche à supprimer", isCompleted: false)
        try await task.save(on: app.db)
        
        guard let taskId = task.id?.uuidString else {
            XCTFail("La tâche devrait avoir un ID")
            return
        }
        
        try await app.test(.DELETE, "/tasks/\(taskId)") { req in
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
        }
        
        // Vérification que la tâche a bien été supprimée
        try await app.test(.GET, "/tasks/\(taskId)") { req in
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        }
    }
    
    /**
     * Test de récupération des tâches en attente
     * 
     * Vérifie que GET /tasks/pending retourne seulement les tâches non terminées
     */
    func testGetPendingTasks() async throws {
        // Création de tâches de test
        let pendingTask = Task(title: "Tâche en attente", isCompleted: false)
        let completedTask = Task(title: "Tâche terminée", isCompleted: true)
        
        try await pendingTask.save(on: app.db)
        try await completedTask.save(on: app.db)
        
        try await app.test(.GET, "/tasks/pending") { req in
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            
            let tasks = try res.content.decode([Task].self)
            
            // Doit retourner seulement la tâche en attente
            XCTAssertEqual(tasks.count, 1)
            XCTAssertEqual(tasks[0].title, "Tâche en attente")
            XCTAssertFalse(tasks[0].isCompleted)
        }
    }
}

// MARK: - Extensions utilitaires pour les tests

/**
 * Extension pour faciliter le décodage de réponses mixtes
 */
struct AnyCodable: Codable {
    let value: Any
    
    init<T>(_ value: T?) {
        self.value = value ?? ()
    }
}

extension AnyCodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            value = arrayValue.map { $0.value }
        } else if let dictValue = try? container.decode([String: AnyCodable].self) {
            value = dictValue.mapValues { $0.value }
        } else {
            value = ()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let intValue as Int:
            try container.encode(intValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        default:
            try container.encodeNil()
        }
    }
}
