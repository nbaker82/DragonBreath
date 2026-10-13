import SwiftUI
import SwiftData

@main
struct DragonBreathApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(
                for: Workout.self, Movement.self, WorkoutResult.self, LiftLog.self, LiftSet.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
            let context = container.mainContext
            Task { @MainActor in
                WorkoutSeeder.seedIfNeeded(context: context)
            }
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .environment(WorkoutRepository(context: container.mainContext))
                .environment(LiftRepository(context: container.mainContext))
        }
    }
}
