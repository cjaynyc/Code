import Foundation

// MARK: - Rune System

/// Complete rune system for a language.
struct RuneSystem: Codable, Equatable {
    var languageId: UUID
    var runeSet: RuneSet
    var bindRunes: [BindRune]
    var castingHistory: [RuneCast]
    var inscriptionJournal: [Inscription]
    /// Map of rune ID to mastery level
    var masteryState: [UUID: RuneMasteryLevel]

    init(
        languageId: UUID,
        runeSet: RuneSet,
        bindRunes: [BindRune] = [],
        castingHistory: [RuneCast] = [],
        inscriptionJournal: [Inscription] = [],
        masteryState: [UUID: RuneMasteryLevel] = [:]
    ) {
        self.languageId = languageId
        self.runeSet = runeSet
        self.bindRunes = bindRunes
        self.castingHistory = castingHistory
        self.inscriptionJournal = inscriptionJournal
        self.masteryState = masteryState
    }
}

/// The set of 16-24 core runes for a language.
struct RuneSet: Codable, Equatable {
    var languageId: UUID
    var runes: [RuneGlyph]
    var readingDirection: ReadingDirection
    /// How words are divided in runic text
    var separatorStyle: SeparatorStyle
    /// Whether runes can combine vertically (bind runes)
    var stackable: Bool
}

/// A single rune glyph carrying sound, concept, and charge.
struct RuneGlyph: Codable, Identifiable, Equatable {
    let id: UUID
    /// Phonetic value: "th", "k", "r", etc.
    var sound: String
    /// Rune name: "Tharn", "Keld", "Reth"
    var name: String
    /// Core meaning: "Protection", "Endurance"
    var concept: String
    /// Category: "defense", "nature", "bond"
    var conceptDomain: String
    /// 0-1 charge level / intensity
    var intensity: Double
    /// Vector path data for rendering
    var paths: [GlyphPath]
    var strokeStyle: RuneStrokeStyle
    /// Map to closest real Unicode rune if applicable
    var unicodeMapping: String?

    init(
        id: UUID = UUID(),
        sound: String,
        name: String,
        concept: String,
        conceptDomain: String,
        intensity: Double = 0.5,
        paths: [GlyphPath] = [],
        strokeStyle: RuneStrokeStyle = .carved,
        unicodeMapping: String? = nil
    ) {
        self.id = id
        self.sound = sound
        self.name = name
        self.concept = concept
        self.conceptDomain = conceptDomain
        self.intensity = intensity
        self.paths = paths
        self.strokeStyle = strokeStyle
        self.unicodeMapping = unicodeMapping
    }
}

/// A bezier path segment for rune rendering.
struct GlyphPath: Codable, Equatable {
    var points: [CodablePoint]
    var controlPoints: [CodablePoint]?
    var strokeWidth: Double
    /// Whether this is the primary vertical/horizontal stroke (main stave)
    var isMainStave: Bool
}

enum RuneStrokeStyle: String, Codable {
    /// Angular, Elder Futhark feel
    case carved
    /// Calligraphic, flowing
    case brushed
    /// Precise, mechanical
    case etched
    /// Organic, branching
    case grown
    /// Simple, few strokes
    case minimal
}

enum ReadingDirection: String, Codable {
    case leftToRight
    case rightToLeft
    case topToBottom
    /// Alternating direction each line (ancient Greek style)
    case boustrophedon
}

enum SeparatorStyle: String, Codable {
    /// Middle dot between words (Old Norse style)
    case dot
    case space
    case colon
    /// Continuous, no word breaks
    case none
}

// MARK: - Bind Runes

/// A composite rune formed by merging 2-4 source runes.
struct BindRune: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    /// IDs of 2-4 source runes
    var componentRuneIds: [UUID]
    /// AI-generated interpretation of the combination
    var combinedMeaning: String
    /// Merged visual paths
    var combinedPaths: [GlyphPath]
    var purpose: BindRunePurpose
    var createdBy: String
    var isFrozen: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        componentRuneIds: [UUID],
        combinedMeaning: String,
        combinedPaths: [GlyphPath] = [],
        purpose: BindRunePurpose,
        createdBy: String,
        isFrozen: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.componentRuneIds = componentRuneIds
        self.combinedMeaning = combinedMeaning
        self.combinedPaths = combinedPaths
        self.purpose = purpose
        self.createdBy = createdBy
        self.isFrozen = isFrozen
        self.createdAt = createdAt
    }
}

enum BindRunePurpose: String, Codable {
    case personalSeal
    case couplesMark
    case tribeMark
    case blessing
    case protection
    case custom
}

// MARK: - Rune Casting

/// A single rune casting / divination session.
struct RuneCast: Codable, Identifiable, Equatable {
    let id: UUID
    var type: CastType
    /// Which runes were drawn
    var runesDrawn: [UUID]
    /// AI-generated interpretation of the cast
    var reading: String
    /// New vocabulary unlocked by this cast
    var wordsUnlocked: [String]
    var castAt: Date

    init(
        id: UUID = UUID(),
        type: CastType,
        runesDrawn: [UUID],
        reading: String,
        wordsUnlocked: [String] = [],
        castAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.runesDrawn = runesDrawn
        self.reading = reading
        self.wordsUnlocked = wordsUnlocked
        self.castAt = castAt
    }
}

enum CastType: String, Codable {
    /// Single rune draw
    case daily
    /// Past/present/future
    case threeRune
    /// 5-rune deep reading (advanced)
    case fullSpread
}

// MARK: - Inscriptions

/// A runic inscription created or practiced by the user.
struct Inscription: Codable, Identifiable, Equatable {
    let id: UUID
    /// The rune sequence
    var runicText: String
    /// Latin script transliteration
    var romanizedText: String
    /// English meaning
    var translation: String
    /// URL to user's hand-drawn version
    var handwrittenImageURL: URL?
    /// 0-1 stroke accuracy score
    var accuracy: Double?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        runicText: String,
        romanizedText: String,
        translation: String,
        handwrittenImageURL: URL? = nil,
        accuracy: Double? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.runicText = runicText
        self.romanizedText = romanizedText
        self.translation = translation
        self.handwrittenImageURL = handwrittenImageURL
        self.accuracy = accuracy
        self.createdAt = createdAt
    }
}

enum RuneMasteryLevel: Int, Codable {
    /// Not yet encountered
    case blank = 0
    /// First encounter
    case revealed = 1
    /// 3+ words learned using this rune
    case practiced = 2
    /// 8+ words + conversation use
    case mastered = 3
    /// All domain words mastered + bind rune created
    case transcended = 4
}

// MARK: - Rune Merge Records

/// Record of how runes were resolved when two languages merged.
struct RuneMergeRecord: Codable, Equatable {
    var languageARuneId: UUID
    var languageBRuneId: UUID
    /// The concept domain they both mapped to
    var sharedConcept: String
    var resolution: RuneMergeResolution
    var resultRuneId: UUID
}

enum RuneMergeResolution: String, Codable {
    case keepA
    case keepB
    /// Both survive as casual/formal variants
    case keepBothRegistered
    /// New glyph combining visual elements
    case blend
    /// Reduced form for pidgin use
    case simplify
}
