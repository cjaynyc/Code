import Foundation

// MARK: - Tribes & Growth

/// A group of speakers sharing a language.
struct Tribe: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var languageId: UUID
    var members: [TribeMember]
    var growthTier: GrowthTier
    var foundedAt: Date
    var governance: GovernanceModel
    var mergeHistory: [MergeEvent]
    var dialectVariations: [DialectVariation]?

    init(
        id: UUID = UUID(),
        name: String,
        languageId: UUID,
        members: [TribeMember] = [],
        growthTier: GrowthTier = .seedling,
        foundedAt: Date = Date(),
        governance: GovernanceModel = .duo,
        mergeHistory: [MergeEvent] = [],
        dialectVariations: [DialectVariation]? = nil
    ) {
        self.id = id
        self.name = name
        self.languageId = languageId
        self.members = members
        self.growthTier = growthTier
        self.foundedAt = foundedAt
        self.governance = governance
        self.mergeHistory = mergeHistory
        self.dialectVariations = dialectVariations
    }
}

struct TribeMember: Codable, Identifiable, Equatable {
    let id: UUID
    var userId: String
    var role: TribeRole
    var joinedAt: Date
    var masteryTier: GrowthTier
    var wordsContributed: Int
    /// Pronunciation/usage variations specific to this speaker
    var dialectMarkers: [String]?

    init(
        id: UUID = UUID(),
        userId: String,
        role: TribeRole = .speaker,
        joinedAt: Date = Date(),
        masteryTier: GrowthTier = .seedling,
        wordsContributed: Int = 0,
        dialectMarkers: [String]? = nil
    ) {
        self.id = id
        self.userId = userId
        self.role = role
        self.joinedAt = joinedAt
        self.masteryTier = masteryTier
        self.wordsContributed = wordsContributed
        self.dialectMarkers = dialectMarkers
    }
}

enum TribeRole: String, Codable {
    case creator
    case elder
    case speaker
    case learner
}

/// Vocabulary size tiers that unlock language growth features.
enum GrowthTier: Int, Codable {
    /// 0-50 words
    case seedling = 1
    /// 50-150 words
    case sapling = 2
    /// 150-300 words
    case youngTree = 3
    /// 300-500 words
    case grove = 4
    /// 500+ words
    case forest = 5
    /// 1000+ words, 1 year+
    case ancientForest = 6
}

enum GovernanceModel: String, Codable {
    /// 2 speakers, mutual agreement
    case duo
    /// 3-5 speakers, majority vote
    case smallCouncil
    /// 6+ speakers, proposal + voting period
    case democracy
}

// MARK: - Language Merging

/// Record of a language merge event.
struct MergeEvent: Codable, Identifiable, Equatable {
    let id: UUID
    var mergeType: MergeType
    /// IDs of parent languages
    var parentLanguages: [UUID]
    var resultLanguageId: UUID
    var mergedAt: Date
    var vocabularyResolutions: [VocabularyResolution]
    /// Frozen words that carried over unchanged
    var frozenSurvivors: [String]

    init(
        id: UUID = UUID(),
        mergeType: MergeType,
        parentLanguages: [UUID],
        resultLanguageId: UUID,
        mergedAt: Date = Date(),
        vocabularyResolutions: [VocabularyResolution] = [],
        frozenSurvivors: [String] = []
    ) {
        self.id = id
        self.mergeType = mergeType
        self.parentLanguages = parentLanguages
        self.resultLanguageId = resultLanguageId
        self.mergedAt = mergedAt
        self.vocabularyResolutions = vocabularyResolutions
        self.frozenSurvivors = frozenSurvivors
    }
}

enum MergeType: String, Codable {
    /// Creolization: both parent languages die, new one is born
    case fullMerge
    /// Shared trade language, both parents survive
    case pidginBridge
    /// Loanword borrowing only, both parents survive
    case vocabularyExchange
}

/// How a single concept was resolved during a language merge.
struct VocabularyResolution: Codable, Equatable {
    /// The concept being resolved (e.g. "water", "love")
    var concept: String
    /// Word from Language A
    var languageAWord: String
    /// Word from Language B
    var languageBWord: String
    var resolution: MergeResolution
    /// Final word in the merged language
    var resultWord: String
    /// Map of userId to chosen option
    var votes: [String: String]
}

enum MergeResolution: String, Codable {
    case keepA
    case keepB
    /// Both survive with nuanced meaning split
    case keepBoth
    /// Hybrid phonetic blend
    case blend
    /// New word from merged roots
    case derive
}

/// A speaker-specific variation from the standard form.
struct DialectVariation: Codable, Equatable {
    var speakerId: String
    /// What varies (e.g. "pronunciation of /r/")
    var feature: String
    /// The canonical/standard form
    var standardForm: String
    /// This speaker's variant
    var dialectForm: String
    /// How often they use the variant
    var frequency: Int
}

// MARK: - Language Lineage

/// Tracks ancestry and descent for language family trees.
struct LanguageLineage: Codable, Equatable {
    var languageId: UUID
    /// Nil if this is an original creation
    var parentLanguages: [UUID]?
    /// Languages descended from this one
    var childLanguages: [UUID]?
    /// Merge events this language was part of
    var mergeEvents: [UUID]?
    var status: LanguageStatus
}

enum LanguageStatus: String, Codable {
    /// Actively used
    case living
    /// No activity 30-89 days
    case dormant
    /// In the Book of Dead Languages, abandoned
    case dead
    /// In the Book, merged into children
    case ancestor
    /// Brought back from the Book
    case resurrected
}
