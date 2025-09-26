import SwiftUI

struct DailyQuoteView: View {
    @EnvironmentObject var quoteService: QuoteService
    @Environment(\.dismiss) private var dismiss
    
    private var currentDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .full
        return formatter.string(from: Date())
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient d'arrière-plan
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.orange.opacity(0.1),
                        Color.pink.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Animation GIF placeholder
                        VStack {
                            Image(systemName: "sun.max.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.orange, .yellow],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .scaleEffect(quoteService.isLoading ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 1).repeatForever(), value: quoteService.isLoading)
                            
                            Text("Citation du Jour")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        .padding(.top, 20)
                        
                        // Date
                        VStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .font(.system(size: 20))
                                .foregroundColor(.orange)
                            
                            Text(currentDateString)
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.primary.opacity(0.05))
                                .shadow(color: .gray.opacity(0.2), radius: 6, x: 0, y: 3)
                        )
                        .padding(.horizontal)
                        
                        // Citation
                        VStack(spacing: 16) {
                            if quoteService.isLoading {
                                VStack(spacing: 16) {
                                    ProgressView()
                                        .scaleEffect(1.2)
                                    Text("Chargement de votre citation du jour...")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(30)
                            } else if let error = quoteService.errorMessage {
                                VStack(spacing: 16) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.orange)
                                    
                                    Text("Oups !")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text(error)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                    
                                    Button("Réessayer") {
                                        Task {
                                            await quoteService.fetchDailyQuote()
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.large)
                                }
                                .padding(30)
                            } else if !quoteService.dailyQuote.isEmpty {
                                VStack(spacing: 20) {
                                    Image(systemName: "quote.opening")
                                        .font(.system(size: 40))
                                        .foregroundColor(.orange.opacity(0.6))
                                    
                                    Text(quoteService.dailyQuote)
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(4)
                                    
                                    Image(systemName: "quote.closing")
                                        .font(.system(size: 40))
                                        .foregroundColor(.orange.opacity(0.6))
                                }
                                .padding(30)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.primary.opacity(0.05))
                                .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 6)
                        )
                        .padding(.horizontal)
                        
                        // Boutons d'action
                        if !quoteService.dailyQuote.isEmpty {
                            HStack(spacing: 16) {
                                Button(action: {
                                    Task {
                                        await quoteService.fetchDailyQuote()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Actualiser")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [.orange, .pink],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: .orange.opacity(0.4), radius: 8, x: 0, y: 4)
                                }
                                .disabled(quoteService.isLoading)
                                
                                PDFDownloadButton(
                                    citation: quoteService.dailyQuote,
                                    type: .daily
                                )
                            }
                        }
                        
                        Spacer(minLength: 30)
                    }
                    .padding()
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
        .task {
            if quoteService.dailyQuote.isEmpty {
                await quoteService.fetchDailyQuote()
            }
        }
    }
}

#Preview {
    DailyQuoteView()
        .environmentObject(QuoteService())
}