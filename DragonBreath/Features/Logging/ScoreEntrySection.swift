import SwiftUI

/// The score fields for a workout type: MIN:SEC for timed workouts, rounds + reps
/// for AMRAP/EMOM/Death By, total reps for Tabata, load for strength, and free text
/// for everything else.
struct ScoreEntrySection: View {
    let workoutType: WorkoutType
    /// Time cap or duration in minutes, when the workout has one.
    let timeCapMinutes: Int?
    @Binding var entry: ScoreEntry
    @Binding var notes: String
    var focus: FocusState<ScoreField?>.Binding

    var body: some View {
        switch workoutType {
        case .forTime, .rft, .chipper:
            Section {
                HStack(spacing: 12) {
                    timeField("MIN", text: $entry.minutes, field: .minutes, label: "Minutes")
                    Text(":").font(.title2.bold()).foregroundStyle(.secondary)
                    timeField("SEC", text: $entry.seconds, field: .seconds, label: "Seconds")
                }
                .padding(.vertical, 4)
            } header: {
                Text("Finishing Time")
            } footer: {
                if entry.secondsAreInvalid(for: workoutType) {
                    Label("Seconds must be between 0 and 59.", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                } else if let timeCapMinutes {
                    Text("Time cap: \(timeCapMinutes) minutes")
                } else {
                    Text("Log the time it took you to finish.")
                }
            }

        case .amrap:
            Section {
                numberRow("Rounds", text: $entry.rounds, field: .rounds)
                numberRow("Extra Reps", text: $entry.reps, field: .reps)
            } header: {
                Text("Score")
            } footer: {
                if let timeCapMinutes {
                    Text("AMRAP in \(timeCapMinutes) min — log complete rounds plus any extra reps from your last partial round.")
                } else {
                    Text("Log complete rounds plus any extra reps.")
                }
            }

        case .emom:
            Section {
                numberRow("Rounds Completed", text: $entry.rounds, field: .rounds)
                numberRow("Extra Reps", text: $entry.reps, field: .reps)
            } header: {
                Text("Score")
            } footer: {
                if let timeCapMinutes {
                    Text("EMOM — \(timeCapMinutes) rounds total. Log how many intervals you completed.")
                } else {
                    Text("Log how many full intervals you completed.")
                }
            }

        case .tabata:
            Section {
                numberRow("Total Reps", text: $entry.totalReps, field: .totalReps)
            } header: {
                Text("Score")
            } footer: {
                Text("Tabata: 8 rounds × 20 sec on / 10 sec off. Log total reps across all rounds.")
            }

        case .deathBy:
            Section {
                numberRow("Rounds Reached", text: $entry.rounds, field: .rounds)
                numberRow("Reps in Final Round", text: $entry.reps, field: .reps)
            } header: {
                Text("Score")
            } footer: {
                Text("Log the last round you completed plus reps into your failed round.")
            }

        case .maxLoad, .strength, .complex:
            Section {
                numberRow("Weight (lbs)", text: $entry.weight, field: .weight, keyboard: .decimalPad)
            } header: {
                Text("Best Load")
            }

        default:
            Section("Score / Notes") {
                TextField("Describe your result…", text: $notes, axis: .vertical)
                    .lineLimit(2...4)
                    .focused(focus, equals: .notes)
            }
        }
    }

    private func timeField(_ caption: String, text: Binding<String>, field: ScoreField, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(caption)
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            TextField("00", text: text)
                .keyboardType(.numberPad)
                .font(.title2.monospacedDigit())
                .frame(maxWidth: .infinity)
                .focused(focus, equals: field)
                .accessibilityLabel(label)
        }
    }

    private func numberRow(
        _ title: String,
        text: Binding<String>,
        field: ScoreField,
        keyboard: UIKeyboardType = .numberPad
    ) -> some View {
        LabeledContent(title) {
            TextField("0", text: text)
                .keyboardType(keyboard)
                .modifier(NumberFieldStyle())
                .focused(focus, equals: field)
        }
    }
}
