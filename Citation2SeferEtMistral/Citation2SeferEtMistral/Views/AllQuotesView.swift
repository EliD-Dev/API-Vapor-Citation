import SwiftUI

struct AllQuotesView: View {
    @EnvironmentObject var quoteService: QuoteService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient d'arrière-plan
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.green.opacity(0.1),
                        Color.mint.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    if quoteService.isLoading {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Chargement des citations...")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = quoteService.errorMessage {
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                            
                            Text("Erreur de chargement")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(error)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Réessayer") {
                                Task {
                                    await quoteService.fetchAllQuotes()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        }
                        .padding(40)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if quoteService.allQuotes.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "text.quote")
                                .font(.system(size: 50))
                                .foregroundColor(.green.opacity(0.6))
                            
                            Text("Aucune citation trouvée")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Il semblerait qu'il n'y ait pas de citations disponibles pour le moment.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(40)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(quoteService.allQuotes) { quote in
                                QuoteRowView(quote: quote)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .padding(.vertical, 4)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .refreshable {
                            await quoteService.fetchAllQuotes()
                        }
                    }
                }
            }
            .navigationTitle("Toutes les Citations")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    HStack {    
                        Button("Actualiser") {
                            Task {
                                await quoteService.fetchAllQuotes()
                            }
                        }
                        .disabled(quoteService.isLoading)
                    }
                }
            }
        }
        .task {
            if quoteService.allQuotes.isEmpty {
                await quoteService.fetchAllQuotes()
            }
        }
    }
}

struct QuoteRowView: View {
    let quote: Quote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "quote.opening")
                    .font(.headline)
                    .foregroundColor(.green.opacity(0.6))
                
                Spacer()
                
                Text("#\(quote.id)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            Text(quote.text)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineSpacing(2)
            
            HStack {
                if !quote.author.isEmpty {
                    Text("— \(quote.author)")
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(Color.secondary)
                }
                
                Spacer()
                
                PDFDownloadButton(
                    citation: quote.text,
                    type: .all
                )
                .scaleEffect(0.8)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary.opacity(0.05))
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

#Preview {
    AllQuotesView()
        .environmentObject(QuoteService())
}