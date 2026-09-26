import SwiftUI

struct ChannelManagerView: View {
    @EnvironmentObject var repo: ChannelRepository
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingAddSheet = false
    @State private var editingChannel: Channel?
    @State private var showingDeleteCustomAlert = false
    @State private var filterText = ""

    var displayedChannels: [Channel] {
        filterText.isEmpty ? repo.channels : repo.channels.filter {
            $0.name.localizedCaseInsensitiveContains(filterText) || $0.category.localizedCaseInsensitiveContains(filterText)
        }
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("إجراءات سريعة").foregroundColor(themeManager.currentTheme.accentColor)) {
                    Button { showingAddSheet = true } label: {
                        Label("إضافة قناة جديدة", systemImage: "plus.circle.fill").foregroundColor(themeManager.currentTheme.accentColor)
                    }
                    Button { showingDeleteCustomAlert = true } label: {
                        Label("حذف جميع القنوات المخصصة", systemImage: "trash.circle.fill").foregroundColor(.red)
                    }
                    Button { repo.resetToBundledDefaults() } label: {
                        Label("استعادة القنوات الافتراضية", systemImage: "arrow.counterclockwise.circle.fill").foregroundColor(.orange)
                    }
                }.listRowBackground(Color(white: 0.1))

                Section(header: Text("القنوات الحالية (\(repo.channels.count))").foregroundColor(themeManager.currentTheme.accentColor)) {
                    ForEach(displayedChannels, id: \.id) { ch in
                        HStack {
                            Button { editingChannel = ch } label: { Image(systemName: "pencil.circle").foregroundColor(themeManager.currentTheme.accentColor) }
                                .buttonStyle(BorderlessButtonStyle())
                            VStack(alignment: .leading, spacing: 2) {
                                Text(ch.name).font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                                Text("\(ch.category) \(ch.isCustom ? "• مخصصة" : "")").font(.system(size: 12)).foregroundColor(.gray)
                            }
                            Spacer()
                            Button { repo.deleteChannel(id: ch.id) } label: { Image(systemName: "trash").foregroundColor(.red.opacity(0.8)) }
                                .buttonStyle(BorderlessButtonStyle())
                        }.padding(.vertical, 4)
                    }
                }.listRowBackground(Color(white: 0.08))
            }
            .background(themeManager.currentTheme.backgroundDark.ignoresSafeArea())
            .navigationTitle("إدارة القنوات")
            .searchable(text: $filterText, prompt: "بحث في القنوات...")
            .sheet(isPresented: $showingAddSheet) { AddChannelSheet() }
            .sheet(item: $editingChannel) { EditChannelSheet(channel: $0) }
            .alert("حذف القنوات المخصصة", isPresented: $showingDeleteCustomAlert) {
                Button("حذف", role: .destructive) { repo.deleteAllCustomChannels() }
                Button("إلغاء", role: .cancel) {}
            } message: { Text("سيتم حذف القنوات التي أضفتها يدويًا فقط.") }
        }.navigationViewStyle(.stack)
    }
}

struct AddChannelSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var repo: ChannelRepository
    @EnvironmentObject var themeManager: ThemeManager
    @State private var name = ""
    @State private var url = ""
    @State private var category = "رياضة"
    private let categories = ["رياضة","أفلام","ترفيه","أخبار","أطفال","وثائقي","عام"]

    var body: some View {
        NavigationView {
            Form {
                Section("بيانات القناة") {
                    TextField("اسم القناة", text: $name)
                    TextField("رابط البث (m3u8 أو ts)", text: $url).autocapitalization(.none).disableAutocorrection(true)
                }
                Section("التصنيف") {
                    Picker("التصنيف", selection: $category) { ForEach(categories, id: \.self) { Text($0).tag($0) } }
                }
                Button("حفظ وإضافة القناة") {
                    let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    let u = url.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !n.isEmpty, !u.isEmpty else { return }
                    repo.addChannel(name: n, url: u, category: category)
                    dismiss()
                }.foregroundColor(themeManager.currentTheme.accentColor)
            }.navigationTitle("إضافة قناة").toolbar { ToolbarItem(placement: .cancellationAction) { Button("إلغاء") { dismiss() } } }
        }
    }
}

struct EditChannelSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var repo: ChannelRepository
    @EnvironmentObject var themeManager: ThemeManager
    let channel: Channel
    @State private var name: String
    @State private var url: String
    @State private var category: String

    init(channel: Channel) {
        self.channel = channel
        _name = State(initialValue: channel.name)
        _url = State(initialValue: channel.url)
        _category = State(initialValue: channel.category)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("تعديل البيانات") {
                    TextField("اسم القناة", text: $name)
                    TextField("رابط البث", text: $url).autocapitalization(.none)
                    TextField("التصنيف", text: $category)
                }
                Button("حفظ التعديلات") {
                    repo.updateChannel(id: channel.id, name: name, url: url, category: category)
                    dismiss()
                }.foregroundColor(themeManager.currentTheme.accentColor)
            }.navigationTitle("تعديل القناة").toolbar { ToolbarItem(placement: .cancellationAction) { Button("إلغاء") { dismiss() } } }
        }
    }
}
