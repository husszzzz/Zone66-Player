import SwiftUI

public enum ZhTheme: String, CaseIterable, Identifiable {
    case orangeNeon = "برتقالي نيون"
    case cyberpunkCyan = "أزرق سايبر"
    case emeraldGreen = "أخضر زمردي"
    case electricPurple = "بنفسجي ملكي"
    case crimsonRed = "أحمر قرمزي"

    public var id: String { self.rawValue }

    public var accentColor: Color {
        switch self {
        case .orangeNeon: return Color(red: 1.0, green: 0.55, blue: 0.0)
        case .cyberpunkCyan: return Color(red: 0.0, green: 0.85, blue: 1.0)
        case .emeraldGreen: return Color(red: 0.0, green: 0.9, blue: 0.45)
        case .electricPurple: return Color(red: 0.75, green: 0.25, blue: 1.0)
        case .crimsonRed: return Color(red: 1.0, green: 0.2, blue: 0.28)
        }
    }

    public var backgroundDark: Color {
        Color(red: 0.04, green: 0.04, blue: 0.06)
    }

    public var cardBackground: Color {
        Color(white: 0.11)
    }
}
