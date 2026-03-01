import Foundation

// MARK: - Scenario Conversations

/// A pre-generated or AI-created conversation scenario for practice.
struct Scenario: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var speakers: [Speaker]
    var exchanges: [Exchange]
    var mood: ScenarioMood
    /// Words that were newly created for this scenario
    var newWordsIntroduced: [String]
    var isFavorite: Bool
    var createdAt: Date
    var lastPracticedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        speakers: [Speaker] = [],
        exchanges: [Exchange] = [],
        mood: ScenarioMood = .casual,
        newWordsIntroduced: [String] = [],
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        lastPracticedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.speakers = speakers
        self.exchanges = exchanges
        self.mood = mood
        self.newWordsIntroduced = newWordsIntroduced
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.lastPracticedAt = lastPracticedAt
    }
}

struct Speaker: Codable, Identifiable, Equatable {
    let id: UUID
    /// Display label: "You", "Partner", "Vendor", etc.
    var label: String

    init(id: UUID = UUID(), label: String) {
        self.id = id
        self.label = label
    }
}

/// A single line of dialog in a scenario conversation.
struct Exchange: Codable, Identifiable, Equatable {
    let id: UUID
    var speakerId: UUID
    var conlangText: String
    var englishTranslation: String
    /// IPA pronunciation
    var pronunciation: String
    /// Interlinear word-by-word gloss
    var wordByWord: [WordGloss]
    /// Locked against regeneration
    var isFrozen: Bool

    init(
        id: UUID = UUID(),
        speakerId: UUID,
        conlangText: String,
        englishTranslation: String,
        pronunciation: String,
        wordByWord: [WordGloss] = [],
        isFrozen: Bool = false
    ) {
        self.id = id
        self.speakerId = speakerId
        self.conlangText = conlangText
        self.englishTranslation = englishTranslation
        self.pronunciation = pronunciation
        self.wordByWord = wordByWord
        self.isFrozen = isFrozen
    }
}

struct WordGloss: Codable, Equatable {
    var conlangWord: String
    var englishMeaning: String
    var isFrozen: Bool
    /// Whether this word was newly created for this scenario
    var isNew: Bool
}

enum ScenarioMood: String, Codable {
    case casual, formal, playful, serious
    case romantic, urgent, negotiation
}

// MARK: - Quick Word Creation

/// A request to create a new word on-the-fly.
struct QuickWordRequest: Codable, Equatable {
    var englishConcept: String
    /// Where in the app the request was triggered
    var context: WordCreationContext?
    /// If created during a scenario
    var relatedScenario: String?
}

enum WordCreationContext: String, Codable {
    case pullDown
    case floatingButton
    case chatSuggestion
    case scenarioGeneration
    case codebreakers
    case dailyPrompt
    case keyboardExtension
}

// MARK: - Privacy & Stealth Settings

/// Privacy and stealth configuration for the app.
struct PrivacySettings: Codable, Equatable {
    /// Disguised app icon
    var stealthModeEnabled: Bool
    var notificationLanguage: NotificationLanguage
    /// Show English translations by default in chat
    var translationHintsDefault: Bool
    /// Require FaceID/TouchID to open app
    var biometricLockEnabled: Bool
    /// Auto-lock after inactivity
    var autoLockTimeout: TimeInterval
    /// Both partners must authenticate for export
    var exportRequiresDualAuth: Bool

    static let defaultSettings = PrivacySettings(
        stealthModeEnabled: false,
        notificationLanguage: .english,
        translationHintsDefault: true,
        biometricLockEnabled: false,
        autoLockTimeout: 300,
        exportRequiresDualAuth: false
    )
}

enum NotificationLanguage: String, Codable {
    /// Notifications show conlang text only
    case conlang
    /// Show English translation
    case english
    /// Just "New message" with no preview
    case minimal
}
