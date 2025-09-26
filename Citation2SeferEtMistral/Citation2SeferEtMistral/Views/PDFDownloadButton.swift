import SwiftUI

struct PDFDownloadButton: View {
    let citation: String
    let type: CitationType
    let theme: String?
    
    @StateObject private var pdfGenerator = PDFGeneratorService()
    @State private var showingShareSheet = false
    @State private var showingSuccess = false
    @State private var showingError = false
    
    init(citation: String, type: CitationType, theme: String? = nil) {
        self.citation = citation
        self.type = type
        self.theme = theme
    }
    
    var body: some View {
        Button(action: generatePDF) {
            HStack(spacing: 8) {
                if pdfGenerator.isGenerating {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                } else if showingSuccess {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                } else if showingError {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "doc.badge.arrow.up")
                        .foregroundColor(.white)
                }
                
                Text(pdfGenerator.isGenerating ? "Génération..." : 
                     showingSuccess ? "PDF créé !" : 
                     showingError ? "Erreur" : "Télécharger PDF")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    colors: showingSuccess ? [.green, .green] : 
                            showingError ? [.red, .red] : [.orange, .red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .orange.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .disabled(pdfGenerator.isGenerating || citation.isEmpty)
        .buttonStyle(PlainButtonStyle())
        .onChange(of: pdfGenerator.lastGeneratedURL) { url in
            if let url = url {
                // Délai pour éviter les conflits de présentation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    pdfGenerator.sharePDF(url: url)
                }
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingSuccess = true
                }
                
                // Réinitialiser après 3 secondes
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingSuccess = false
                    }
                }
            }
        }
    }
    
    private func generatePDF() {
        // Réinitialiser les états
        showingSuccess = false
        showingError = false
        
        Task {
            let result = await pdfGenerator.generatePDF(for: citation, type: type, theme: theme)
            
            if result == nil {
                // Afficher l'erreur
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingError = true
                    }
                    
                    // Réinitialiser après 3 secondes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingError = false
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PDFDownloadButton(
            citation: "Sefer nous inspire : « La persévérance réside en chacun de nous, il suffit de la réveiller. »",
            type: .daily
        )
        
        PDFDownloadButton(
            citation: "Comme Spider-Man, Sefer sait que de grands pouvoirs impliquent de grandes responsabilités.",
            type: .mistral,
            theme: "Spider-Man"
        )
    }
    .padding()
}