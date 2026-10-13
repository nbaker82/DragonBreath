import SwiftUI

struct ContentView: View {
    var body: some View {
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

            BTWBImportView()
                .tabItem {
                    Label("Import", systemImage: "square.and.arrow.down.fill")
                }

            // TEMP: remove after exporting the app icon
            AppIconExportView()
                .tabItem {
                    Label("Icon", systemImage: "app.fill")
                }
        }
        .tint(Color.brand)
    }
}
