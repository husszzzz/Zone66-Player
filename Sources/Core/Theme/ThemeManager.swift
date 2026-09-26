import SwiftUI

public final class ThemeManager: ObservableObject {
    public static let shared = ThemeManager()
    @AppStorage("selected_theme_key") private var savedTheme: String = ZhTheme.orangeNeon.rawValue

    @Published public var currentTheme: ZhTheme = .orangeNeon {
        didSet { savedTheme = currentTheme.rawValue }
    }

    private init() {
        if let match = ZhTheme.allCases.first(where: { $0.rawValue == savedTheme }) {
            currentTheme = match
        }
    }

    public func setTheme(_ theme: ZhTheme) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentTheme = theme
        }
    }
}
