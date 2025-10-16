import SwiftUI

struct AppFonts {
    static func recoleta(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if let _ = UIFont(name: "Recoleta-Regular", size: size) {
            return Font.custom("Recoleta-Regular", size: size)
        }
        return Font.system(size: size, weight: weight, design: .serif)
    }
    
    static func recoletaBold(size: CGFloat) -> Font {
        if let _ = UIFont(name: "Recoleta-Bold", size: size) {
            return Font.custom("Recoleta-Bold", size: size)
        }
        return Font.system(size: size, weight: .bold, design: .serif)
    }
    
    static func openSans(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let fontName: String
        switch weight {
        case .bold:
            fontName = "OpenSans-Bold"
        case .semibold:
            fontName = "OpenSans-SemiBold"
        case .medium:
            fontName = "OpenSans-Medium"
        case .light:
            fontName = "OpenSans-Light"
        default:
            fontName = "OpenSans-Regular"
        }
        
        if let _ = UIFont(name: fontName, size: size) {
            return Font.custom(fontName, size: size)
        }
        return Font.system(size: size, weight: weight)
    }
    
    static let title = recoletaBold(size: 28)
    static let headline = recoleta(size: 22)
    static let body = openSans(size: 16)
    static let caption = openSans(size: 14, weight: .light)
}

extension View {
    func customFont(_ font: Font) -> some View {
        self.font(font)
    }
}
