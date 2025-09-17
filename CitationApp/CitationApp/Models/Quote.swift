import Foundation

struct Quote: Codable, Identifiable {
    let id: String
    let text: String
    let author: String
    
    var formattedText: String {
        return "« \(text) »"
    }
}

extension Quote {
    static let example = Quote(
        id: "1",
        text: "La seule façon de faire un excellent travail est d'aimer ce que vous faites.",
        author: "Steve Jobs"
    )
}