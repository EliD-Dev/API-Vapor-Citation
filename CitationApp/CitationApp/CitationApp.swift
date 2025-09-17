import SwiftUI

@main
struct CitationApp: App {
    @StateObject private var quoteService = QuoteService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(quoteService)
        }
    }
}