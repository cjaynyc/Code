import Foundation

/// A visual inspiration input (image or video) that contributes to the language's mood profile.
struct InspirationSource: Codable, Identifiable, Equatable {
    let id: UUID
    /// Raw image data for uploaded photos
    var imageData: Data?
    /// URL for video inspiration sources
    var videoURL: URL?
    /// User-provided description of the source
    var description: String?
    /// 0-1 influence weight on the composite mood profile
    var weight: Double
    /// Mood profile extracted by AI analysis of this source
    var extractedMood: MoodProfile?

    init(
        id: UUID = UUID(),
        imageData: Data? = nil,
        videoURL: URL? = nil,
        description: String? = nil,
        weight: Double = 1.0,
        extractedMood: MoodProfile? = nil
    ) {
        self.id = id
        self.imageData = imageData
        self.videoURL = videoURL
        self.description = description
        self.weight = weight
        self.extractedMood = extractedMood
    }
}
