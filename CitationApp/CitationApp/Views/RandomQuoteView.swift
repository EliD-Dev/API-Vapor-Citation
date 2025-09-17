import SwiftUI

struct RandomQuoteView: View {
    @EnvironmentObject var quoteService: QuoteService
    @Environment(\.dismiss) private var dismiss
    
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
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Animation GIF placeholder
                        VStack {
                            Image(systemName: "shuffle")
                                .font(.system(size: 60))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.purple, .blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .rotationEffect(.degrees(quoteService.isLoading ? 360 : 0))
                                .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: quoteService.isLoading)
                            
                            Text("Citation Aléatoire")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        .padding(.top, 20)
                        
                        // Citation
                        VStack(spacing: 16) {
                            if quoteService.isLoading {
                                VStack(spacing: 16) {
                                    ProgressView()
                                        .scaleEffect(1.2)
                                    Text("Recherche d'une citation inspirante...")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(30)
                            } else if let error = quoteService.errorMessage {
                                VStack(spacing: 16) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.purple)
                                    
                                    Text("Oups !")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text(error)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                    
                                    Button("Réessayer") {
                                        Task {
                                            await quoteService.fetchRandomQuote()
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.large)
                                }
                                .padding(30)
                            } else if !quoteService.randomQuote.isEmpty {
                                VStack(spacing: 20) {
                                    Image(systemName: "quote.opening")
                                        .font(.system(size: 40))
                                        .foregroundColor(.purple.opacity(0.6))
                                    
                                    Text(quoteService.randomQuote)
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(4)
                                    
                                    Image(systemName: "quote.closing")
                                        .font(.system(size: 40))
                                        .foregroundColor(.purple.opacity(0.6))
                                }
                                .padding(30)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(UIColor.systemBackground))
                                .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 6)
                        )
                        .padding(.horizontal)
                        
                        // Bouton pour une nouvelle citation
                        if !quoteService.randomQuote.isEmpty {
                            Button(action: {
                                Task {
                                    await quoteService.fetchRandomQuote()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "dice")
                                    Text("Nouvelle Citation")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.purple, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: .purple.opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                            .disabled(quoteService.isLoading)
                        }
                        
                        Spacer(minLength: 30)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            if quoteService.randomQuote.isEmpty {
                await quoteService.fetchRandomQuote()
            }
        }
    }
}

#Preview {
    RandomQuoteView()
        .environmentObject(QuoteService())
}