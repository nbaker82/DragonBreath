import SwiftData
import Foundation

/// Fills an empty store with the built-in movement and workout library.
///
/// The library lives in `movements.json` and `workouts.json` (Resources/SeedData).
/// Workouts reference movements by name; enum values use the same raw values
/// SwiftData persists, e.g. "Weightlifting" or "For Time".
enum WorkoutSeeder {

    static func seedIfNeeded(context: ModelContext, bundle: Bundle = .main) {
        let count = (try? context.fetchCount(FetchDescriptor<Workout>())) ?? 0
        guard count == 0 else { return }

        do {
            let library = try SeedLibrary.load(from: bundle)
            var movementsByName: [String: Movement] = [:]

            for seed in library.movements {
                let movement = Movement(name: seed.name, category: seed.category, scoreTypes: seed.scoreTypes)
                context.insert(movement)
                movementsByName[seed.name] = movement
            }

            for seed in library.workouts {
                let workout = Workout(
                    name: seed.name,
                    workoutType: seed.type,
                    workoutDescription: seed.description,
                    timeCap: seed.timeCap,
                    isBenchmark: seed.isBenchmark ?? false,
                    isHero: seed.isHero ?? false,
                    isOpen: seed.isOpen ?? false
                )
                // Insert before linking: SwiftData can drop many-to-many links set earlier.
                context.insert(workout)
                workout.movements = seed.movements.compactMap { movementsByName[$0] }
            }

            try context.save()
        } catch {
            // Seed data ships with the app, so a failure here is a packaging bug.
            assertionFailure("Seeding the workout library failed: \(error)")
        }
    }
}
