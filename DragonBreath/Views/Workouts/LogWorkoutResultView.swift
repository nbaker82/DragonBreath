import SwiftUI

struct LogWorkoutResultView: View {
    @Environment(WorkoutRepository.self) private var workoutRepo
    @Environment(\.dismiss) private var dismiss

    let workout: Workout

    @State private var date: Date = Date()
    @State private var minutes: String = ""
    @State private var seconds: String = ""
    @State private var rounds: String = ""
    @State private var reps: String = ""
    @State private var weight: String = ""
    @State private var totalReps: String = ""
    @State private var notes: String = ""
    @State private var rx: Bool = true

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    WorkoutTypeBanner(workout: workout)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                }

                Section("Date & Rx") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    Toggle("Rx", isOn: $rx)
                }

                scoreSection

                Section("Notes") {
                    TextField("Optional notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Log Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    @ViewBuilder
    private var scoreSection: some View {
        switch workout.workoutType {
        case .forTime, .rft, .chipper:
            Section {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MIN").font(.caption2).foregroundStyle(.secondary)
                        TextField("00", text: $minutes)
                            .keyboardType(.numberPad)
                            .font(.title2.monospacedDigit())
                            .frame(maxWidth: .infinity)
                    }
                    Text(":").font(.title2.bold()).foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SEC").font(.caption2).foregroundStyle(.secondary)
                        TextField("00", text: $seconds)
                            .keyboardType(.numberPad)
                            .font(.title2.monospacedDigit())
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 4)
            } header: { Text("Finishing Time") } footer: {
                if let cap = workout.timeCap { Text("Time cap: \(cap / 60) minutes") }
            }

        case .amrap:
            Section {
                LabeledContent("Rounds") {
                    TextField("0", text: $rounds).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                }
                LabeledContent("Extra Reps") {
                    TextField("0", text: $reps).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                }
            } header: { Text("Score") } footer: {
                if let cap = workout.timeCap {
                    Text("AMRAP in \(cap / 60) minutes — log complete rounds + any extra reps in your last partial round.")
                }
            }

        case .emom:
            Section {
                LabeledContent("Rounds Completed") {
                    TextField("0", text: $rounds).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                }
                LabeledContent("Extra Reps") {
                    TextField("0", text: $reps).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                }
            } header: { Text("Score") } footer: {
                if let cap = workout.timeCap { Text("EMOM — \(cap / 60) rounds total. Log how many intervals you completed.") }
                else { Text("Log how many full intervals you completed.") }
            }

        case .tabata:
            Section {
                LabeledContent("Total Reps") {
                    TextField("0", text: $totalReps).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                }
            } header: { Text("Score") } footer: {
                Text("Tabata: 8 rounds of 20 sec on / 10 sec off. Log total reps across all rounds.")
            }

        case .deathBy:
            Section {
                LabeledContent("Rounds Reached") {
                    TextField("0", text: $rounds).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                }
                LabeledContent("Reps in Final Round") {
                    TextField("0", text: $reps).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                }
            } header: { Text("Score") } footer: {
                Text("Death By: log the last round you completed + reps into your failed round.")
            }

        case .maxLoad, .strength, .complex:
            Section {
                LabeledContent("Weight (lbs)") {
                    TextField("0", text: $weight).keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                }
            } header: { Text("Best Load") }

        default:
            Section("Score") {
                TextField("Score / notes", text: $notes)
            }
        }
    }

    private func save() {
        var timeSecondsVal: Int? = nil
        var roundsInt: Int? = nil
        var repsInt: Int? = nil
        var weightDouble: Double? = nil
        var totalRepsInt: Int? = nil
        var scoreType: ScoreType = .time

        switch workout.workoutType {
        case .forTime, .rft, .chipper:
            let m = Int(minutes) ?? 0
            let s = Int(seconds) ?? 0
            timeSecondsVal = m * 60 + s
            scoreType = .time
        case .amrap, .emom:
            roundsInt = Int(rounds)
            repsInt = Int(reps)
            scoreType = .rounds
        case .tabata:
            totalRepsInt = Int(totalReps)
            scoreType = .reps
        case .deathBy:
            roundsInt = Int(rounds)
            repsInt = Int(reps)
            scoreType = .rounds
        case .maxLoad, .strength, .complex:
            weightDouble = Double(weight)
            scoreType = .weight
        default:
            scoreType = .reps
        }

        let result = WorkoutResult(
            workout: workout,
            date: date,
            scoreType: scoreType,
            timeSeconds: timeSecondsVal,
            rounds: roundsInt,
            repsRemainder: repsInt,
            weight: weightDouble,
            totalReps: totalRepsInt,
            notes: notes,
            rx: rx
        )
        workoutRepo.saveResult(result)
        dismiss()
    }
}
