import SwiftUI
import SwiftData

struct LiftLogRowView: View {
    let log: LiftLog

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(log.movement?.name ?? "Unknown")
                    .font(.headline)
                Spacer()
                Text(log.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                if let max = log.maxWeight {
                    Label("\(max.formatted()) \(log.unit.rawValue)", systemImage: "arrow.up.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.brand)
                }
                Text("\(log.sets.count) set\(log.sets.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
