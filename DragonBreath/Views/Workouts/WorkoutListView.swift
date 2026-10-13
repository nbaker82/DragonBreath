import SwiftUI
import SwiftData

struct WorkoutListView: View {
    @Query(sort: \Workout.name) private var workouts: [Workout]
    @Query(sort: \Movement.name) private var movements: [Movement]

    @State private var vm = WorkoutListViewModel()
    @State private var showingAddWorkout = false
    @State private var showingFilters = false

    var body: some View {
        NavigationStack {
            Group {
                if workouts.isEmpty {
                    ContentUnavailableView("No Workouts", systemImage: "flame",
                        description: Text("Add your first workout or import from btwb."))
                } else {
                    List(vm.filtered(workouts)) { workout in
                        NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                            WorkoutRowView(workout: workout)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("DragonBreath 🐉")
            .searchable(text: $vm.searchText, prompt: "Search workouts or movements")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showingFilters.toggle() } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundStyle(hasActiveFilters ? Color.brand : .primary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingAddWorkout.toggle() } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                WorkoutFilterView(vm: vm, movements: movements)
            }
            .sheet(isPresented: $showingAddWorkout) {
                AddWorkoutView()
            }
        }
    }

    private var hasActiveFilters: Bool {
        vm.selectedType != nil || vm.selectedMovement != nil || vm.showBenchmarksOnly
    }
}

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
                    .foregroundStyle(workout.workoutType.themeColor)
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
