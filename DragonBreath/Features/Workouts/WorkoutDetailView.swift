import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    @Environment(WorkoutRepository.self) private var workoutRepo
    @Query(sort: \LiftLog.date, order: .reverse) private var allLogs: [LiftLog]

    let workout: Workout
    @State private var vm: WorkoutDetailViewModel

    init(workout: Workout) {
        self.workout = workout
        _vm = State(initialValue: WorkoutDetailViewModel(workout: workout))
    }

    var body: some View {
        List {
            Section("Workout") {
                Text(workout.workoutDescription)
                    .font(.body)
            }

            if let pb = vm.personalBest {
                Section("Personal Best") {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(Color.brand)
                        Text(pb.displayScore)
                            .font(.title2.bold())
                        Spacer()
                        Text(pb.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if !vm.sortedResults.isEmpty {
                Section("Your History") {
                    ForEach(vm.sortedResults) { result in
                        WorkoutResultRowView(result: result, vm: vm)
                    }
                    .onDelete { offsets in deleteResults(at: offsets) }
                }
            }
        }
        .navigationTitle(workout.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Log Result") { vm.showingLogSheet = true }
                    .foregroundStyle(Color.brand)
            }
        }
        .sheet(isPresented: $vm.showingLogSheet) {
            LogWorkoutResultView(workout: workout)
        }
    }

    private func deleteResults(at offsets: IndexSet) {
        let results = vm.sortedResults
        for index in offsets {
            workoutRepo.deleteResult(results[index])
        }
    }
}
