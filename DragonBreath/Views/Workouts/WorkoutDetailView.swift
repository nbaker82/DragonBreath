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

struct WorkoutResultRowView: View {
    let result: WorkoutResult
    let vm: WorkoutDetailViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(result.displayScore)
                    .font(.headline)
                if !result.notes.isEmpty {
                    Text(result.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(result.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    if !result.rx {
                        Text("Scaled")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.blue.opacity(0.15))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }
                    Text(vm.percentileLabel(for: result))
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(percentileBg(result))
                        .foregroundStyle(percentileFg(result))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 2)
    }

    private func percentileBg(_ result: WorkoutResult) -> Color {
        let p = vm.percentile(for: result)
        if p >= 1.0 { return .yellow.opacity(0.2) }
        if p >= 0.9 { return .green.opacity(0.15) }
        if p >= 0.75 { return .blue.opacity(0.15) }
        return .gray.opacity(0.1)
    }

    private func percentileFg(_ result: WorkoutResult) -> Color {
        let p = vm.percentile(for: result)
        if p >= 1.0 { return .brandGold }
        if p >= 0.9 { return .green }
        if p >= 0.75 { return .blue }
        return .secondary
    }
}
