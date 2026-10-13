import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Query(sort: \WorkoutResult.date, order: .reverse) private var allResults: [WorkoutResult]
    @Query(sort: \LiftLog.date, order: .reverse) private var allLiftLogs: [LiftLog]

    @State private var showLogWorkout = false
    @State private var showCustomBuilder = false

    private var monthResults: [WorkoutResult] {
        allResults.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }
    }

    private var monthLiftLogs: [LiftLog] {
        allLiftLogs.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }
    }

    private var categoryData: [CategoryStat] {
        var bodyweight = 0
        var cardio = 0
        var strength = 0
        for result in monthResults {
            guard let movements = result.workout?.movements, !movements.isEmpty else { continue }
            for movement in movements {
                switch movement.category {
                case .gymnastics:                    bodyweight += 1
                case .monostructural:                cardio += 1
                case .weightlifting, .strongman:     strength += 1
                }
            }
        }
        return [
            CategoryStat(label: "Bodyweight", count: bodyweight, color: .brand),
            CategoryStat(label: "Cardio",     count: cardio,     color: .blue),
            CategoryStat(label: "Strength",   count: strength,   color: .red)
        ]
    }

    private var dailyData: [DailyStat] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: monthResults) { cal.startOfDay(for: $0.date) }
        guard let monthInterval = cal.dateInterval(of: .month, for: Date()) else { return [] }
        var days: [DailyStat] = []
        var cursor = monthInterval.start
        let today = cal.startOfDay(for: Date())
        while cursor <= today {
            days.append(DailyStat(date: cursor, count: grouped[cursor]?.count ?? 0))
            cursor = cal.date(byAdding: .day, value: 1, to: cursor)!
        }
        return days
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    RankCardView(workoutCount: allResults.count, liftCount: allLiftLogs.count)
                        .padding(.horizontal)

                    HStack(spacing: 12) {
                        StatCard(title: "WODs This Month", value: "\(monthResults.count)")
                        StatCard(title: "Lift Sessions",   value: "\(monthLiftLogs.count)")
                        StatCard(title: "Rx Rate",         value: rxRate)
                    }
                    .padding(.horizontal)

                    MovementBreakdownChart(categoryData: categoryData)
                        .padding(.horizontal)

                    WorkoutsPerDayChart(dailyData: dailyData)
                        .padding(.horizontal)

                    Spacer(minLength: 20)
                }
                .padding(.top, 8)
            }
            .navigationTitle(monthTitle)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showLogWorkout = true
                        } label: {
                            Label("Log What I Did", systemImage: "pencil.and.list.clipboard")
                        }
                        Button {
                            showCustomBuilder = true
                        } label: {
                            Label("Generate Workout", systemImage: "hammer")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .tint(Color.brand)
                    }
                }
            }
            .sheet(isPresented: $showLogWorkout) {
                QuickLogWorkoutView()
            }
            .sheet(isPresented: $showCustomBuilder) {
                CustomWorkoutBuilderView()
            }
        }
    }

    private var rxRate: String {
        guard !monthResults.isEmpty else { return "—" }
        let rxCount = monthResults.filter { $0.rx }.count
        return "\(Int((Double(rxCount) / Double(monthResults.count)) * 100))%"
    }

    private var monthTitle: String {
        Date().formatted(.dateTime.month(.wide).year())
    }
}

// MARK: - Chart subviews

private struct MovementBreakdownChart: View {
    let categoryData: [CategoryStat]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Movement Breakdown")
                .font(.headline)
                .padding(.horizontal)

            if categoryData.allSatisfy({ $0.count == 0 }) {
                emptyPlaceholder("No workout data this month")
            } else {
                Chart(categoryData) { stat in
                    BarMark(
                        x: .value("Category", stat.label),
                        y: .value("Count", stat.count)
                    )
                    .foregroundStyle(stat.color)
                    .cornerRadius(6)
                }
                .chartYAxis { AxisMarks(position: .leading) }
                .frame(height: 180)
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(Color.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.brand.opacity(0.15), lineWidth: 1))
    }
}

private struct WorkoutsPerDayChart: View {
    let dailyData: [DailyStat]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Workouts This Month")
                .font(.headline)
                .padding(.horizontal)

            if dailyData.isEmpty || dailyData.allSatisfy({ $0.count == 0 }) {
                emptyPlaceholder("No workouts logged yet this month")
            } else {
                Chart(dailyData) { stat in
                    LineMark(
                        x: .value("Day", stat.date, unit: .day),
                        y: .value("Workouts", stat.count)
                    )
                    .foregroundStyle(LinearGradient.fire)
                    .interpolationMethod(.monotone)
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    AreaMark(
                        x: .value("Day", stat.date, unit: .day),
                        y: .value("Workouts", stat.count)
                    )
                    .foregroundStyle(LinearGradient.fireArea)
                    .interpolationMethod(.monotone)

                    PointMark(
                        x: .value("Day", stat.date, unit: .day),
                        y: .value("Workouts", stat.count)
                    )
                    .foregroundStyle(Color.brand)
                    .symbolSize(stat.count > 0 ? 40 : 0)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 7)) { value in
                        AxisValueLabel(format: .dateTime.day())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 4))
                }
                .frame(height: 180)
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(Color.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.brand.opacity(0.15), lineWidth: 1))
    }
}

private func emptyPlaceholder(_ message: String) -> some View {
    Text(message)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, minHeight: 80)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
}

// MARK: - Chart data models

struct CategoryStat: Identifiable {
    let id = UUID()
    let label: String
    let count: Int
    let color: Color
}

struct DailyStat: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}
