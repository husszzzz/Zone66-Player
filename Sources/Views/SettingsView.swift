import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("إحصائيات المنصة").foregroundColor(.orange)) {
                    HStack {
                        Text("إجمالي القنوات")
                        Spacer()
                        Text("\(ChannelRepository.shared.channels.count) قناة")
                            .foregroundColor(.orange)
                            .bold()
                    }
                    HStack {
                        Text("دقة العرض")
                        Spacer()
                        Text("Full Native Retina")
                            .foregroundColor(.green)
                    }
                }
                .listRowBackground(Color(white: 0.1))

                Section(header: Text("معلومات التطبيق").foregroundColor(.orange)) {
                    HStack {
                        Text("اسم التطبيق")
                        Spacer()
                        Text("ZONE 66 TV")
                            .bold()
                    }
                    HStack {
                        Text("الإصدار")
                        Spacer()
                        Text("2.0.0 Cinema Edition")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("شعار القناة المدمج")
                        Spacer()
                        Text("Watermark Top-Right")
                            .foregroundColor(.gray)
                    }
                }
                .listRowBackground(Color(white: 0.1))
            }
            .background(Color(red: 0.04, green: 0.04, blue: 0.05).ignoresSafeArea())
            .navigationTitle("الإعدادات")
        }
        .navigationViewStyle(.stack)
    }
}
