import Vapor

struct QuoteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let quotesRoute = routes.grouped("quotes")
        quotesRoute.post(use: create)
        quotesRoute.get(use: index)
        quotesRoute.get(":quoteID", use: show)
        quotesRoute.put(":quoteID", use: update)
        quotesRoute.delete(":quoteID", use: delete)
    }
    
    func create(req: Request) throws -> EventLoopFuture<Quote> {
        let quote = try req.content.decode(Quote.self)
        return quote.save(on: req.db).map { quote }
    }
    
    func index(req: Request) throws -> EventLoopFuture<[Quote]> {
        return Quote.query(on: req.db).all()
    }
    
    func show(req: Request) throws -> EventLoopFuture<Quote> {
        Quote.find(req.parameters.get("quoteID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func update(req: Request) throws -> EventLoopFuture<Quote> {
        let updatedQuote = try req.content.decode(Quote.self)
        return Quote.find(req.parameters.get("quoteID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { quote in
                quote.text = updatedQuote.text
                quote.author = updatedQuote.author
                return quote.save(on: req.db).map { quote }
            }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        Quote.find(req.parameters.get("quoteID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { quote in
                quote.delete(on: req.db)
            }.transform(to: .noContent)
    }
}
