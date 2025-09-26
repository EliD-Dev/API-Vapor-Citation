import SwiftUI

@main
struct Citation2SeferEtMistralApp: App {
    @StateObject private var quoteService = QuoteService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(quoteService)
        }
    }
}
