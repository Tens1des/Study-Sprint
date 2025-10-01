import SwiftUI

struct AvatarPicker: View {
    @Binding var selected: String
    private let icons: [String] = [
        "person.circle.fill","person.crop.circle.fill","person.fill","figure.walk.circle.fill","graduationcap.fill","book.circle.fill","bolt.circle.fill","globe.americas.fill","brain.head.profile"
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Choose avatar").font(.title2.bold())
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 3), spacing: 14) {
                    ForEach(icons, id: \.self) { icon in
                        Button(action: { selected = icon }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18).fill(Color(UIColor.secondarySystemBackground))
                                Image(systemName: icon).font(.largeTitle)
                            }
                            .frame(height: 90)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(selected == icon ? Color.accentColor : Color(UIColor.separator), lineWidth: selected == icon ? 2 : 1)
                            )
                        }
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}


