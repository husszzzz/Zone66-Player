import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var theme: Zone66Theme
    @EnvironmentObject var repository: ChannelRepository
    @EnvironmentObject var settings: Zone66Settings

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("المشاهدة")) {
                    Toggle("التشغيل التلقائي", isOn: $settings.autoPlay)
                    Toggle("ملء الشاشة", isOn: $settings.fillVideo)
                    Toggle("العلامة المائية", isOn: $settings.watermarkEnabled)

                    if settings.watermarkEnabled {
                        TextField("نص العلامة المائية", text: $settings.watermarkText)
                    }
                }
                .listRowBackground(theme.card)

                Section(header: Text("البيانات")) {
                    HStack {
                        Text("القنوات المتاحة")
                        Spacer()
                        Text("\(repository.enabledChannels.count)")
                            .foregroundColor(theme.accent)
                    }

                    Button {
                        repository.refresh()
                    } label: {
                        HStack {
                            Text("تحديث القنوات الآن")
                            Spacer()
                            if repository.isLoading {
                                ProgressView()
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                    }
                }
                .listRowBackground(theme.card)

                Section(header: Text("حول التطبيق")) {
                    HStack {
                        Text("الإصدار")
                        Spacer()
                        Text("4.0.0")
                            .foregroundColor(.gray)
                    }

                    if !repository.remoteSettings.supportURL.isEmpty,
                       let url = URL(string: repository.remoteSettings.supportURL) {
                        Link(destination: url) {
                            Label(
                                repository.remoteSettings.supportTitle,
                                systemImage: "paperplane.fill"
                            )
                        }
                    }
                }
                .listRowBackground(theme.card)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("الإعدادات")
        }
        .navigationViewStyle(.stack)
    }
}
