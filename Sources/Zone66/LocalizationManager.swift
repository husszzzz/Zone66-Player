import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case arabic = "ar"
    case english = "en"
    case kurdish = "ku"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .arabic: return "العربية"
        case .english: return "English"
        case .kurdish: return "کوردی"
        }
    }

    var flag: String {
        switch self {
        case .arabic: return "🇮🇶"
        case .english: return "🇬🇧"
        case .kurdish: return "☀️"
        }
    }
}

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "app_lang")
        }
    }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "app_lang") ?? "ar"
        self.currentLanguage = AppLanguage(rawValue: saved) ?? .arabic
    }

    func tr(_ key: String) -> String {
        let dict: [String: [AppLanguage: String]] = [
            "home": [.arabic: "الرئيسية", .english: "Home", .kurdish: "سەرەکی"],
            "channels": [.arabic: "القنوات", .english: "Channels", .kurdish: "کەناڵەکان"],
            "favorites": [.arabic: "المفضلة", .english: "Favorites", .kurdish: "دڵخوازەکان"],
            "settings": [.arabic: "الإعدادات", .english: "Settings", .kurdish: "ڕێکخستنەکان"],
            "matches_today": [.arabic: "مباريات اليوم", .english: "Today's Matches", .kurdish: "یارییەکانی ئەمڕۆ"],
            "live_now": [.arabic: "مباشر الآن", .english: "LIVE NOW", .kurdish: "ڕاستەوخۆ"],
            "upcoming": [.arabic: "قادمة", .english: "Upcoming", .kurdish: "داهاتوو"],
            "finished": [.arabic: "انتهت", .english: "Finished", .kurdish: "کۆتایی هات"],
            "all": [.arabic: "الكل", .english: "All", .kurdish: "هەموو"],
            "watch_now": [.arabic: "مشاهدة البث", .english: "Watch Stream", .kurdish: "سەیرکردنی پەخش"],
            "choose_channel": [.arabic: "اختر القناة الناقلة", .english: "Select Channel", .kurdish: "کەناڵ هەڵبژێرە"],
            "no_internet_title": [.arabic: "عذراً، تحتاج إلى الإنترنت", .english: "Internet Connection Required", .kurdish: "ببورە، پێویستت بە هێڵی ئینتەرنێتە"],
            "no_internet_desc": [.arabic: "يرجى التحقق من اتصال الواي فاي أو بيانات الهاتف للمتابعة", .english: "Please check your Wi-Fi or cellular network to continue", .kurdish: "تکایە دڵنیابە لە هێڵی ئینتەرنێت یان داتای مۆبایل"],
            "retry": [.arabic: "إعادة المحاولة", .english: "Try Again", .kurdish: "دووبارە هەوڵبدەرەوە"],
            "search_placeholder": [.arabic: "ابحث عن قناة أو بطولة...", .english: "Search channels or leagues...", .kurdish: "بگەڕێ بۆ کەناڵ یان یاری..."],
            "language": [.arabic: "لغة التطبيق", .english: "App Language", .kurdish: "زمانی بەرنامە"],
            "quick_channels": [.arabic: "القنوات السريعة", .english: "Quick Channels", .kurdish: "کەناڵە خێراکان"],
            "screen_locked": [.arabic: "تم قفل الشاشة", .english: "Screen Locked", .kurdish: "شاشە قفڵ کرا"],
            "unlock": [.arabic: "إلغاء القفل", .english: "Unlock", .kurdish: "کردنەوەی قفڵ"]
        ]

        if let translations = dict[key], let val = translations[currentLanguage] {
            return val
        }
        return key
    }
}
