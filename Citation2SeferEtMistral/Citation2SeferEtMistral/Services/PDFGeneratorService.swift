import Foundation
import PDFKit
import UIKit
import SwiftUI

@MainActor
class PDFGeneratorService: ObservableObject {
    @Published var isGenerating = false
    @Published var lastGeneratedURL: URL?
    
    func generatePDF(for citation: String, type: CitationType, theme: String? = nil) async -> URL? {
        isGenerating = true
        defer { isGenerating = false }
        
        let pdfDocument = PDFDocument()
        
        if type == .all && citation.contains("\n\n") {
            // Multi-citations : créer plusieurs pages
            let citations = citation.components(separatedBy: "\n\n")
            for (index, singleCitation) in citations.enumerated() {
                let page = createPDFPage(citation: singleCitation, type: type, theme: theme, pageNumber: index + 1, totalPages: citations.count)
                pdfDocument.insert(page, at: index)
            }
        } else {
            // Citation unique
            let page = createPDFPage(citation: citation, type: type, theme: theme)
            pdfDocument.insert(page, at: 0)
        }
        
        // Créer le nom du fichier
        let fileName = generateFileName(type: type, theme: theme)
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pdfURL = documentsPath.appendingPathComponent(fileName)
        
        print("📝 Tentative de sauvegarde PDF à : \(pdfURL.path)")
        
        // Sauvegarder le PDF avec gestion d'erreur
        do {
            // S'assurer que le répertoire existe
            try FileManager.default.createDirectory(at: documentsPath, withIntermediateDirectories: true, attributes: nil)
            
            // Supprimer le fichier s'il existe déjà
            if FileManager.default.fileExists(atPath: pdfURL.path) {
                try FileManager.default.removeItem(at: pdfURL)
            }
            
            // Sauvegarder le PDF
            if pdfDocument.write(to: pdfURL) {
                print("✅ PDF sauvegardé avec succès")
                
                // Vérifier que le fichier a bien été créé
                if FileManager.default.fileExists(atPath: pdfURL.path) {
                    let fileSize = try FileManager.default.attributesOfItem(atPath: pdfURL.path)[.size] as? Int64 ?? 0
                    print("✅ Fichier créé, taille: \(fileSize) bytes")
                    lastGeneratedURL = pdfURL
                    return pdfURL
                } else {
                    print("❌ Échec: Le fichier n'a pas été créé")
                }
            } else {
                print("❌ Échec de l'écriture du PDF")
            }
        } catch {
            print("❌ Erreur lors de la sauvegarde: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    private func createPDFPage(citation: String, type: CitationType, theme: String?, pageNumber: Int = 1, totalPages: Int = 1) -> PDFPage {
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4 format
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        
        let image = renderer.image { context in
            let cgContext = context.cgContext
            
            // Arrière-plan gradient
            drawGradientBackground(in: pageRect, context: cgContext)
            
            // Titre selon le type
            drawTitle(type: type, theme: theme, in: pageRect, context: cgContext)
            
            // Citation principale
            drawCitation(citation, in: pageRect, context: cgContext)
            
            // Signature Sefer
            drawSignature(in: pageRect, context: cgContext)
            
            // Footer avec date et type
            drawFooter(type: type, in: pageRect, context: cgContext, pageNumber: pageNumber, totalPages: totalPages)
            
            // Décoration
            drawDecorations(in: pageRect, context: cgContext)
        }
        
        let page = PDFPage(image: image)!
        return page
    }
    
    private func drawGradientBackground(in rect: CGRect, context: CGContext) {
        let colors = [
            UIColor.systemPurple.withAlphaComponent(0.1).cgColor,
            UIColor.systemBlue.withAlphaComponent(0.1).cgColor,
            UIColor.white.cgColor
        ]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0, 0.5, 1.0])!
        
        context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: rect.width, y: rect.height), options: [])
    }
    
    private func drawTitle(type: CitationType, theme: String?, in rect: CGRect, context: CGContext) {
        let title: String
        switch type {
        case .daily:
            title = "Citation du Jour"
        case .random:
            title = "Citation Aléatoire"
        case .all:
            title = "Collection de Citations"
        case .mistral:
            title = theme != nil ? "Citation Mistral AI - \(theme!)" : "Citation Mistral AI"
        }
        
        let titleFont = UIFont.boldSystemFont(ofSize: 28)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.systemPurple,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.alignment = .center
                return style
            }()
        ]
        
        let titleRect = CGRect(x: 50, y: 60, width: rect.width - 100, height: 50)
        title.draw(in: titleRect, withAttributes: titleAttributes)
    }
    
    private func drawCitation(_ citation: String, in rect: CGRect, context: CGContext) {
        let citationFont = UIFont.systemFont(ofSize: 20, weight: .medium)
        let citationAttributes: [NSAttributedString.Key: Any] = [
            .font: citationFont,
            .foregroundColor: UIColor.label,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.alignment = .center
                style.lineSpacing = 8
                return style
            }()
        ]
        
        // Ajouter des guillemets décoratifs
        let decoratedCitation = "« \(citation) »"
        
        let citationRect = CGRect(x: 80, y: 200, width: rect.width - 160, height: 400)
        decoratedCitation.draw(in: citationRect, withAttributes: citationAttributes)
    }
    
    private func drawSignature(in rect: CGRect, context: CGContext) {
        let signatureFont = UIFont.italicSystemFont(ofSize: 18)
        let signatureAttributes: [NSAttributedString.Key: Any] = [
            .font: signatureFont,
            .foregroundColor: UIColor.systemBlue,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.alignment = .right
                return style
            }()
        ]
        
        let signature = "- Sefer"
        let signatureRect = CGRect(x: rect.width - 200, y: 620, width: 150, height: 30)
        signature.draw(in: signatureRect, withAttributes: signatureAttributes)
    }
    
    private func drawFooter(type: CitationType, in rect: CGRect, context: CGContext, pageNumber: Int = 1, totalPages: Int = 1) {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "fr_FR")
        
        let footerText = totalPages > 1 ? 
            "Généré le \(formatter.string(from: Date())) • Citation2SeferEtMistral • Page \(pageNumber)/\(totalPages)" :
            "Généré le \(formatter.string(from: Date())) • Citation2SeferEtMistral"
        
        let footerFont = UIFont.systemFont(ofSize: 12)
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: footerFont,
            .foregroundColor: UIColor.systemGray,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.alignment = .center
                return style
            }()
        ]
        
        let footerRect = CGRect(x: 50, y: rect.height - 50, width: rect.width - 100, height: 20)
        footerText.draw(in: footerRect, withAttributes: footerAttributes)
    }
    
    private func drawDecorations(in rect: CGRect, context: CGContext) {
        // Lignes décoratives
        context.setStrokeColor(UIColor.systemPurple.withAlphaComponent(0.3).cgColor)
        context.setLineWidth(2)
        
        // Ligne du haut
        context.move(to: CGPoint(x: 80, y: 140))
        context.addLine(to: CGPoint(x: rect.width - 80, y: 140))
        
        // Ligne du bas
        context.move(to: CGPoint(x: 80, y: 680))
        context.addLine(to: CGPoint(x: rect.width - 80, y: 680))
        
        context.strokePath()
        
        // Étoiles décoratives
        drawStar(at: CGPoint(x: 100, y: 120), size: 15, context: context)
        drawStar(at: CGPoint(x: rect.width - 100, y: 120), size: 15, context: context)
        drawStar(at: CGPoint(x: 100, y: 700), size: 15, context: context)
        drawStar(at: CGPoint(x: rect.width - 100, y: 700), size: 15, context: context)
    }
    
    private func drawStar(at center: CGPoint, size: CGFloat, context: CGContext) {
        context.setFillColor(UIColor.systemPurple.withAlphaComponent(0.6).cgColor)
        
        let path = CGMutablePath()
        let numberOfPoints = 5
        let outerRadius = size
        let innerRadius = size * 0.4
        
        for i in 0..<numberOfPoints * 2 {
            let angle = CGFloat(i) * CGFloat.pi / CGFloat(numberOfPoints)
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let x = center.x + radius * cos(angle - CGFloat.pi / 2)
            let y = center.y + radius * sin(angle - CGFloat.pi / 2)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        context.addPath(path)
        context.fillPath()
    }
    
    private func generateFileName(type: CitationType, theme: String?) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        
        let typeString: String
        switch type {
        case .daily:
            typeString = "Citation_Jour"
        case .random:
            typeString = "Citation_Aleatoire"
        case .all:
            typeString = "Toutes_Citations"
        case .mistral:
            if let theme = theme {
                // Nettoyer le nom du thème pour le nom de fichier
                let cleanTheme = theme.replacingOccurrences(of: " ", with: "_")
                    .replacingOccurrences(of: "[^a-zA-Z0-9_-]", with: "", options: .regularExpression)
                typeString = "Mistral_\(cleanTheme)"
            } else {
                typeString = "Mistral"
            }
        }
        
        return "\(typeString)_\(timestamp).pdf"
    }
    
    // Méthode alternative pour copier vers un répertoire temporaire si nécessaire
    private func copyToAccessibleLocation(from originalURL: URL) -> URL? {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(originalURL.lastPathComponent)
        
        do {
            // Supprimer le fichier temporaire s'il existe
            if FileManager.default.fileExists(atPath: tempURL.path) {
                try FileManager.default.removeItem(at: tempURL)
            }
            
            try FileManager.default.copyItem(at: originalURL, to: tempURL)
            print("✅ PDF copié vers répertoire temporaire: \(tempURL.path)")
            return tempURL
        } catch {
            print("❌ Erreur lors de la copie: \(error.localizedDescription)")
            return nil
        }
    }
    
    func sharePDF(url: URL) {
        // Vérifier que le fichier existe et est lisible
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("❌ Erreur: Le fichier PDF n'existe pas à l'emplacement: \(url.path)")
            return
        }
        
        var finalURL = url
        
        // Si le fichier n'est pas lisible, essayer de le copier vers un répertoire temporaire
        if !FileManager.default.isReadableFile(atPath: url.path) {
            print("⚠️ Fichier non lisible, tentative de copie...")
            if let tempURL = copyToAccessibleLocation(from: url) {
                finalURL = tempURL
            } else {
                print("❌ Erreur: Impossible de rendre le fichier accessible")
                return
            }
        }
        
        print("✅ Fichier PDF prêt à partager: \(finalURL.path)")
        
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                
                // Vérifier qu'aucune modal n'est déjà présentée
                var presentingVC = rootVC
                while let presented = presentingVC.presentedViewController {
                    presentingVC = presented
                }
                
                let activityVC = UIActivityViewController(activityItems: [finalURL], applicationActivities: nil)
                
                // Configuration pour iPad
                if let popover = activityVC.popoverPresentationController {
                    popover.sourceView = presentingVC.view
                    popover.sourceRect = CGRect(x: presentingVC.view.bounds.midX, y: presentingVC.view.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                
                presentingVC.present(activityVC, animated: true) {
                    print("✅ UIActivityViewController présenté avec succès")
                }
            }
        }
    }
}

enum CitationType {
    case daily
    case random
    case all
    case mistral
}