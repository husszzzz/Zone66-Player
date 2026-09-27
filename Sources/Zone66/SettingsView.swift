import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var theme: Zone66Theme
    @EnvironmentObject var repository: ChannelRepository
    @EnvironmentObject var settings: Zone66Settings

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("التشغيل")) {
                    Toggle("تشغيل تلقائي", isOn: $settings.autoPlay)
                    Toggle("ملء الشاشة", isOn: $settings.fillVideo)
                }
                .listRowBackground(theme.card)

                Section(header: Text("القنوات")) {
                    HStack {
                        Text("عدد القنوات المتاحة")
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
                        Text("4.1.0")
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
