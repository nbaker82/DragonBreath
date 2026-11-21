import SwiftUI
import SwiftData

struct LogWorkoutResultView: View {
    @Environment(WorkoutRepository.self) private var workoutRepo
    @Environment(\.dismiss) private var dismiss

    let workout: Workout

    @State private var date: Date = .now
    @State private var score = ScoreEntry()
    @State private var notes: String = ""
    @State private var rx: Bool = true

    @FocusState private var focusedField: ScoreField?

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

                ScoreEntrySection(
                    workoutType: workout.workoutType,
                    timeCapMinutes: workout.timeCap.map { $0 / 60 },
                    entry: $score,
                    notes: $notes,
                    focus: $focusedField
                )

                Section("Notes") {
                    TextField("Optional notes...", text: $notes, axis: .vertical).focused($focusedField, equals: .notes)
                        .lineLimit(3...6)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Log Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(score.secondsAreInvalid(for: workout.workoutType))
                }
                // Number pads have no return key, so give them an explicit way out.
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done", action: dismissKeyboard)
                }
            }
        }
    }

    private func dismissKeyboard() {
        focusedField = nil
    }

    private func save() {
        let result = WorkoutResult(
            workout: workout,
            date: date,
            score: score.score(for: workout.workoutType),
            notes: notes,
            rx: rx
        )
        workoutRepo.saveResult(result)
        dismiss()
    }
}
