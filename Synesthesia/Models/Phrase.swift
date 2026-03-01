import Foundation

/// A sample phrase demonstrating the language.
struct Phrase: Codable, Identifiable, Equatable {
    let id: UUID
    /// Text in the constructed language
    var conlang: String
    /// English translation
    var english: String
    /// IPA pronunciation
    var pronunciation: String
    /// Word-by-word literal translation
    var literalTranslation: String

    init(
        id: UUID = UUID(),
        conlang: String,
        english: String,
        pronunciation: String,
        literalTranslation: String
    ) {
        self.id = id
        self.conlang = conlang
        self.english = english
        self.pronunciation = pronunciation
        self.literalTranslation = literalTranslation
    }
}

// MARK: - Phrase Book

/// A collection of culturally significant phrases, proverbs, and songs.
struct PhraseBook: Codable, Equatable {
    var proverbs: [CulturalPhrase]
    var songs: [Song]
    var sacredPhrases: [CulturalPhrase]
    /// Milestone phrases: birth, marriage, death, anniversary
    var milestones: [CulturalPhrase]
    var dailyExpressions: [CulturalPhrase]
    var customPhrases: [CulturalPhrase]

    static let empty = PhraseBook(
        proverbs: [], songs: [], sacredPhrases: [],
        milestones: [], dailyExpressions: [], customPhrases: []
    )
}

/// A phrase with cultural/emotional significance.
struct CulturalPhrase: Codable, Identifiable, Equatable {
    let id: UUID
    var category: PhraseCategory
    var conlangText: String
    var englishTranslation: String
    var literalTranslation: String
    /// IPA pronunciation
    var pronunciation: String
    /// 0-1 emotional weight for dynamic background responses
    var intensity: Double
    var isFrozen: Bool
    /// Context or usage notes
    var notes: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        category: PhraseCategory,
        conlangText: String,
        englishTranslation: String,
        literalTranslation: String,
        pronunciation: String,
        intensity: Double = 0.5,
        isFrozen: Bool = false,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.category = category
        self.conlangText = conlangText
        self.englishTranslation = englishTranslation
        self.literalTranslation = literalTranslation
        self.pronunciation = pronunciation
        self.intensity = intensity
        self.isFrozen = isFrozen
        self.notes = notes
        self.createdAt = createdAt
    }
}

enum PhraseCategory: String, Codable {
    case love, grief, joy, greeting, farewell
    case blessing, prayer, vow, curse
    case proverb, exclamation, comfort
    case birth, marriage, death, anniversary
    case custom
}

// MARK: - Songs

struct Song: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var titleTranslation: String
    var type: SongType
    var verses: [SongVerse]
    var audioURL: URL?
    var duration: TimeInterval?
    var isFrozen: Bool

    init(
        id: UUID = UUID(),
        title: String,
        titleTranslation: String,
        type: SongType,
        verses: [SongVerse] = [],
        audioURL: URL? = nil,
        duration: TimeInterval? = nil,
        isFrozen: Bool = false
    ) {
        self.id = id
        self.title = title
        self.titleTranslation = titleTranslation
        self.type = type
        self.verses = verses
        self.audioURL = audioURL
        self.duration = duration
        self.isFrozen = isFrozen
    }
}

enum SongType: String, Codable {
    case anthem, lullaby, loveSong
    case warChant, mourning, teaching
    case counting, custom
}

struct SongVerse: Codable, Equatable {
    var conlangLines: [String]
    var englishLines: [String]
    var pronunciation: [String]
    var isChorus: Bool
}

// MARK: - Code Phrases

/// A pre-agreed phrase with a secret meaning (privacy/stealth use case).
struct CodePhrase: Codable, Identifiable, Equatable {
    let id: UUID
    /// Phrase in the constructed language
    var conlangPhrase: String
    /// What the words literally translate to
    var literalTranslation: String
    /// What the speakers agreed it actually means
    var secretMeaning: String
    var pronunciation: String
    var category: CodePhraseCategory
    /// Code phrases are always frozen by default
    var isFrozen: Bool
    var createdBy: String?
    var agreedAt: Date

    init(
        id: UUID = UUID(),
        conlangPhrase: String,
        literalTranslation: String,
        secretMeaning: String,
        pronunciation: String,
        category: CodePhraseCategory,
        isFrozen: Bool = true,
        createdBy: String? = nil,
        agreedAt: Date = Date()
    ) {
        self.id = id
        self.conlangPhrase = conlangPhrase
        self.literalTranslation = literalTranslation
        self.secretMeaning = secretMeaning
        self.pronunciation = pronunciation
        self.category = category
        self.isFrozen = isFrozen
        self.createdBy = createdBy
        self.agreedAt = agreedAt
    }
}

enum CodePhraseCategory: String, Codable {
    case status
    case emergency
    case emotional
    case logistical
    case romantic
    case escape
    case custom
}

// MARK: - Cosmology

/// The metaphysical worldview embedded in the language's cultural layer.
struct Cosmology: Codable, Equatable {
    var divineModel: DivineModel
    var afterlifeModel: AfterlifeModel
    var evilModel: EvilModel
    /// Generated spiritual/cosmological vocabulary
    var sacredVocabulary: [LexiconEntry]
}

enum DivineModel: String, Codable {
    case monotheist
    case polytheist
    case pantheist
    case naturalist
}

enum AfterlifeModel: String, Codable {
    case rebirth
    case transcendence
    case ancestral
    case natural
    case unknown
}

enum EvilModel: String, Codable {
    case adversary
    case imbalance
    case humanChoice
    case absent
}
