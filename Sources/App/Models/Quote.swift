import Vapor
import Fluent

final class Quote: Model, Content {
    static let schema = "quotes"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "text")
    var text: String
    
    @Field(key: "author")
    var author: String
    
    init() { }
    
    init(id: UUID? = nil, text: String, author: String) {
        self.id = id
        self.text = text
        self.author = author
    }
}
