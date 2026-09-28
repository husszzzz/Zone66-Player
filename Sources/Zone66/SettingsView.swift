import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var theme: Zone66Theme
    @EnvironmentObject var repository: ChannelRepository
    @EnvironmentObject var settings: Zone66Settings
    @ObservedObject var loc = LocalizationManager.shared

    @State private var showLanguagePicker = false

    var body: some View {
        NavigationView {
            List {
                // MARK: - App Brand Header
                Section {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(theme.accent.opacity(0.15))
                                .frame(width: 90, height: 90)

                            BundledImageView(name: "zh_logo", ext: "png", placeholder: "tv.fill")
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(theme.accent, lineWidth: 2))
                                .shadow(color: theme.accent.opacity(0.5), radius: 8)
                        }

                        Text("ZH TEAM TV PRO")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(.white)

                        Text("الإصدار 5.4.0 • المشغل الملكي للبث المباشر")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .listRowBackground(theme.card)

                // MARK: - Language Selector Button
                Section(header: Text(loc.tr("language")).foregroundColor(theme.accent)) {
                    Button {
                        showLanguagePicker = true
                    } label: {
                        HStack(spacing: 12) {
                            Text(loc.currentLanguage.flag)
                                .font(.system(size: 22))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(loc.tr("language"))
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)

                                Text(loc.currentLanguage.title)
                                    .font(.system(size: 12))
                                    .foregroundColor(theme.accent)
                            }

                            Spacer()

                            Image(systemName: "chevron.left")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                .listRowBackground(theme.card)

                // MARK: - Report a Problem (Contact Hussein Al-Hassani)
                Section(header: Text("الدعم الفني والإبلاغ").foregroundColor(theme.accent)) {
                    Link(destination: URL(string: "https://t.me/OM_G9")!) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.15))
                                    .frame(width: 38, height: 38)

                                Image(systemName: "exclamationmark.bubble.fill")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.orange)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("إبلاغ عن مشكلة")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)

                                Text("تواصل مباشر مع المطور حسين الحسني")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.6))
                            }

                            Spacer()

                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 13))
                                .foregroundColor(.orange)
                        }
                    }
                }
                .listRowBackground(theme.card)

                // MARK: - Development Team
                Section(header: Text("فريق العمل والإدارة").foregroundColor(theme.accent)) {
                    // Main Developer: Hussein Al-Hasani
                    HStack(spacing: 14) {
                        BundledImageView(name: "developer_hussein", ext: "jpg", placeholder: "person.crop.circle.fill")
                            .frame(width: 52, height: 52)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.red.opacity(0.8), lineWidth: 2))
                            .shadow(color: Color.red.opacity(0.4), radius: 5)

                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text("حسين الحسني")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)

                                Text("المطور الرئيسي")
                                    .font(.system(size: 10, weight: .heavy))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.red.opacity(0.2))
                                    .foregroundColor(.red)
                                    .cornerRadius(6)
                            }

                            Text("برمجة وتطوير تطبيق ZH TEAM")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.6))
                        }

                        Spacer()

                        Link(destination: URL(string: "https://t.me/OM_G9")!) {
                            HStack(spacing: 4) {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 12))
                                Text("@OM_G9")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.vertical, 6)

                    // Channel Manager & Designer: Abboud Scofield
                    HStack(spacing: 14) {
                        BundledImageView(name: "manager_abboud", ext: "jpg", placeholder: "person.crop.circle.fill")
                            .frame(width: 52, height: 52)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(theme.accent.opacity(0.8), lineWidth: 2))
                            .shadow(color: theme.accent.opacity(0.4), radius: 5)

                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text("عبود سكوفيلد")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)

                                Text("مصمم ومدير القنوات")
                                    .font(.system(size: 10, weight: .heavy))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(theme.accent.opacity(0.2))
                                    .foregroundColor(theme.accent)
                                    .cornerRadius(6)
                            }

                            Text("إدارة مصادر وسيرفرات البث")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.6))
                        }

                        Spacer()

                        Link(destination: URL(string: "https://t.me/rbf_8")!) {
                            HStack(spacing: 4) {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 12))
                                Text("@rbf_8")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.vertical, 6)
                }
                .listRowBackground(theme.card)

                // MARK: - Player & Performance Settings
                Section(header: Text("إعدادات المشغل والجودة").foregroundColor(theme.accent)) {
                    Toggle(isOn: .hardwareAcceleration) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("تسريع العتاد (Hardware Decoding)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            Text("تقليل استهلاك البطارية وسلاسة في 60fps")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }

                    Toggle(isOn: .lowLatencyMode) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("وضع البث فائق السرعة (Low Latency)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            Text("تقليل فارق البث المباشر لأقل من ثانيتين")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }

                    Toggle(isOn: .autoReconnect) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("إعادة الاتصال التلقائي")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            Text("استئناف البث فوراً في حال انقطاع الشبكة")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                .listRowBackground(theme.card)

                // MARK: - Data Synchronization
                Section(header: Text("مزامنة السيرفرات").foregroundColor(theme.accent)) {
                    Button {
                        repository.refresh()
                    } label: {
                        HStack {
                            Image(systemName: repository.isSyncing ? "arrow.triangle.2.circlepath" : "arrow.clockwise")
                                .foregroundColor(theme.accent)
                            Text("تحديث جدول المباريات والقنوات فوراً")
                                .foregroundColor(.white)
                            Spacer()
                            if repository.isSyncing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: theme.accent))
                            }
                        }
                    }

                    HStack {
                        Text("إجمالي القنوات الفعالة")
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("\(repository.enabledChannels.count)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(theme.accent)
                    }

                    HStack {
                        Text("عدد مباريات اليوم")
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("\(repository.matches.count)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(theme.accent)
                    }
                }
                .listRowBackground(theme.card)
            }
            .listStyle(InsetGroupedListStyle())
            .background(theme.background.ignoresSafeArea())
            .navigationTitle(loc.tr("settings"))
            .sheet(isPresented: ) {
                LanguageSelectionModal(isPresented: )
                    .environmentObject(theme)
                    .environmentObject(loc)
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct LanguageSelectionModal: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var theme: Zone66Theme
    @ObservedObject var loc = LocalizationManager.shared

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text(loc.tr("language"))
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()

                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)

                VStack(spacing: 12) {
                    ForEach(AppLanguage.allCases) { lang in
                        Button {
                            withAnimation(.easeInOut) {
                                loc.currentLanguage = lang
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                isPresented = false
                            }
                        } label: {
                            HStack(spacing: 14) {
                                Text(lang.flag)
                                    .font(.system(size: 26))

                                Text(lang.title)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)

                                Spacer()

                                if loc.currentLanguage == lang {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(theme.accent)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(loc.currentLanguage == lang ? theme.accent.opacity(0.15) : theme.card)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(loc.currentLanguage == lang ? theme.accent : Color.white.opacity(0.08), lineWidth: 1.5)
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }
}
