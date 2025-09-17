import Vapor
import Fluent

func routes(_ app: Application) throws {
    // Routes déjà existantes
    app.get("quotes") { req async throws -> [Quote] in
        try await Quote.query(on: req.db).all()
    }

    // ➕ Nouveau endpoint : GET /quotes/random
    app.get("quotes", "random") { req async throws -> String in
        guard let quote = try await Quote.query(on: req.db).all().randomElement() else {
            throw Abort(.notFound, reason: "No quotes found")
        }
        return quote.text
    }

        // ➕ Endpoint : GET /quotes/daily
        app.get("quotes", "daily") { req async throws -> String in
            let today = Calendar.current.startOfDay(for: Date())
            // Vérifie si une citation du jour existe déjà
            if let daily = try await DailyQuote.query(on: req.db)
                .filter(\.$date == today)
                .with(\.$quote)
                .first() {
                return daily.quote.text
            }
            // Récupère la citation du jour précédente (pour éviter doublon)
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)
            var excludeID: UUID? = nil
            if let yesterday = yesterday,
               let previous = try await DailyQuote.query(on: req.db)
                    .filter(\.$date == yesterday)
                    .first() {
                excludeID = previous.$quote.id
            }
            // Sélectionne une citation aléatoire différente de la veille
            var quotes = try await Quote.query(on: req.db).all()
            if let excludeID = excludeID {
                quotes.removeAll { $0.id == excludeID }
            }
            guard let chosen = quotes.randomElement(), let quoteID = chosen.id else {
                throw Abort(.notFound, reason: "No quotes available for daily selection")
            }
            // Stocke la citation du jour
            let daily = DailyQuote(date: today, quoteID: quoteID)
            try await daily.save(on: req.db)
            return chosen.text
        }
}
