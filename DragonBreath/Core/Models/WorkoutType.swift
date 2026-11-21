import Foundation

enum WorkoutType: String, Codable, CaseIterable {
    case forTime    = "For Time"
    case amrap      = "AMRAP"
    case emom       = "EMOM"
    case tabata     = "Tabata"
    case maxLoad    = "Max Load"
    case rft        = "Rounds For Time"
    case strength   = "Strength"     // 5-5-5, 1RM, Wendler cycles
    case intervals  = "Intervals"    // Timed intervals with prescribed rest
    case chipper    = "Chipper"      // Long task-priority with varied movements
    case deathBy    = "Death By"     // Ascending rep scheme each minute
    case complex    = "Complex"      // Bear Complex, Macho Man, etc.
    case custom     = "Custom"
}
