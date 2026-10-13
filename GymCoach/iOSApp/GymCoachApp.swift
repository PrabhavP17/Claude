import SwiftUI
import SwiftData
import GymCoachKit

@main
struct GymCoachApp: App {
    private let container: ModelContainer

    init() {
        let container: ModelContainer
        do {
            container = try ModelContainer(for: SessionRecord.self)
        } catch {
            fatalError("Could not open the workout store: \(error)")
        }
        self.container = container

        Connectivity.shared.onSession = { session in
            Task { @MainActor in
                SessionStore.save(session, in: container.mainContext)
            }
        }
        Connectivity.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                PlanView()
                    .tabItem { Label("Plan", systemImage: "figure.cricket") }
                HistoryView()
                    .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
                ProgressChartView()
                    .tabItem { Label("Progress", systemImage: "chart.line.uptrend.xyaxis") }
                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape") }
            }
        }
        .modelContainer(container)
    }
}
