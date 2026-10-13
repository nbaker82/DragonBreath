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

    var color: Color {
        switch self {
        case .houseCat: return .gray
        case .fox:      return Color(red: 0.85, green: 0.45, blue: 0.1)
        case .wolf:     return Color(red: 0.45, green: 0.5, blue: 0.6)
        case .cheetah:  return Color(red: 0.8, green: 0.65, blue: 0.1)
        case .lion:     return Color(red: 0.85, green: 0.55, blue: 0.05)
        case .grizzly:  return Color(red: 0.55, green: 0.35, blue: 0.15)
        case .phoenix:  return Color(red: 0.9, green: 0.3, blue: 0.1)
        case .griffin:  return Color(red: 0.5, green: 0.2, blue: 0.8)
        case .dragon:   return Color(red: 0.9, green: 0.15, blue: 0.15)
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

// MARK: - Rank Card View

struct RankCardView: View {
    let workoutCount: Int
    let liftCount: Int

    private var totalSessions: Int { workoutCount + liftCount }
    private var rank: FitnessRank { FitnessRank.rank(for: totalSessions) }

    private var progressToNext: Double {
        guard let next = rank.next else { return 1.0 }
        let range = next.threshold - rank.threshold
        let done  = totalSessions - rank.threshold
        return min(Double(done) / Double(range), 1.0)
    }

    private var sessionsToNext: Int? {
        guard let next = rank.next else { return nil }
        return max(next.threshold - totalSessions, 0)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header row
            HStack(alignment: .center, spacing: 14) {
                // Animal badge
                ZStack {
                    Circle()
                        .fill(rank.color.opacity(0.15))
                        .frame(width: 64, height: 64)

                    if rank == .griffin {
                        // Griffin: layered emoji since there's no griffin emoji
                        ZStack {
                            Text("🦁").font(.system(size: 28)).offset(x: -4, y: 4)
                            Text("🦅").font(.system(size: 22)).offset(x: 8, y: -8)
                        }
                    } else {
                        Text(rank.emoji)
                            .font(.system(size: 34))
                    }

                    if rank == .dragon {
                        Circle()
                            .strokeBorder(LinearGradient.gold, lineWidth: 2.5)
                            .frame(width: 64, height: 64)
                    } else if rank.isMythical {
                        Circle()
                            .strokeBorder(rank.color.opacity(0.6), lineWidth: 2)
                            .frame(width: 64, height: 64)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        if rank == .dragon {
                            Text("MYTHICAL")
                                .font(.caption2.bold())
                                .foregroundStyle(LinearGradient.gold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.brandGold.opacity(0.15))
                                .clipShape(Capsule())
                        } else if rank.isMythical {
                            Text("MYTHICAL")
                                .font(.caption2.bold())
                                .foregroundStyle(rank.color)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(rank.color.opacity(0.12))
                                .clipShape(Capsule())
                        }
                        Text(rank.displayName.uppercased())
                            .font(.headline.bold())
                            .foregroundStyle(rank == .dragon ? AnyShapeStyle(LinearGradient.gold) : AnyShapeStyle(rank.color))
                    }
                    Text(rank.tagline)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            Divider().padding(.horizontal, 16)

            // Stats row
            HStack(spacing: 0) {
                RankStatCell(value: "\(totalSessions)", label: "Total Sessions")
                Divider().frame(height: 36)
                RankStatCell(value: "\(workoutCount)", label: "Workouts")
                Divider().frame(height: 36)
                RankStatCell(value: "\(liftCount)", label: "Lifts")
            }
            .padding(.vertical, 10)

            // Progress bar
            if let nextRank = rank.next, let remaining = sessionsToNext {
                Divider().padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Progress to \(nextRank.emoji) \(nextRank.displayName)")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(remaining) sessions to go")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.cardSurface2)
                                .frame(height: 8)
                            Capsule()
                                .fill(rank == .dragon ? LinearGradient.gold : LinearGradient(
                                    colors: [rank.color.opacity(0.8), rank.color],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(width: geo.size.width * progressToNext, height: 8)
                                .animation(.easeOut(duration: 0.6), value: progressToNext)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 14)
            } else {
                // Max rank — Dragon
                VStack(spacing: 4) {
                    Text("🐉 Maximum Rank Achieved")
                        .font(.caption.bold())
                        .foregroundStyle(LinearGradient.gold)
                    Text("You are the Dragon. There is nothing higher.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 12)
            }
        }
        .background(Color.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    rank == .dragon
                        ? AnyShapeStyle(LinearGradient.gold)
                        : AnyShapeStyle(rank.color.opacity(rank.isMythical ? 0.5 : 0.25)),
                    lineWidth: rank.isMythical ? 1.5 : 1
                )
        )
        .shadow(
            color: rank == .dragon
                ? Color.brandGold.opacity(0.35)
                : rank.color.opacity(rank.isMythical ? 0.25 : 0.1),
            radius: rank == .dragon ? 20 : rank.isMythical ? 12 : 4,
            y: 3
        )
    }
}

// MARK: - Rank Stat Cell

private struct RankStatCell: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3.bold())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
