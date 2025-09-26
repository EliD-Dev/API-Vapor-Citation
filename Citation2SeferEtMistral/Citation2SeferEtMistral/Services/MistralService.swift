import Foundation

@MainActor
class MistralService: ObservableObject {
    @Published var generatedQuote: String = ""
    @Published var isLoading: Bool = false
    @Published var hasError: Bool = false
    
    func generateQuote(theme: String) async {
        isLoading = true
        hasError = false
        generatedQuote = ""
        
        print("🤖 Génération citation pour thème: \(theme)")
        
        do {
            let prompt = createPrompt(theme: theme)
            print("🤖 Prompt créé: \(prompt.prefix(200))...")
            let quote = try await callMistralAPI(prompt: prompt)
            print("🤖 Citation reçue: \(quote)")
            generatedQuote = quote
        } catch {
            print("❌ Erreur lors de la génération: \(error)")
            hasError = true
            // Citation de fallback en cas d'erreur
            let fallback = generateFallbackQuote(theme: theme)
            print("🔄 Utilisation fallback: \(fallback)")
            generatedQuote = fallback
        }
        
        isLoading = false
    }
    
    private func createPrompt(theme: String) -> String {
        let contextualPrompt = analyzeThemeContext(theme: theme)
        
        return """
        Créer une citation inspirante et motivante sur le thème : "\(theme)".
        maximum 2 lignes, en français,
        adapte toi au thème "\(theme)". pour être comme dans l'univers de ce thème
        Réponds uniquement avec la citation, sans guillemets ni introduction.
        """
    }
    
    private func analyzeThemeContext(theme: String) -> String {
        let lowerTheme = theme.lowercased()
        
        // Jeux vidéo populaires
        if lowerTheme.contains("rocket league") {
            return "Jeu de football avec voitures - évoque l'aérodynamisme, les saves impossibles, le travail d'équipe, la précision et les goals spectaculaires"
        } else if lowerTheme.contains("spider") && lowerTheme.contains("man") {
            return "Super-héros araignée - évoque les responsabilités, les pouvoirs d'araignée, sauver la ville, l'équilibre vie/héros, la toile et l'agilité"
        } else if lowerTheme.contains("fifa") || lowerTheme.contains("football") {
            return "Football - évoque la technique, les passes, les buts, l'esprit d'équipe, la tactique et la passion du ballon"
        } else if lowerTheme.contains("fortnite") {
            return "Battle royale - évoque la construction, la survie, la stratégie, l'adaptation et la victoire royale"
        } else if lowerTheme.contains("minecraft") {
            return "Monde de blocs - évoque la créativité, la construction, l'exploration, les ressources et l'imagination"
        } else if lowerTheme.contains("batman") {
            return "Chevalier noir - évoque la justice, Gotham, les gadgets, la détermination et la protection des innocents"
        } else if lowerTheme.contains("basketball") || lowerTheme.contains("basket") {
            return "Basketball - évoque les shoots, les dunks, l'adresse, l'équipe et la performance athlétique"
        } else if lowerTheme.contains("tennis") {
            return "Tennis - évoque la précision, les échanges, la concentration, l'endurance et la technique"
        } else if lowerTheme.contains("programming") || lowerTheme.contains("code") {
            return "Programmation - évoque les algorithmes, le debug, l'innovation, la logique et la création numérique"
        } else if lowerTheme.contains("music") || lowerTheme.contains("musique") {
            return "Musique - évoque l'harmonie, le rythme, l'émotion, la créativité et l'expression artistique"
        } else {
            return "Thème général - adapte avec des métaphores concrètes et des références spécifiques au domaine mentionné"
        }
    }
    
    private func callMistralAPI(prompt: String) async throws -> String {
        print("🔑 Vérification configuration API...")
        // Vérifier si l'API est configurée
        guard MistralConfig.isConfigured else {
            print("❌ API non configurée")
            throw MistralError.apiKeyNotConfigured
        }
        
        print("✅ API configurée, URL: \(MistralConfig.baseURL)")
        guard let url = URL(string: MistralConfig.baseURL) else {
            print("❌ URL invalide")
            throw MistralError.invalidURL
        }
        
        let requestBody: [String: Any] = [
            "model": MistralConfig.model,
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": MistralConfig.maxTokens,
            "temperature": MistralConfig.temperature
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(MistralConfig.apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw MistralError.encodingError
        }
        
        print("🌐 Envoi requête API...")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Réponse HTTP invalide")
            throw MistralError.serverError
        }
        
        print("📡 Code de réponse: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            print("❌ Erreur serveur: \(httpResponse.statusCode)")
            if let errorData = String(data: data, encoding: .utf8) {
                print("📄 Détails erreur: \(errorData)")
            }
            
            // Gestion spécifique de l'erreur 429 (quota dépassé)
            if httpResponse.statusCode == 429 {
                throw MistralError.quotaExceeded
            } else {
                throw MistralError.serverError
            }
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                throw MistralError.parsingError
            }
        } catch {
            throw MistralError.parsingError
        }
    }
    
    func generateFallbackQuote(theme: String) -> String {
        let lowerTheme = theme.lowercased()
        
        // Citations spécialisées selon le contexte détecté
        if lowerTheme.contains("rocket league") {
            let quotes = [
                "Sefer maîtrise chaque save impossible, car il sait que dans Rocket League comme dans la vie, c'est la persévérance qui mène à la victoire.",
                "Comme dans Rocket League, Sefer comprend que l'teamwork et la précision transforment chaque goal en chef-d'œuvre.",
                "Sefer vole vers ses rêves avec l'agilité d'une voiture de Rocket League, sachant que chaque boost compte."
            ]
            return quotes.randomElement()!
        } else if lowerTheme.contains("spider") && lowerTheme.contains("man") {
            let quotes = [
                "Comme Spider-Man, Sefer sait que de grands pouvoirs impliquent de grandes responsabilités, et que chaque défi est une toile à tisser.",
                "Sefer swingue à travers les obstacles de la vie avec l'agilité de Spider-Man, sachant que chaque chute prépare un nouveau saut.",
                "Tel Spider-Man protégeant New York, Sefer défend ses rêves avec courage et détermination."
            ]
            return quotes.randomElement()!
        } else if lowerTheme.contains("pokémon") || lowerTheme.contains("pokemon") {
            let quotes = [
                "Sefer collectionne les victoires comme un dresseur Pokémon, sachant que chaque échec l'entraîne vers l'évolution.",
                "Comme un maître Pokémon, Sefer comprend que la vraie force vient de l'amitié et de la persévérance.",
                "Sefer attrape ses rêves avec la détermination d'un dresseur Pokémon, car il sait qu'il faut tous les attraper."
            ]
            return quotes.randomElement()!
        } else if lowerTheme.contains("football") || lowerTheme.contains("fifa") {
            let quotes = [
                "Sur le terrain de la vie, Sefer dribble les obstacles avec la technique d'un grand footballeur.",
                "Sefer marque ses buts dans l'existence avec la précision d'un champion de football, sachant que chaque passe compte.",
                "Comme dans le football, Sefer joue en équipe avec la vie, transformant chaque défaite en leçon de victoire."
            ]
            return quotes.randomElement()!
        } else if lowerTheme.contains("basketball") || lowerTheme.contains("basket") {
            let quotes = [
                "Sefer shoot ses rêves dans le panier de la réussite avec la précision d'un basketteur professionnel.",
                "Comme au basketball, Sefer sait que chaque dunk de la vie nécessite un élan parfait et une détermination sans faille.",
                "Sur le terrain de l'existence, Sefer dribble vers ses objectifs avec l'agilité d'un champion de basket."
            ]
            return quotes.randomElement()!
        } else {
            // Citations générales mais personnalisées
            let fallbackQuotes = [
                "Comme le dit Sefer : « Le \(theme) n'est pas une destination, c'est un voyage qui forge l'âme. »",
                "Sefer nous enseigne que le \(theme) naît dans l'action, pas dans l'attente.",
                "« Chaque jour est une nouvelle opportunité de cultiver le \(theme) », rappelle Sefer avec sagesse.",
                "Dans les mots de Sefer : « Le \(theme) authentique commence par croire en ses propres rêves. »",
                "Sefer l'affirme : « Le \(theme) n'est pas un don, c'est une décision quotidienne. »"
            ]
            return fallbackQuotes.randomElement() ?? "Sefer nous inspire : « Le \(theme) réside en chacun de nous, il suffit de le réveiller. »"
        }
    }
}

enum MistralError: Error {
    case invalidURL
    case encodingError
    case serverError
    case parsingError
    case apiKeyNotConfigured
    case quotaExceeded
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "URL invalide"
        case .encodingError:
            return "Erreur d'encodage"
        case .serverError:
            return "Erreur serveur"
        case .parsingError:
            return "Erreur de parsing"
        case .apiKeyNotConfigured:
            return "Clé API Mistral non configurée"
        case .quotaExceeded:
            return "Quota API dépassé - utilisation du mode local"
        }
    }
}
