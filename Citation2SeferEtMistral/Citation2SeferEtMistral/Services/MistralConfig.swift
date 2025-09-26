import Foundation

struct MistralConfig {
    // IMPORTANT: Remplacez "YOUR_MISTRAL_API_KEY" par votre vraie clé API Mistral
    // Vous pouvez obtenir une clé API sur https://console.mistral.ai/
    static let apiKey = "jAvhE1O43hjw87vkGiNxq3cz2zMfa9di"
    
    // Configuration par défaut
    static let baseURL = "https://api.mistral.ai/v1/chat/completions"
    static let model = "mistral-large-latest"
    static let maxTokens = 300
    static let temperature = 0.7
    
    // Vérification si la clé API est configurée
    static var isConfigured: Bool {
        return apiKey != "YOUR_MISTRAL_API_KEY" && !apiKey.isEmpty
    }
}