import Vapor
import Fluent

struct CreateQuote: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("quotes")
            .id()
            .field("text", .string, .required)
            .field("author", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("quotes").delete()
    }
}
