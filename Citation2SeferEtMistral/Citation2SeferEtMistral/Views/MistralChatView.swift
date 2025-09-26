import SwiftUI

struct MistralChatView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var mistralService = MistralService()
    @State private var theme: String = ""
    @State private var showingGeneratedQuote = false
    @State private var isGenerating = false
    @State private var showCopyFeedback = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient d'arrière-plan
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.purple.opacity(0.1),
                        Color.blue.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Logo et titre
                    VStack(spacing: 16) {
                        Image("mistral")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Text("Chat Mistral AI")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Créez une citation personnalisée avec Sefer")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Zone de saisie du thème
                    VStack(spacing: 20) {
                        // Message d'information si l'API n'est pas configurée
                        if !MistralConfig.isConfigured {
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.orange)
                                    .font(.title2)
                                
                                Text("API Mistral non configurée")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                
                                Text("Les citations seront générées localement avec des modèles prédéfinis.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange.opacity(0.1))
                            )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Entrez un thème pour votre citation :")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Ex: persévérance, réussite, motivation...", text: $theme)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.body)
                                .padding(.horizontal, 4)
                        }
                        
                        // Bouton de génération
                        Button(action: generateQuote) {
                            HStack {
                                if isGenerating {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 20))
                                }
                                
                                Text(isGenerating ? "Génération en cours..." : "Générer une citation")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: theme.isEmpty || isGenerating ? [Color.gray, Color.gray] : [Color.purple, Color.blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: Color.purple.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(theme.isEmpty || isGenerating)
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 30)
                    
                    // Affichage de la citation générée
                    if !mistralService.generatedQuote.isEmpty {
                        VStack(spacing: 16) {
                            Text("Citation générée :")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            ScrollView {
                                Text(mistralService.generatedQuote)
                                    .font(.title3)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(nil)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                            }
                            .frame(minHeight: 100, maxHeight: 200)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.primary.opacity(0.05))
                                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                            )
                            
                            // Boutons d'action pour la citation
                            VStack(spacing: 12) {
                                HStack(spacing: 16) {
                                    Button(action: {
                                        copyToClipboard()
                                    }) {
                                        HStack {
                                            Image(systemName: showCopyFeedback ? "checkmark" : "doc.on.clipboard")
                                            Text(showCopyFeedback ? "Copié !" : "Copier")
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(showCopyFeedback ? Color.green : Color.blue)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Button(action: {
                                        generateQuote()
                                    }) {
                                        HStack {
                                            Image(systemName: "arrow.clockwise")
                                            Text("Régénérer")
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.purple)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                PDFDownloadButton(
                                    citation: mistralService.generatedQuote,
                                    type: .mistral,
                                    theme: theme
                                )
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                        }
                        .padding(.horizontal, 30)
                        .transition(.opacity.combined(with: .scale))
                    }
                    
                    if mistralService.hasError {
                        Text("Erreur lors de la génération. Veuillez réessayer.")
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.horizontal, 30)
                    }
                    
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func generateQuote() {
        guard !theme.isEmpty else { return }
        
        isGenerating = true
        Task {
            await mistralService.generateQuote(theme: theme)
            await MainActor.run {
                isGenerating = false
            }
        }
    }
    
    private func copyToClipboard() {
        let textToCopy = mistralService.generatedQuote
        print("📋 Tentative de copie : \(textToCopy)")
        
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        let success = pasteboard.setString(textToCopy, forType: .string)
        print("📋 Copie macOS réussie : \(success)")
        #else
        UIPasteboard.general.string = textToCopy
        print("📋 Copie iOS effectuée")
        #endif
        
        // Feedback visuel
        withAnimation(.easeInOut(duration: 0.25)) {
            showCopyFeedback = true
        }
        
        // Réinitialiser après 2 secondes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.25)) {
                showCopyFeedback = false
            }
        }
    }
}

#Preview {
    MistralChatView()
}