import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var theme: Zone66Theme
    @EnvironmentObject var repository: ChannelRepository
    @EnvironmentObject var settings: Zone66Settings
    @EnvironmentObject var resetManager: AppResetManager
    @ObservedObject var loc = LocalizationManager.shared

    @State private var showLanguagePicker = false
    @State private var showFixAlert = false
    @State private var showSuccessNotice = false

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

                        Text(loc.tr("app_subtitle"))
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

                            Image(systemName: loc.currentLanguage.isRTL ? "chevron.left" : "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                .listRowBackground(theme.card)

                // MARK: - Troubleshooting & Reset (إصلاح الأخطاء)
                Section(header: Text(loc.tr("fix_bugs_title")).foregroundColor(theme.accent)) {
                    Button {
                        showFixAlert = true
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.18))
                                    .frame(width: 38, height: 38)

                                Image(systemName: "wrench.and.screwdriver.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.orange)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(loc.tr("fix_bugs_btn"))
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)

                                Text(loc.tr("fix_bugs_desc"))
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.6))
                            }

                            Spacer()

                            Image(systemName: "arrow.counterclockwise.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.orange)
                        }
                    }
                }
                .listRowBackground(theme.card)

                // MARK: - Report a Problem (Contact Hussein Al-Hassani)
                Section(header: Text(loc.tr("support_section")).foregroundColor(theme.accent)) {
                    Link(destination: URL(string: "https://t.me/OM_G9")!) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.15))
                                    .frame(width: 38, height: 38)

                                Image(systemName: "exclamationmark.bubble.fill")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.blue)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(loc.tr("report_issue"))
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)

                                Text(loc.tr("report_desc"))
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.6))
                            }

                            Spacer()

                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 13))
                                .foregroundColor(.blue)
                        }
                    }
                }
                .listRowBackground(theme.card)

                // MARK: - Development Team
                Section(header: Text(loc.tr("team_section")).foregroundColor(theme.accent)) {
                    // Main Developer: Hussein Al-Hasani
                    HStack(spacing: 14) {
                        BundledImageView(name: "developer_hussein", ext: "jpg", placeholder: "person.crop.circle.fill")
                            .frame(width: 52, height: 52)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.red.opacity(0.8), lineWidth: 2))
                            .shadow(color: Color.red.opacity(0.4), radius: 5)

                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text(loc.tr("dev_name"))
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)

                                Text(loc.tr("dev_badge"))
                                    .font(.system(size: 10, weight: .heavy))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.red.opacity(0.2))
                                    .foregroundColor(.red)
                                    .cornerRadius(6)
                            }

                            Text(loc.tr("dev_desc"))
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
                                Text(loc.tr("manager_name"))
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)

                                Text(loc.tr("manager_badge"))
                                    .font(.system(size: 10, weight: .heavy))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(theme.accent.opacity(0.2))
                                    .foregroundColor(theme.accent)
                                    .cornerRadius(6)
                            }

                            Text(loc.tr("manager_desc"))
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
                Section(header: Text(loc.tr("player_settings")).foregroundColor(theme.accent)) {
                    Toggle(loc.tr("hw_accel"), isOn: Binding(
                        get: { settings.hardwareAcceleration },
                        set: { settings.hardwareAcceleration = $0 }
                    ))
                    .foregroundColor(.white)

                    Toggle(loc.tr("low_latency"), isOn: Binding(
                        get: { settings.lowLatencyMode },
                        set: { settings.lowLatencyMode = $0 }
                    ))
                    .foregroundColor(.white)

                    Toggle(loc.tr("auto_reconnect"), isOn: Binding(
                        get: { settings.autoReconnect },
                        set: { settings.autoReconnect = $0 }
                    ))
                    .foregroundColor(.white)
                }
                .listRowBackground(theme.card)

                // MARK: - Data Synchronization
                Section(header: Text(loc.tr("server_sync")).foregroundColor(theme.accent)) {
                    Button {
                        repository.refresh()
                    } label: {
                        HStack {
                            Image(systemName: repository.isSyncing ? "arrow.triangle.2.circlepath" : "arrow.clockwise")
                                .foregroundColor(theme.accent)
                            Text(loc.tr("sync_btn"))
                                .foregroundColor(.white)
                            Spacer()
                            if repository.isSyncing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: theme.accent))
                            }
                        }
                    }

                    HStack {
                        Text(loc.tr("total_channels"))
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("\(repository.enabledChannels.count)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(theme.accent)
                    }

                    HStack {
                        Text(loc.tr("today_matches_count"))
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
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showLanguagePicker) {
            LanguageSelectionModal(isPresented: $showLanguagePicker)
                .environmentObject(theme)
                .environmentObject(loc)
        }
        .alert(isPresented: $showFixAlert) {
            Alert(
                title: Text(loc.tr("fix_confirm_title")),
                message: Text(loc.tr("fix_confirm_msg")),
                primaryButton: .destructive(Text(loc.tr("confirm"))) {
                    resetManager.restartApp()
                },
                secondaryButton: .cancel(Text(loc.tr("cancel")))
            )
        }
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
