import Fluent

struct CreateDailyQuote: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("daily_quotes")
            .id()
            .field("date", .date, .required)
            .field("quote_id", .uuid, .required, .references("quotes", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("daily_quotes").delete()
    }
}
