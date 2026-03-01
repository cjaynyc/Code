import Foundation

// MARK: - Dynamic Background System

/// User preferences for the dynamic conversational background.
struct BackgroundPreferences: Codable, Equatable {
    var mode: BackgroundMode
    /// 0-1 how reactive the background is to mood shifts
    var sensitivity: Double
    var particlesEnabled: Bool
    var textureEnabled: Bool
    /// Syncs with iOS accessibility setting
    var reducedMotion: Bool

    static let defaultPreferences = BackgroundPreferences(
        mode: .ambient,
        sensitivity: 0.7,
        particlesEnabled: true,
        textureEnabled: true,
        reducedMotion: false
    )
}

enum BackgroundMode: String, Codable {
    /// Fully dynamic, responds to conversation
    case ambient
    /// Locked serene palette
    case calm
    /// Minimal, near-static for studying
    case focus
    /// Festive, energetic
    case celebration
    /// Dark and quiet
    case night
}

/// Events that trigger special visual effects in the dynamic background.
enum BackgroundEvent: Codable, Equatable {
    case newWordUsed(word: String)
    case sacredWordAppeared(word: String)
    case vocabularyMilestone(count: Int)
    case longPause(duration: TimeInterval)
    case emotionShift(fromWarmth: Double, toWarmth: Double)
    case topicChange(newTopic: String)
}
