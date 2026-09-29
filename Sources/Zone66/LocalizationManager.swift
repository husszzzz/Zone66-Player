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

    var isRTL: Bool {
        switch self {
        case .arabic, .kurdish: return true
        case .english: return false
        }
    }

    var layoutDirection: LayoutDirection {
        return isRTL ? .rightToLeft : .leftToRight
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
            "cancel": [.arabic: "إلغاء", .english: "Cancel", .kurdish: "هەڵوەشاندنەوە"],
            "no_internet_title": [.arabic: "عذراً، تحتاج إلى الإنترنت", .english: "Internet Connection Required", .kurdish: "ببورە، پێویستت بە هێڵی ئینتەرنێتە"],
            "no_internet_desc": [.arabic: "يرجى التحقق من اتصال الواي فاي أو بيانات الهاتف للمتابعة", .english: "Please check your Wi-Fi or cellular network to continue", .kurdish: "تکایە دڵنیابە لە هێڵی ئینتەرنێت یان داتای مۆبایل"],
            "retry": [.arabic: "إعادة المحاولة", .english: "Try Again", .kurdish: "دووبارە هەوڵبدەرەوە"],
            "search_placeholder": [.arabic: "ابحث عن قناة أو بطولة...", .english: "Search channels or leagues...", .kurdish: "بگەڕێ بۆ کەناڵ یان یاری..."],
            "search_channels_prompt": [.arabic: "ابحث في القنوات...", .english: "Search channels...", .kurdish: "بگەڕێ لە کەناڵەکان..."],
            "language": [.arabic: "لغة التطبيق", .english: "App Language", .kurdish: "زمانی بەرنامە"],
            "quick_channels": [.arabic: "القنوات السريعة", .english: "Quick Channels", .kurdish: "کەناڵە خێراکان"],
            "screen_locked": [.arabic: "تم قفل الشاشة", .english: "Screen Locked", .kurdish: "شاشە قفڵ کرا"],
            "unlock": [.arabic: "إلغاء القفل", .english: "Unlock", .kurdish: "کردنەوەی قفڵ"],
            "channels_bundle": [.arabic: "باقة القنوات", .english: "Channels Package", .kurdish: "پاکێجی کەناڵەکان"],
            "no_matching_channels": [.arabic: "لا توجد قنوات مطابقة", .english: "No matching channels", .kurdish: "هیچ کەناڵێک نەدۆزرایەوە"],
            "no_matching_desc": [.arabic: "جرب البحث عن اسم آخر أو اختيار تصنيف مختلف", .english: "Try searching for another name or category", .kurdish: "ناوی تر یان بەشێکی تر هەڵبژێرە"],
            "favorites_empty": [.arabic: "المفضلة فارغة", .english: "Favorites is Empty", .kurdish: "دڵخوازەکان بەتاڵە"],
            "favorites_empty_desc": [.arabic: "اضغط على القلب داخل المشغل لحفظ القنوات هنا", .english: "Save favorite channels to show up here", .kurdish: "کەناڵە دڵخوازەکان لێرەدا پاشەکەوت بکە"],
            "no_matches_today": [.arabic: "لا توجد مباريات مسجلة حالياً", .english: "No matches scheduled today", .kurdish: "هیچ یارییەک لەم کاتەدا نییە"],
            "no_matches_desc": [.arabic: "يمكنك مزامنة المباريات والقنوات فوراً", .english: "Matches and channels can be synced instantly", .kurdish: "دەتوانیت یارییەکان و کەناڵەکان هاوکات بکەیت"],
            "app_subtitle": [.arabic: "الإصدار 1.0.0 • المشغل الملكي للبث المباشر", .english: "v1.0.0 • Royal Live Stream Player", .kurdish: "وەشانی 1.0.0 • پەخشکەری شاهانەی ڕاستەوخۆ"],
            "support_section": [.arabic: "الدعم الفني والإبلاغ", .english: "Support & Feedback", .kurdish: "پشتیوانی و ڕاپۆرتکردن"],
            "report_issue": [.arabic: "إبلاغ عن مشكلة", .english: "Report an Issue", .kurdish: "ڕاپۆرتکردنی کێشە"],
            "report_desc": [.arabic: "تواصل مباشر مع المطور حسين الحسني", .english: "Direct contact with developer Hussein", .kurdish: "پەیوەندی ڕاستەوخۆ لەگەڵ گەشەپێدەر حوسێن"],
            "team_section": [.arabic: "فريق العمل والإدارة", .english: "Team & Management", .kurdish: "تیمی کار و بەڕێوەبردن"],
            "dev_name": [.arabic: "حسين الحسني", .english: "Hussein Al-Hasani", .kurdish: "حوسێن حەسەنی"],
            "dev_badge": [.arabic: "المطور الرئيسي", .english: "Lead Developer", .kurdish: "گەشەپێدەری سەرەکی"],
            "dev_desc": [.arabic: "برمجة وتطوير تطبيق ZH TEAM", .english: "Programming & development of ZH TEAM", .kurdish: "بەرنامەسازی و گەشەپێدانی ZH TEAM"],
            "manager_name": [.arabic: "عبود سكوفيلد", .english: "Abboud Scofield", .kurdish: "عەبوود سکۆفێڵد"],
            "manager_badge": [.arabic: "مصمم ومدير القنوات", .english: "Designer & Channels Manager", .kurdish: "دیزاینەر و بەڕێوەبەری کەناڵەکان"],
            "manager_desc": [.arabic: "إدارة مصادر وسيرفرات البث", .english: "Managing stream servers & sources", .kurdish: "بەڕێوەبردنی سەرچاوەکانی پەخش"],
            "player_settings": [.arabic: "إعدادات المشغل والجودة", .english: "Player & Quality Settings", .kurdish: "ڕێکخستنەکانی پەخشکەر و کوالیتی"],
            "hw_accel": [.arabic: "تسريع العتاد (Hardware Decoding)", .english: "Hardware Decoding", .kurdish: "خێراکردنی ڕەقەکاڵا"],
            "low_latency": [.arabic: "وضع البث فائق السرعة (Low Latency)", .english: "Low Latency Mode", .kurdish: "دۆخی پەخشی خێرا"],
            "auto_reconnect": [.arabic: "إعادة الاتصال التلقائي", .english: "Auto Reconnect", .kurdish: "پەیوەستبوونەوەی خۆکار"],
            "server_sync": [.arabic: "مزامنة السيرفرات", .english: "Server Synchronization", .kurdish: "هاوکاتکردنی سێرڤەرەکان"],
            "sync_btn": [.arabic: "تحديث جدول المباريات والقنوات فوراً", .english: "Sync matches & channels now", .kurdish: "نوێکردنەوەی خێرای یارییەکان و کەناڵەکان"],
            "total_channels": [.arabic: "إجمالي القنوات الفعالة", .english: "Total Active Channels", .kurdish: "کۆی گشتی کەناڵە چالاکەکان"],
            "today_matches_count": [.arabic: "عدد مباريات اليوم", .english: "Today's Matches Count", .kurdish: "ژمارەی یارییەکانی ئەمڕۆ"],
            "fix_bugs_title": [.arabic: "إصلاح الأخطاء وإعادة التشغيل", .english: "Troubleshoot & Restart", .kurdish: "چاککردنی کێشەکان و دەستپێکردنەوە"],
            "fix_bugs_btn": [.arabic: "إصلاح الأخطاء", .english: "Fix Errors & Restart", .kurdish: "چاککردنی هەڵەکان"],
            "fix_bugs_desc": [.arabic: "مسح الذاكرة المؤقتة، إعادة تعيين الاتصالات، وإعادة تشغيل التطبيق فوراً", .english: "Clear cache, reset streams, and restart app state", .kurdish: "سڕینەوەی کاش، ڕێکخستنەوەی پەخش، و دەستپێکردنەوەی خێرا"],
            "fix_confirm_title": [.arabic: "إصلاح الأخطاء وإعادة التشغيل", .english: "Fix Errors & Restart", .kurdish: "چاککردنی کێشەکان"],
            "fix_confirm_msg": [.arabic: "هل تريد مسح الكاش وإعادة تهيئة القنوات والمباريات وإعادة تشغيل التطبيق؟", .english: "Do you want to clear cache, reload channels & matches, and restart the app?", .kurdish: "دەتەوێت کاش بسڕیتەوە و هەموو کەناڵ و یارییەکان ڕێکبخەیتەوە؟"],
            "fix_success": [.arabic: "تم إصلاح الأخطاء وإعادة تشغيل التطبيق بنجاح", .english: "Errors fixed & app restarted successfully", .kurdish: "کێشەکان چارەسەر کران و بەرنامە دەستی پێکردەوە"],
            "confirm": [.arabic: "متابعة", .english: "Continue", .kurdish: "بەردەوامبە"]
        ]

        if let translations = dict[key], let val = translations[currentLanguage] {
            return val
        }
        return key
    }
}
