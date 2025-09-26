import Foundation

@MainActor
class QuoteService: ObservableObject {
    private let baseURL = "http://localhost:8080"
    
    @Published var allQuotes: [Quote] = []
    @Published var dailyQuote: String = ""
    @Published var randomQuote: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let session = URLSession.shared
    
    // MARK: - Fetch Daily Quote
    func fetchDailyQuote() async {
        await performRequest(endpoint: "/quotes/daily") { [weak self] (result: String) in
            DispatchQueue.main.async {
                self?.dailyQuote = result
            }
        }
    }
    
    // MARK: - Fetch Random Quote
    func fetchRandomQuote() async {
        await performRequest(endpoint: "/quotes/random") { [weak self] (result: String) in
            DispatchQueue.main.async {
                self?.randomQuote = result
            }
        }
    }
    
    // MARK: - Fetch All Quotes
    func fetchAllQuotes() async {
        await performRequest(endpoint: "/quotes") { [weak self] (result: [Quote]) in
            DispatchQueue.main.async {
                self?.allQuotes = result
            }
        }
    }
    
    // MARK: - Generic Request Handler
    private func performRequest<T: Codable>(endpoint: String, completion: @escaping (T) -> Void) async {
        guard let url = URL(string: baseURL + endpoint) else {
            setError("URL invalide")
            return
        }
        
        setLoading(true)
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                setError("Erreur serveur")
                return
            }
            
            if T.self == String.self {
                let stringResult = String(data: data, encoding: .utf8) ?? ""
                completion(stringResult as! T)
            } else {
                let result = try JSONDecoder().decode(T.self, from: data)
                completion(result)
            }
            
            clearError()
            
        } catch {
            setError("Erreur de connexion: \(error.localizedDescription)")
        }
        
        setLoading(false)
    }
    
    // MARK: - Helper Methods
    @MainActor
    private func setLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    @MainActor
    private func setError(_ message: String) {
        errorMessage = message
    }
    
    @MainActor
    private func clearError() {
        errorMessage = nil
    }
}