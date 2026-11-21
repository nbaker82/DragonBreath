import SwiftUI

struct ContentView: View {
    var body: some View {
        // Four tabs keeps everything on the iPhone tab bar (five or more spills into "More").
        // One-off actions such as CSV import live in the Dashboard's options menu.
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }

            WorkoutListView()
                .tabItem {
                    Label("Workouts", systemImage: "flame.fill")
                }

            LiftLogListView()
                .tabItem {
                    Label("Lifts", systemImage: "dumbbell.fill")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "chart.line.uptrend.xyaxis")
                }
        }
        .tint(Color.brand)
    }
}
