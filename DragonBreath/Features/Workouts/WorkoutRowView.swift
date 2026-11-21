import SwiftUI
import SwiftData

struct WorkoutRowView: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(workout.name)
                    .font(.headline)
                if workout.isBenchmark {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(Color.brand)
                }
                Spacer()
                Text(workout.workoutType.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(workout.workoutType.themeColor.opacity(0.18))
                    .foregroundStyle(.primary)
                    .clipShape(Capsule())
            }

            if !workout.movements.isEmpty {
                Text(workout.movements.map { $0.name }.joined(separator: " · "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            if !workout.results.isEmpty {
                Text("\(workout.results.count) result\(workout.results.count == 1 ? "" : "s")")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
