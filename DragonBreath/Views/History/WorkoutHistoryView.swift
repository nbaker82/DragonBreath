import SwiftUI

struct WorkoutHistoryView: View {
    let results: [WorkoutResult]

    var grouped: [(String, [WorkoutResult])] {
        let dict = Dictionary(grouping: results) { r in
            r.workout?.name ?? "Unknown"
        }
        return dict.sorted { $0.key < $1.key }
    }

    var body: some View {
        List {
            Section {
                HStack(spacing: 20) {
                    StatCard(title: "Total WODs", value: "\(results.count)")
                    StatCard(title: "Unique WODs", value: "\(grouped.count)")
                    StatCard(title: "Rx Rate", value: rxRate)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }

            ForEach(grouped, id: \.0) { name, workoutResults in
                Section(name) {
                    ForEach(workoutResults) { result in
                        HStack {
                            Text(result.displayScore)
                                .font(.subheadline)
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(result.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if !result.rx {
                                    Text("Scaled")
                                        .font(.caption2)
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var rxRate: String {
        guard !results.isEmpty else { return "—" }
        let rxCount = results.filter { $0.rx }.count
        let pct = Int((Double(rxCount) / Double(results.count)) * 100)
        return "\(pct)%"
    }
}
