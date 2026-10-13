import SwiftUI

struct MovementPickerSheet: View {
    let allMovements: [Movement]
    @Binding var selected: [Movement]
    @Environment(\.dismiss) private var dismiss

    @State private var search = ""

    private var filtered: [Movement] {
        search.isEmpty ? allMovements : allMovements.filter {
            $0.name.localizedCaseInsensitiveContains(search)
        }
    }

    private var grouped: [(String, [Movement])] {
        let dict = Dictionary(grouping: filtered) { $0.category.rawValue }
        return dict.sorted { $0.key < $1.key }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(grouped, id: \.0) { category, movements in
                    Section(category) {
                        ForEach(movements) { movement in
                            HStack {
                                Text(movement.name)
                                Spacer()
                                if selected.contains(where: { $0.id == movement.id }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.brand)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { toggle(movement) }
                        }
                    }
                }
            }
            .searchable(text: $search, prompt: "Search movements")
            .navigationTitle("Add Movements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func toggle(_ movement: Movement) {
        if let idx = selected.firstIndex(where: { $0.id == movement.id }) {
            selected.remove(at: idx)
        } else {
            selected.append(movement)
        }
    }
}
