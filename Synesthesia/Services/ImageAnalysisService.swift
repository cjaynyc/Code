import Foundation

/// Analyzes images through Claude's vision API to extract mood profiles.
final class ImageAnalysisService {
    private let api: ClaudeAPIService

    init(api: ClaudeAPIService) {
        self.api = api
    }

    /// Analyze a single image and extract its mood profile.
    func analyzeMood(imageData: Data, mediaType: ImageMediaType = .jpeg) async throws -> MoodProfile {
        try await api.sendImageAndDecode(
            text: Self.moodAnalysisPrompt,
            imageData: imageData,
            mediaType: mediaType,
            as: MoodProfile.self,
            maxTokens: 1024
        )
    }

    /// Analyze multiple images and blend their mood profiles with weights.
    func analyzeAndBlend(sources: [InspirationSource]) async throws -> MoodProfile {
        guard !sources.isEmpty else { return .neutral }

        var weightedProfiles: [(MoodProfile, Double)] = []

        for source in sources {
            guard let imageData = source.imageData else { continue }
            let profile = try await analyzeMood(imageData: imageData)
            weightedProfiles.append((profile, source.weight))
        }

        guard !weightedProfiles.isEmpty else { return .neutral }
        return blend(weightedProfiles)
    }

    /// Blend multiple mood profiles using weighted averaging.
    private func blend(_ profiles: [(MoodProfile, Double)]) -> MoodProfile {
        let totalWeight = profiles.reduce(0.0) { $0 + $1.1 }
        guard totalWeight > 0 else { return .neutral }

        var result = MoodProfile.neutral
        for (profile, weight) in profiles {
            let w = weight / totalWeight
            result.warmth += profile.warmth * w
            result.harshness += profile.harshness * w
            result.energy += profile.energy * w
            result.age += profile.age * w
            result.organic += profile.organic * w
            result.complexity += profile.complexity * w
            result.intimacy += profile.intimacy * w
            result.darkness += profile.darkness * w
        }
        return result
    }

    // MARK: - Prompt

    private static let moodAnalysisPrompt = """
    Analyze this image and extract its emotional, aesthetic, and sensory qualities.
    Return ONLY a JSON object with these attributes scored from -1.0 to 1.0:

    {
      "warmth": float,
      "harshness": float,
      "energy": float,
      "age": float,
      "organic": float,
      "complexity": float,
      "intimacy": float,
      "darkness": float
    }

    Scoring guide:
    - warmth: -1 cold/clinical to 1 warm/inviting
    - harshness: -1 soft/gentle to 1 harsh/aggressive
    - energy: -1 serene/still to 1 chaotic/dynamic
    - age: -1 ancient/weathered to 1 futuristic/new
    - organic: -1 mechanical/geometric to 1 organic/natural
    - complexity: -1 minimal/sparse to 1 ornate/complex
    - intimacy: -1 formal/distant to 1 intimate/personal
    - darkness: -1 light/bright to 1 dark/shadowy

    Consider: color palette, textures, composition, subject matter, lighting, \
    emotional resonance, cultural associations, and spatial qualities.

    Return ONLY the JSON object, no other text.
    """
}
