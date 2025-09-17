import Vapor
import Fluent
import FluentSQLiteDriver

public func configure(_ app: Application) async throws {
    // Base de données SQLite
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    // Migrations (création + seed)
    app.migrations.add(CreateQuote())
    app.migrations.add(SeedQuotes())
    app.migrations.add(CreateDailyQuote())

    // Middleware fichiers statiques
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Routes
    try routes(app)
}
