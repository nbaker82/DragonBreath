import SwiftUI

struct WorkoutTypeBanner: View {
    let workout: Workout

    private var color: Color { workout.workoutType.themeColor }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: typeIcon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(workout.workoutType.rawValue.uppercased())
                    .font(.caption.bold())
                    .foregroundStyle(color)
                Text(typeDescription)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                if let cap = workout.timeCap {
                    Text("Time cap: \(cap / 60) min")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(12)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(color.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.vertical, 4)
    }

    var typeIcon: String {
        switch workout.workoutType {
        case .amrap:                            return "arrow.clockwise"
        case .emom:                             return "timer"
        case .forTime, .rft, .chipper:          return "stopwatch"
        case .tabata:                           return "waveform.path"
        case .deathBy:                          return "chart.line.uptrend.xyaxis"
        case .maxLoad, .strength, .complex:     return "scalemass"
        case .intervals:                        return "repeat.circle"
        default:                                return "flame"
        }
    }

    var typeDescription: String {
        switch workout.workoutType {
        case .amrap:     return "As Many Rounds As Possible"
        case .emom:      return "Every Minute On the Minute"
        case .forTime:   return "Finish as fast as possible"
        case .rft:       return "Rounds For Time"
        case .chipper:   return "Work through all reps for time"
        case .tabata:    return "20 sec on / 10 sec off × 8 rounds"
        case .deathBy:   return "Ascending reps — survive as long as you can"
        case .maxLoad:   return "Find your heaviest single"
        case .strength:  return "Strength protocol"
        case .complex:   return "Barbell complex — unbroken sets"
        case .intervals: return "Work / rest intervals"
        default:         return workout.workoutType.rawValue
        }
    }
}
