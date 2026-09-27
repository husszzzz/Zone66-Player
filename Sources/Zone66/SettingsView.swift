import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var theme: Zone66Theme
    @EnvironmentObject var repository: ChannelRepository
    @EnvironmentObject var settings: Zone66Settings

    var body: some View {
        NavigationView {
            List {
                // MARK: - App Brand Header with Real Logo
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

                        Text("الإصدار 5.2.0 • المشغل الملكي للبث المباشر")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .listRowBackground(theme.card)

                // MARK: - Development Team (فريق العمل والمطورين)
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
                    Toggle(isOn: $settings.hardwareAcceleration) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("تسريع العتاد (Hardware Decoding)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            Text("تقليل استهلاك البطارية وسلاسة في 60fps")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }

                    Toggle(isOn: $settings.lowLatencyMode) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("وضع البث فائق السرعة (Low Latency)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            Text("تقليل فارق البث المباشر لأقل من ثانيتين")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }

                    Toggle(isOn: $settings.autoReconnect) {
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
            .navigationTitle("الإعدادات")
        }
        .navigationViewStyle(.stack)
    }
}
