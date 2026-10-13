import Foundation
import SwiftData
import GymCoachKit

/// A finished workout saved on the device. The session is stored as JSON so the
/// watch and the iPhone always agree on its shape.
@Model
final class SessionRecord {
    @Attribute(.unique) var id: UUID
    var dayID: String
    var startedAt: Date
    var payload: Data

    init(session: LoggedSession) {
        id = session.id
        dayID = session.dayID
        startedAt = session.startedAt
        payload = (try? JSONEncoder().encode(session)) ?? Data()
    }

    var session: LoggedSession? {
        try? JSONDecoder().decode(LoggedSession.self, from: payload)
    }
}

enum SessionStore {
    /// Saves a session once. Receiving the same session twice does nothing.
    static func save(_ session: LoggedSession, in context: ModelContext) {
        let id = session.id
        let descriptor = FetchDescriptor<SessionRecord>(predicate: #Predicate { $0.id == id })
        if let count = try? context.fetchCount(descriptor), count > 0 { return }
        context.insert(SessionRecord(session: session))
        try? context.save()
    }

    /// The sets from the most recent session that included this exercise.
    static func lastSets(for exerciseID: String, in context: ModelContext) -> [LoggedSet] {
        var descriptor = FetchDescriptor<SessionRecord>(sortBy: [SortDescriptor(\.startedAt, order: .reverse)])
        descriptor.fetchLimit = 40
        let records = (try? context.fetch(descriptor)) ?? []
        for record in records {
            if let sets = record.session?.sets(for: exerciseID), !sets.isEmpty {
                return sets
            }
        }
        return []
    }
}
