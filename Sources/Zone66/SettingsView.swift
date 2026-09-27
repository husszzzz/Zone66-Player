import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var theme: Zone66Theme
    @EnvironmentObject var repository: ChannelRepository
    @EnvironmentObject var settings: Zone66Settings

    var body: some View {
        NavigationView {
            List {
                // MARK: - About ZH TEAM Header
                Section {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [theme.accent.opacity(0.3), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)

                            Text("ZH")
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundColor(theme.accent)
                        }

                        Text("ZH TEAM TV PRO")
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.white)

                        Text("الإصدار 5.0.0 • أقوى تطبيق بث مباشر")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .listRowBackground(theme.card)

                // MARK: - Development Team (حول التطبيق وفريق العمل)
                Section(header: Text("حول التطبيق وفريق العمل").foregroundColor(theme.accent)) {
                    // Main Developer
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .font(.system(size: 24))
                            .foregroundColor(theme.accent)

                        VStack(alignment: .leading, spacing: 3) {
                            Text("المطور الرئيسي")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                            Text("حسين الحسني")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        Link(destination: URL(string: "https://t.me/OM_G9")!) {
                            HStack(spacing: 6) {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 12))
                                Text("@OM_G9")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(theme.accent)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.vertical, 4)

                    // Designer & Channel Manager
                    HStack(spacing: 12) {
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 24))
                            .foregroundColor(theme.accent)

                        VStack(alignment: .leading, spacing: 3) {
                            Text("مصمم ومدير القنوات")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                            Text("عبود سكوفيلد")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        Link(destination: URL(string: "https://t.me/rbf_8")!) {
                            HStack(spacing: 6) {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 12))
                                Text("@rbf_8")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(theme.accent)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(theme.card)

                // MARK: - Playback Settings
                Section(header: Text("إعدادات المشغل").foregroundColor(.white.opacity(0.7))) {
                    Toggle("تشغيل تلقائي للبث", isOn: Binding(
                        get: { settings.autoPlay },
                        set: { val in settings.autoPlay = val }
                    ))
                    Toggle("ملء الشاشة تلقائياً", isOn: Binding(
                        get: { settings.fillVideo },
                        set: { val in settings.fillVideo = val }
                    ))
                    HStack {
                        Text("دعم Picture in Picture (PiP)")
                        Spacer()
                        Text("مفعل تلقائياً")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(theme.accent)
                    }
                }
                .listRowBackground(theme.card)

                // MARK: - Channels Management
                Section(header: Text("إدارة القنوات والبيانات").foregroundColor(.white.opacity(0.7))) {
                    HStack {
                        Text("القنوات المتوفرة")
                        Spacer()
                        Text("\(repository.enabledChannels.count)")
                            .fontWeight(.bold)
                            .foregroundColor(theme.accent)
                    }

                    HStack {
                        Text("المفضلة")
                        Spacer()
                        Text("\(repository.favoriteChannels.count)")
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }

                    Button {
                        repository.refresh()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("تحديث قائمة القنوات والمباريات")
                            Spacer()
                            if repository.isSyncing {
                                ProgressView()
                                    .tint(theme.accent)
                            }
                        }
                        .foregroundColor(theme.accent)
                    }
                }
                .listRowBackground(theme.card)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("الإعدادات")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
