import SwiftUI
import SwiftData
import GymCoachKit

@main
struct GymCoachWatchApp: App {
    private let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: SessionRecord.self)
        } catch {
            fatalError("Could not open the workout store: \(error)")
        }
        Connectivity.shared.onUnit = { unit in
            UserDefaults.standard.set(unit.rawValue, forKey: "unit")
        }
        Connectivity.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            TodayView()
        }
        .modelContainer(container)
    }
}
