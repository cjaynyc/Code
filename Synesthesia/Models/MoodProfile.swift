import Foundation

/// Mood analysis extracted from visual inputs.
/// Each dimension is scored from -1.0 to 1.0.
struct MoodProfile: Codable, Equatable {
    /// -1 (cold/clinical) to 1 (warm/inviting)
    var warmth: Double
    /// -1 (soft/gentle) to 1 (harsh/aggressive)
    var harshness: Double
    /// -1 (serene/still) to 1 (chaotic/dynamic)
    var energy: Double
    /// -1 (ancient/weathered) to 1 (futuristic/new)
    var age: Double
    /// -1 (mechanical/geometric) to 1 (organic/natural)
    var organic: Double
    /// -1 (minimal/sparse) to 1 (ornate/complex)
    var complexity: Double
    /// -1 (formal/distant) to 1 (intimate/personal)
    var intimacy: Double
    /// -1 (light/bright) to 1 (dark/shadowy)
    var darkness: Double

    static let neutral = MoodProfile(
        warmth: 0, harshness: 0, energy: 0, age: 0,
        organic: 0, complexity: 0, intimacy: 0, darkness: 0
    )

    /// Generate a random mood profile for testing without an API key.
    static func random() -> MoodProfile {
        MoodProfile(
            warmth: Double.random(in: -1...1),
            harshness: Double.random(in: -1...1),
            energy: Double.random(in: -1...1),
            age: Double.random(in: -1...1),
            organic: Double.random(in: -1...1),
            complexity: Double.random(in: -1...1),
            intimacy: Double.random(in: -1...1),
            darkness: Double.random(in: -1...1)
        )
    }
}

/// Lightweight mood vector used for real-time conversational analysis
/// and dynamic background rendering.
struct MoodVector: Codable, Equatable {
    /// Drives color temperature
    var warmth: Double
    /// Drives movement speed
    var energy: Double
    /// Drives color darkness
    var depth: Double
    /// Drives softness/blur
    var tenderness: Double

    static let neutral = MoodVector(warmth: 0, energy: 0, depth: 0, tenderness: 0)
}
