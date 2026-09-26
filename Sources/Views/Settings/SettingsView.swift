import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var repo: ChannelRepository

    var body: some View {
        NavigationView {
            List {
                // Real Theme Switcher
                Section(header: Text("المظهر والثيمات الحية").foregroundColor(themeManager.currentTheme.accentColor)) {
                    ForEach(ZhTheme.allCases) { th in
                        Button(action: {
                            themeManager.setTheme(th)
                        }) {
                            HStack {
                                Circle()
                                    .fill(th.accentColor)
                                    .frame(width: 18, height: 18)

                                Text(th.rawValue)
                                    .foregroundColor(.white)
                                    .font(.system(size: 15, weight: .medium))

                                Spacer()

                                if themeManager.currentTheme == th {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(th.accentColor)
                                        .bold()
                                }
                            }
                        }
                    }
                }
                .listRowBackground(Color(white: 0.1))

                // Watermark & Player Controls
                Section(header: Text("إعدادات المشغل والشعار").foregroundColor(themeManager.currentTheme.accentColor)) {
                    Toggle("إظهار شعار القناة المائي", isOn: $settings.watermarkEnabled)

                    if settings.watermarkEnabled {
                        HStack {
                            Text("نص الشعار")
                            Spacer()
                            TextField("Zh Team", text: $settings.watermarkTitle)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(themeManager.currentTheme.accentColor)
                        }
                    }

                    Picker("أبعاد الفيديو الافتراضية", selection: $settings.videoAspectMode) {
                        Text("ملاءمة الشاشة (Fit)").tag("fit")
                        Text("ملء الشاشة بالكامل (Fill)").tag("fill")
                    }
                }
                .listRowBackground(Color(white: 0.1))

                // App Stats
                Section(header: Text("إحصائيات المنصة").foregroundColor(themeManager.currentTheme.accentColor)) {
                    HStack {
                        Text("إجمالي القنوات المتاحة")
                        Spacer()
                        Text("\(repo.channels.count) قناة")
                            .foregroundColor(themeManager.currentTheme.accentColor)
                            .bold()
                    }
                    HStack {
                        Text("القنوات المخصصة المضافة")
                        Spacer()
                        Text("\(repo.channels.filter { $0.isCustom }.count)")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("فريق التطوير")
                        Spacer()
                        Text("Zh Team")
                            .bold()
                    }
                    HStack {
                        Text("الإصدار")
                        Spacer()
                        Text("3.0.0 Pro")
                            .foregroundColor(.gray)
                    }
                }
                .listRowBackground(Color(white: 0.1))
            }
            .background(themeManager.currentTheme.backgroundDark.ignoresSafeArea())
            .navigationTitle("الإعدادات")
        }
        .navigationViewStyle(.stack)
    }
}
