import Foundation
import WatchConnectivity
import GymCoachKit

/// Moves finished workouts from the watch to the iPhone, and the unit setting
/// from the iPhone to the watch. transferUserInfo queues the data, so a workout
/// still arrives if the iPhone is out of range when you finish.
final class Connectivity: NSObject, WCSessionDelegate {
    static let shared = Connectivity()

    /// Called on the main queue.
    var onSession: ((LoggedSession) -> Void)?
    /// Called on the main queue.
    var onUnit: ((WeightUnit) -> Void)?

    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func send(_ session: LoggedSession) {
        guard WCSession.isSupported(), let data = try? JSONEncoder().encode(session) else { return }
        WCSession.default.transferUserInfo(["session": data])
    }

    func sendUnit(_ unit: WeightUnit) {
        guard WCSession.isSupported(), WCSession.default.activationState == .activated else { return }
        try? WCSession.default.updateApplicationContext(["unit": unit.rawValue])
    }

    // MARK: WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {}

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        // Happens when switching to a different watch.
        WCSession.default.activate()
    }
    #endif

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        guard let data = userInfo["session"] as? Data,
              let logged = try? JSONDecoder().decode(LoggedSession.self, from: data) else { return }
        DispatchQueue.main.async { self.onSession?(logged) }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        guard let raw = applicationContext["unit"] as? String, let unit = WeightUnit(rawValue: raw) else { return }
        DispatchQueue.main.async { self.onUnit?(unit) }
    }
}
