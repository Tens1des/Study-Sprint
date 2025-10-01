import SwiftUI

struct TagsView: View {
    @EnvironmentObject var app: AppState
    @State private var newName: String = ""
    @State private var showAdd = false
    @State private var newIcon: String = "book.fill"
    @State private var newColor: String = "6C5CE7"
    @State private var focusMin: Int = 25
    @State private var breakMin: Int = 5

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Subjects").font(.largeTitle.bold())
                Text("Manage your study categories").foregroundColor(.secondary)

                Button(action: { showAdd = true }) {
                    HStack(spacing: 10) {
                        Image(systemName: "plus").font(.headline)
                        Text("Add new subject").fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                            .foregroundColor(Color.blue.opacity(0.6))
                    )
                }

                VStack(spacing: 16) {
                    ForEach(app.tags) { tag in
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14).fill(Color.white)
                                    .frame(width: 56, height: 56)
                                Image(systemName: tag.iconSystemName).font(.title2)
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                Text(tag.name).font(.headline)
                                Text("\(sessionsCount(for: tag)) sessions").font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(action: { setDefault(tag) }) { Image(systemName: tag.isDefault ? "star.fill" : "star") }
                            Button(action: { delete(tag) }) { Image(systemName: "trash") }
                        }
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color(UIColor.secondarySystemBackground)))
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                    }
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAdd) {
            NavigationStack { addSheet }
        }
    }

    private var addSheet: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("New subject").font(.title.bold())
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Subject name").font(.subheadline)
                        TextField("Mathematics", text: $newName)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose icon").font(.subheadline)
                        iconGrid
                    }
                }

                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose color").font(.subheadline)
                        colorGrid
                    }
                }

                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Session duration").font(.subheadline)
                        HStack {
                            Stepper(value: $focusMin, in: 5...120, step: 5) { Text("Focus: \(focusMin) min") }
                        }
                        HStack {
                            Stepper(value: $breakMin, in: 1...60, step: 1) { Text("Break: \(breakMin) min") }
                        }
                    }
                }

                Button("Add subject") { addTag() }
                    .buttonStyle(.borderedProminent)
                    .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
    }

    private func sessionsCount(for tag: Tag) -> Int {
        app.sessions.filter { $0.tagId == tag.id }.count
    }

    private func addTag() {
        let tag = Tag(name: newName, iconSystemName: newIcon, colorHex: newColor, isDefault: app.tags.isEmpty, preferredFocusSec: focusMin*60, preferredBreakSec: breakMin*60)
        app.tags.append(tag)
        newName = ""
        newIcon = "book.fill"
        newColor = "6C5CE7"
        focusMin = max(5, app.settings.defaultFocusSec/60)
        breakMin = max(1, app.settings.defaultBreakSec/60)
        app.save()
        showAdd = false
    }

    private func delete(_ tag: Tag) {
        if let idx = app.tags.firstIndex(where: { $0.id == tag.id }) {
            app.tags.remove(at: idx)
            if !app.tags.contains(where: { $0.isDefault }), let first = app.tags.first { setDefault(first) }
            app.save()
        }
    }

    private func setDefault(_ tag: Tag) {
        app.tags = app.tags.map { t in
            var m = t
            m.isDefault = (t.id == tag.id)
            return m
        }
        app.save()
    }
}

// MARK: - Add Sheet controls
extension TagsView {
    private var iconCandidates: [String] {
        ["books.vertical.fill","ruler","pencil.and.ruler","paintpalette.fill","music.note","laptopcomputer","globe","book.fill","highlighter","paperclip","chart.bar.fill","person.circle.fill","building.columns.fill","target","brain.head.profile"]
    }

    private var colorsHex: [String] { ["6C5CE7","1ABC9C","2ECC71","3498DB","F1C40F","E67E22","E74C3C","E84393","27AE60","F39C12","8E44AD","16A085"] }

    private var iconGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
            ForEach(iconCandidates, id: \.self) { icon in
                Button(action: { newIcon = icon }) {
                    Image(systemName: icon)
                        .frame(width: 44, height: 44)
                        .background(RoundedRectangle(cornerRadius: 12).stroke(newIcon == icon ? Color.blue : Color.gray.opacity(0.3), lineWidth: newIcon == icon ? 2 : 1))
                }
            }
        }
    }

    private var colorGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
            ForEach(colorsHex, id: \.self) { hex in
                Button(action: { newColor = hex }) {
                    Circle()
                        .fill(Color(hex: hex) ?? .blue)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Group { if newColor == hex { Image(systemName: "checkmark.circle.fill").foregroundColor(.white).shadow(radius: 2) } }
                        )
                }
            }
        }
    }
}


