import Fluent
import Vapor

final class DailyQuote: Model, Content {
    static let schema = "daily_quotes"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "date")
    var date: Date

    @Parent(key: "quote_id")
    var quote: Quote

    init() {}

    init(id: UUID? = nil, date: Date, quoteID: UUID) {
        self.id = id
        self.date = date
        self.$quote.id = quoteID
    }
}
