import Foundation

/// A user participating in collaborative language creation.
struct Collaborator: Codable, Identifiable, Equatable {
    let id: UUID
    var userId: String
    var displayName: String
    var role: CollaboratorRole
    var joinedAt: Date

    init(
        id: UUID = UUID(),
        userId: String,
        displayName: String,
        role: CollaboratorRole = .contributor,
        joinedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.displayName = displayName
        self.role = role
        self.joinedAt = joinedAt
    }
}

enum CollaboratorRole: String, Codable {
    case creator
    case contributor
}
