import SwiftUI

struct ChannelManagerView: View {
    @EnvironmentObject var repo: ChannelRepository
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingAddSheet = false
    @State private var editingChannel: Channel?
    @State private var showingResetAlert = false
    @State private var showingDeleteCustomAlert = false
    @State private var filterText = ""

    var displayedChannels: [Channel] {
        if filterText.isEmpty {
            return repo.channels
        }
        return repo.channels.filter {
            $0.name.localizedCaseInsensitiveContains(filterText) ||
            $0.category.localizedCaseInsensitiveContains(filterText)
        }
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("إجراءات سريعة").foregroundColor(themeManager.currentTheme.accentColor)) {
                    Button(action: { showingAddSheet = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(themeManager.currentTheme.accentColor)
                            Text("إضافة قناة جديدة")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }

                    Button(action: { showingDeleteCustomAlert = true }) {
                        HStack {
                            Image(systemName: "trash.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.red)
                            Text("حذف جميع القنوات المخصصة")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }

                    Button(action: { showingResetAlert = true }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.orange)
                            Text("استعادة قائمة القنوات الافتراضية")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.orange)
                            Spacer()
                        }
                    }
                }
                .listRowBackground(Color(white: 0.1))

                Section(header: Text("القنوات الحالية (\(repo.channels.count))").foregroundColor(themeManager.currentTheme.accentColor)) {
                    ForEach(displayedChannels, id: \.id) { ch in
                        HStack {
                            Button(action: { editingChannel = ch }) {
                                Image(systemName: "pencil.circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(themeManager.currentTheme.accentColor)
                            }
                            .buttonStyle(BorderlessButtonStyle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(ch.name)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                Text("\(ch.category) \(ch.isCustom ? "• مخصصة" : "")")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            Button(action: {
                                repo.deleteChannel(id: ch.id)
                            }) {
                                Image(systemName: "trash")
                                    .font(.system(size: 16))
                                    .foregroundColor(.red.opacity(0.8))
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listRowBackground(Color(white: 0.08))
            }
            .background(themeManager.currentTheme.backgroundDark.ignoresSafeArea())
            .navigationTitle("إدارة القنوات")
            .searchable(text: $filterText, prompt: "بحث في القنوات...")
            .sheet(isPresented: $showingAddSheet) {
                AddChannelSheet()
            }
            .sheet(item: $editingChannel) { ch in
                EditChannelSheet(channel: ch)
            }
            .alert(isPresented: $showingDeleteCustomAlert) {
                Alert(
                    title: Text("حذف القنوات المخصصة"),
                    message: Text("هل أنت متأكد من رغبتك بحذف جميع القنوات التي أضفتها بنفسك؟"),
                    primaryButton: .destructive(Text("حذف")) {
                        repo.deleteAllCustomChannels()
                    },
                    secondaryButton: .cancel(Text("إلغاء"))
                )
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct AddChannelSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var repo: ChannelRepository
    @EnvironmentObject var themeManager: ThemeManager

    @State private var name: String = ""
    @State private var url: String = ""
    @State private var category: String = "رياضة"
    private let availableCategories = ["رياضة", "أفلام", "ترفيه", "أخبار", "أطفال", "وثائقي", "عام"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("بيانات القناة").foregroundColor(themeManager.currentTheme.accentColor)) {
                    TextField("اسم القناة (مثال: BeIN Sports 1)", text: $name)
                    TextField("رابط البث (m3u8 أو ts)", text: $url)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }

                Section(header: Text("التصنيف").foregroundColor(themeManager.currentTheme.accentColor)) {
                    Picker("التصنيف", selection: $category) {
                        ForEach(availableCategories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }

                Button(action: {
                    let trimName = name.trimmingCharacters(in: .whitespaces)
                    let trimUrl = url.trimmingCharacters(in: .whitespaces)
                    if !trimName.isEmpty && !trimUrl.isEmpty {
                        repo.addChannel(name: trimName, url: trimUrl, category: category)
                        dismiss()
                    }
                }) {
                    Text("حفظ وإضافة القناة")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                        .padding(.vertical, 8)
                }
                .listRowBackground(themeManager.currentTheme.accentColor)
            }
            .navigationTitle("إضافة قناة جديدة")
            .navigationBarItems(leading: Button("إلغاء") { dismiss() })
        }
    }
}

struct EditChannelSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var repo: ChannelRepository
    @EnvironmentObject var themeManager: ThemeManager

    let channel: Channel
    @State private var name: String = ""
    @State private var url: String = ""
    @State private var category: String = ""

    init(channel: Channel) {
        self.channel = channel
        _name = State(initialValue: channel.name)
        _url = State(initialValue: channel.url)
        _category = State(initialValue: channel.category)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("تعديل البيانات").foregroundColor(themeManager.currentTheme.accentColor)) {
                    TextField("اسم القناة", text: $name)
                    TextField("رابط البث", text: $url)
                        .autocapitalization(.none)
                    TextField("التصنيف", text: $category)
                }

                Button(action: {
                    repo.updateChannel(id: channel.id, name: name, url: url, category: category)
                    dismiss()
                }) {
                    Text("حفظ التعديلات")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                        .padding(.vertical, 8)
                }
                .listRowBackground(themeManager.currentTheme.accentColor)
            }
            .navigationTitle("تعديل القناة")
            .navigationBarItems(leading: Button("إلغاء") { dismiss() })
        }
    }
}
