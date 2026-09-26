import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var repo: ChannelRepository

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("المظهر والثيمات").foregroundColor(themeManager.currentTheme.accentColor)) {
                    ForEach(ZhTheme.allCases) { th in
                        Button { themeManager.setTheme(th) } label: {
                            HStack {
                                Circle().fill(th.accentColor).frame(width: 18, height: 18)
                                Text(th.rawValue).foregroundColor(.white)
                                Spacer()
                                if themeManager.currentTheme == th { Image(systemName: "checkmark").foregroundColor(th.accentColor).bold() }
                            }
                        }
                    }
                }.listRowBackground(Color(white: 0.1))

                Section(header: Text("إعدادات المشغل").foregroundColor(themeManager.currentTheme.accentColor)) {
                    Toggle("إظهار الشعار المائي", isOn: $settings.watermarkEnabled)
                    if settings.watermarkEnabled {
                        HStack { Text("نص الشعار"); Spacer(); TextField("Zone66", text: $settings.watermarkTitle).multilineTextAlignment(.trailing).foregroundColor(themeManager.currentTheme.accentColor) }
                    }
                    Picker("أبعاد الفيديو", selection: $settings.videoAspectMode) {
                        Text("ملاءمة الشاشة").tag("fit")
                        Text("ملء الشاشة").tag("fill")
                    }
                    Toggle("التشغيل التلقائي", isOn: $settings.autoPlay)
                }.listRowBackground(Color(white: 0.1))

                Section(header: Text("الإحصائيات").foregroundColor(themeManager.currentTheme.accentColor)) {
                    HStack { Text("إجمالي القنوات"); Spacer(); Text("\(repo.channels.count)").foregroundColor(themeManager.currentTheme.accentColor).bold() }
                    HStack { Text("القنوات المخصصة"); Spacer(); Text("\(repo.channels.filter { $0.isCustom }.count)").foregroundColor(.gray) }
                    HStack { Text("الإصدار"); Spacer(); Text("3.1.0").foregroundColor(.gray) }
                }.listRowBackground(Color(white: 0.1))
            }
            .background(themeManager.currentTheme.backgroundDark.ignoresSafeArea())
            .navigationTitle("الإعدادات")
        }.navigationViewStyle(.stack)
    }
}
