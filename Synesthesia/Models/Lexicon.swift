import Foundation

/// A single dictionary entry in the language's vocabulary.
struct LexiconEntry: Codable, Identifiable, Equatable {
    let id: UUID
    /// Word in the constructed language
    var word: String
    /// IPA pronunciation
    var pronunciation: String
    /// Part of speech: "noun", "verb", "adjective", etc.
    var partOfSpeech: String
    /// English translation
    var englishTranslation: String
    /// Etymological root word
    var rootWord: String?
    /// Example sentence using this word
    var exampleSentence: String?
    /// User who proposed the word (collaborative mode)
    var proposedBy: String?
    /// Whether the word has been approved (collaborative mode)
    var approved: Bool

    // MARK: - Freeze System

    /// Whether the word is frozen (locked against language evolution)
    var isFrozen: Bool
    /// When the word was frozen
    var frozenAt: Date?
    /// User who initiated the freeze
    var frozenBy: String?
    /// Reason for freezing
    var frozenReason: FreezeReason?
    /// Partner who approved the freeze (shared languages)
    var freezeApprovedBy: String?

    // MARK: - Intensity

    /// 0-1 emotional weight for dynamic background responses
    var intensity: Double?

    init(
        id: UUID = UUID(),
        word: String,
        pronunciation: String,
        partOfSpeech: String,
        englishTranslation: String,
        rootWord: String? = nil,
        exampleSentence: String? = nil,
        proposedBy: String? = nil,
        approved: Bool = true,
        isFrozen: Bool = false,
        frozenAt: Date? = nil,
        frozenBy: String? = nil,
        frozenReason: FreezeReason? = nil,
        freezeApprovedBy: String? = nil,
        intensity: Double? = nil
    ) {
        self.id = id
        self.word = word
        self.pronunciation = pronunciation
        self.partOfSpeech = partOfSpeech
        self.englishTranslation = englishTranslation
        self.rootWord = rootWord
        self.exampleSentence = exampleSentence
        self.proposedBy = proposedBy
        self.approved = approved
        self.isFrozen = isFrozen
        self.frozenAt = frozenAt
        self.frozenBy = frozenBy
        self.frozenReason = frozenReason
        self.freezeApprovedBy = freezeApprovedBy
        self.intensity = intensity
    }
}

/// Reason a word was frozen (locked against evolution).
enum FreezeReason: String, Codable {
    case userChoice
    case mastered
    case nameReveal
    case curseWord
    case loanwordAdoption
    case sacred
    case partnerAgreement
}

// MARK: - Loanword System

/// A word that was flagged for the Loanword Challenge flow.
struct LoanwordEntry: Codable, Identifiable, Equatable {
    let id: UUID
    /// The source language word (e.g. "saudade")
    var originalWord: String
    /// Source language (e.g. "Portuguese")
    var originalLanguage: String
    /// Meaning/description
    var definition: String
    /// How the loanword was resolved
    var resolution: LoanwordResolution
    /// User's reason for keeping the word unchanged (Path C)
    var reason: String?
    /// User who proposed the loanword action (collaborative mode)
    var proposedBy: String?
    /// Partner who approved (collaborative mode)
    var approvedBy: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        originalWord: String,
        originalLanguage: String = "English",
        definition: String,
        resolution: LoanwordResolution,
        reason: String? = nil,
        proposedBy: String? = nil,
        approvedBy: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.originalWord = originalWord
        self.originalLanguage = originalLanguage
        self.definition = definition
        self.resolution = resolution
        self.reason = reason
        self.proposedBy = proposedBy
        self.approvedBy = approvedBy
        self.createdAt = createdAt
    }
}

/// How a loanword was resolved through the Loanword Challenge.
enum LoanwordResolution: String, Codable {
    /// Phonetically adapted to fit the conlang's sound system
    case adopted
    /// New compound word derived from existing roots
    case derived
    /// Kept in original form (untranslatable)
    case sacred
    /// Awaiting partner input (collaborative mode)
    case pending
}

// MARK: - Curse Words

/// A specially forged curse/expletive word.
struct CurseWord: Codable, Identifiable, Equatable {
    let id: UUID
    var word: String
    var pronunciation: String
    var intensity: CurseIntensity
    var category: CurseCategory
    /// Root breakdown / etymology
    var etymology: String
    /// Descriptive sensation (what it feels like to say)
    var feelsLike: String
    var usageExample: String
    var isFrozen: Bool
    var proposedBy: String?
    var approvedBy: String?

    init(
        id: UUID = UUID(),
        word: String,
        pronunciation: String,
        intensity: CurseIntensity,
        category: CurseCategory,
        etymology: String,
        feelsLike: String,
        usageExample: String,
        isFrozen: Bool = false,
        proposedBy: String? = nil,
        approvedBy: String? = nil
    ) {
        self.id = id
        self.word = word
        self.pronunciation = pronunciation
        self.intensity = intensity
        self.category = category
        self.etymology = etymology
        self.feelsLike = feelsLike
        self.usageExample = usageExample
        self.isFrozen = isFrozen
        self.proposedBy = proposedBy
        self.approvedBy = approvedBy
    }
}

enum CurseIntensity: String, Codable {
    case mild
    case moderate
    case strong
}

enum CurseCategory: String, Codable {
    case generalExpletive
    case insult
    case shock
    case frustration
}
