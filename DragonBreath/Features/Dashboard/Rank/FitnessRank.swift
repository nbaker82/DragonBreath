import SwiftUI

// MARK: - Fitness Rank

enum FitnessRank: Int, CaseIterable {
    case houseCat   = 0
    case fox        = 1
    case wolf       = 2
    case cheetah    = 3
    case lion       = 4
    case grizzly    = 5
    case phoenix    = 6
    case griffin    = 7
    case dragon     = 8

    // Minimum total sessions required to reach this rank
    var threshold: Int {
        switch self {
        case .houseCat: return 0
        case .fox:      return 15
        case .wolf:     return 35
        case .cheetah:  return 75
        case .lion:     return 150
        case .grizzly:  return 275
        case .phoenix:  return 425
        case .griffin:  return 600
        case .dragon:   return 850
        }
    }

    var displayName: String {
        switch self {
        case .houseCat: return "House Cat"
        case .fox:      return "Fox"
        case .wolf:     return "Wolf"
        case .cheetah:  return "Cheetah"
        case .lion:     return "Lion"
        case .grizzly:  return "Grizzly Bear"
        case .phoenix:  return "Phoenix"
        case .griffin:  return "Griffin"
        case .dragon:   return "Dragon"
        }
    }

    var emoji: String {
        switch self {
        case .houseCat: return "🐱"
        case .fox:      return "🦊"
        case .wolf:     return "🐺"
        case .cheetah:  return "🐆"
        case .lion:     return "🦁"
        case .grizzly:  return "🐻"
        case .phoenix:  return "🦅"
        case .griffin:  return "🦁"   // composite — styled in view
        case .dragon:   return "🐉"
        }
    }

    var tagline: String {
        switch self {
        case .houseCat: return "Just getting started — every legend begins somewhere."
        case .fox:      return "Sharp and quick — you're building real momentum."
        case .wolf:     return "Running with the pack and holding your own."
        case .cheetah:  return "Speed and power — you don't miss days."
        case .lion:     return "You lead. Consistency is your signature."
        case .grizzly:  return "Raw strength and relentless endurance."
        case .phoenix:  return "You rise every time. Mythic-tier on the horizon."
        case .griffin:  return "Part lion, part eagle — elite in every domain."
        case .dragon:   return "The apex. Fire in your lungs, iron in your will."
        }
    }

    /// Light-mode shades are darkened so the rank name stays readable on the card;
    /// dark-mode shades are brighter. Defined in the asset catalog.
    var color: Color {
        switch self {
        case .houseCat: Color("ThemeRankHouseCat")
        case .fox:      Color("ThemeRankFox")
        case .wolf:     Color("ThemeRankWolf")
        case .cheetah:  Color("ThemeRankCheetah")
        case .lion:     Color("ThemeRankLion")
        case .grizzly:  Color("ThemeRankGrizzly")
        case .phoenix:  Color("ThemeRankPhoenix")
        case .griffin:  Color("ThemeRankGriffin")
        case .dragon:   Color("ThemeRankDragon")
        }
    }

    var isMythical: Bool {
        self == .phoenix || self == .griffin || self == .dragon
    }

    var next: FitnessRank? {
        FitnessRank(rawValue: rawValue + 1)
    }

    static func rank(for sessions: Int) -> FitnessRank {
        FitnessRank.allCases.reversed().first { sessions >= $0.threshold } ?? .houseCat
    }
}
