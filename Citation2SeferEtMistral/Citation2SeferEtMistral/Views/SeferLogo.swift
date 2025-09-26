import SwiftUI

struct SeferLogo: View {
    @State private var currentFrame: Int = 1
    @State private var animationTimer: Timer?
    @State private var opacity: Double = 1.0
    
    // Liste des noms d'images à faire défiler
    private let frameNames = ["frame1", "frame2"]
    
    var body: some View {
        Image(frameNames[currentFrame - 1])
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 180, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(opacity)
            .onAppear {
                startAnimation()
            }
            .onDisappear {
                stopAnimation()
            }
    }
    
    private func startAnimation() {
        print("🎬 Démarrage de l'animation des frames Sefer")
        
        // Démarrer le timer qui change d'image toutes les 1.2 secondes avec transition douce
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { _ in
            // Transition douce avec fade out/in
            withAnimation(.easeInOut(duration: 0.3)) {
                opacity = 0.3
            }
            
            // Changer l'image après un court délai
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                currentFrame = currentFrame == 1 ? 2 : 1
                
                // Fade in avec la nouvelle image
                withAnimation(.easeInOut(duration: 0.3)) {
                    opacity = 1.0
                }
            }
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        print("⏹️ Arrêt de l'animation des frames Sefer")
    }
}