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
                        description: Text("Add your first workout or import a CSV."))
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
