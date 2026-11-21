import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \WorkoutResult.date, order: .reverse) private var allResults: [WorkoutResult]
    @Query(sort: \LiftLog.date, order: .reverse) private var allLiftLogs: [LiftLog]

    @State private var showLogWorkout = false
    @State private var showCustomBuilder = false
    @State private var showImport = false
    @State private var showIconExport = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
            CategoryStat(label: "Bodyweight", count: bodyweight, color: .teal),
            CategoryStat(label: "Cardio",     count: cardio,     color: .blue),
            CategoryStat(label: "Strength",   count: strength,   color: .purple)
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

                    // Three across fits standard sizes; accessibility sizes stack them full width.
                    let statLayout = dynamicTypeSize.isAccessibilitySize
                        ? AnyLayout(VStackLayout(spacing: 12))
                        : AnyLayout(HStackLayout(alignment: .top, spacing: 12))
                    statLayout {
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
                ToolbarItem(placement: .topBarLeading) {
                    Menu("Options", systemImage: "ellipsis.circle") {
                        AppearancePicker()
                        Button("Import CSV", systemImage: "square.and.arrow.down", action: presentImport)
                        #if DEBUG
                        Button("Export App Icon", systemImage: "app", action: presentIconExport)
                        #endif
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Log What I Did", systemImage: "pencil.and.list.clipboard", action: presentLogWorkout)
                        Button("Generate Workout", systemImage: "hammer", action: presentCustomBuilder)
                    } label: {
                        Label("Add Workout", systemImage: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showImport) {
                ImportView()
            }
            .sheet(isPresented: $showIconExport) {
                AppIconExportView()
            }
            .sheet(isPresented: $showLogWorkout) {
                QuickLogWorkoutView()
            }
            .sheet(isPresented: $showCustomBuilder) {
                CustomWorkoutBuilderView()
            }
        }
    }

    private func presentImport() { showImport = true }
    private func presentIconExport() { showIconExport = true }
    private func presentLogWorkout() { showLogWorkout = true }
    private func presentCustomBuilder() { showCustomBuilder = true }

    private var rxRate: String {
        guard !monthResults.isEmpty else { return "—" }
        let rxCount = monthResults.filter { $0.rx }.count
        return "\(Int((Double(rxCount) / Double(monthResults.count)) * 100))%"
    }

    /// "November 2026", shortened to "Nov 2026" at accessibility sizes so the large title isn't truncated.
    private var monthTitle: String {
        let month: Date.FormatStyle.Symbol.Month = dynamicTypeSize.isAccessibilitySize ? .abbreviated : .wide
        return Date().formatted(.dateTime.month(month).year())
    }
}
