import SwiftUI

// MARK: - Rank Card View

struct RankCardView: View {
    let workoutCount: Int
    let liftCount: Int

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private var isLarge: Bool { dynamicTypeSize.isAccessibilitySize }

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
            // Header row — badge beside the text normally, above it at accessibility sizes
            (isLarge
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
                : AnyLayout(HStackLayout(alignment: .center, spacing: 14))) {
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

                if !isLarge {
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            Divider().padding(.horizontal, 16)

            // Stats row
            (isLarge
                ? AnyLayout(VStackLayout(spacing: 8))
                : AnyLayout(HStackLayout(spacing: 0))) {
                RankStatCell(value: "\(totalSessions)", label: "Total Sessions")
                if !isLarge { Divider().frame(height: 36) }
                RankStatCell(value: "\(workoutCount)", label: "Workouts")
                if !isLarge { Divider().frame(height: 36) }
                RankStatCell(value: "\(liftCount)", label: "Lifts")
            }
            .padding(.vertical, 10)
            .padding(.horizontal, isLarge ? 16 : 0)

            // Progress bar
            if let nextRank = rank.next, let remaining = sessionsToNext {
                Divider().padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 8) {
                    (isLarge
                        ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
                        : AnyLayout(HStackLayout())) {
                        Text("Progress to \(nextRank.emoji) \(nextRank.displayName)")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                        if !isLarge { Spacer() }
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
