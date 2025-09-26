import SwiftUI

struct HomeView: View {
    @StateObject private var quoteService = QuoteService()
    @State private var showDailyQuote = false
    @State private var showRandomQuote = false
    @State private var showAllQuotes = false
    @State private var showMistralChat = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient d'arrière-plan
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Logo et titre
                    VStack(spacing: 16) {
                        // Logo Sefer MP4 en boucle
                        SeferLogo()
                        
                        Text("Citations2Sefer")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Découvrez l'inspiration quotidienne")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    // Boutons principaux
                    VStack(spacing: 20) {
                        MenuButton(
                            title: "Citation du Jour",
                            icon: "calendar.badge.plus",
                            color: .orange,
                            action: { showDailyQuote = true }
                        )
                        
                        MenuButton(
                            title: "Citation Aléatoire",
                            icon: "shuffle",
                            color: .green,
                            action: { showRandomQuote = true }
                        )
                        
                        MenuButton(
                            title: "Toutes les Citations",
                            icon: "list.bullet.rectangle",
                            color: .blue,
                            action: { showAllQuotes = true }
                        )
                        
                        MenuButton(
                            title: "Mistral",
                            icon: "mistral",
                            color: .white,
                            action: { showMistralChat = true },
                            isCustomImage: true
                        )
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showDailyQuote) {
            DailyQuoteView()
                .environmentObject(quoteService)
        }
        .sheet(isPresented: $showRandomQuote) {
            RandomQuoteView()
                .environmentObject(quoteService)
        }
        .sheet(isPresented: $showAllQuotes) {
            AllQuotesView()
                .environmentObject(quoteService)
        }
        .sheet(isPresented: $showMistralChat) {
            MistralChatView()
        }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    let isCustomImage: Bool
    
    init(title: String, icon: String, color: Color, action: @escaping () -> Void, isCustomImage: Bool = false) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
        self.isCustomImage = isCustomImage
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Group {
                    if isCustomImage {
                        Image(icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 24))
                    }
                }
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .clipShape(Circle())
                .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.primary.opacity(0.05))
                    .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
}
