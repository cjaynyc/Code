import Foundation

/// Core language specification — the root model that aggregates all components
/// of a constructed language.
struct Language: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String

    // MARK: - Core Linguistic Components

    var moodProfile: MoodProfile
    var phonology: Phonology
    var grammar: Grammar
    var lexicon: [LexiconEntry]
    var samplePhrases: [Phrase]
    var inspirationSources: [InspirationSource]
    var tuningParameters: TuningParameters

    // MARK: - Visual Identity

    var identity: LanguageIdentity?

    // MARK: - Social & Collaboration

    var collaborators: [Collaborator]?

    // MARK: - Loanword System

    /// Words kept in their original form (Untranslatable Archive)
    var untranslatableArchive: [LoanwordEntry]
    /// Words phonetically adapted into the conlang
    var loanwords: [LoanwordEntry]

    // MARK: - Cultural Layer

    var phraseBook: PhraseBook?
    var cosmology: Cosmology?
    var curseWords: [CurseWord]

    // MARK: - Learning & Mastery

    var masteryTracker: VocabularyMasteryTracker?
    var fluencyTracker: FluencyTracker?

    // MARK: - Rune System

    var runeSystem: RuneSystem?

    // MARK: - Chat & Background

    var backgroundPreferences: BackgroundPreferences
    /// Map of conlang word to its emotional weight vector
    var vocabularyEmotionMap: [String: MoodVector]

    // MARK: - Privacy

    var privacySettings: PrivacySettings

    // MARK: - Scenarios & Code Phrases

    var scenarios: [Scenario]
    var codePhrases: [CodePhrase]

    // MARK: - Growth & Lineage

    var lineage: LanguageLineage?

    // MARK: - Timestamps

    var createdAt: Date
    var updatedAt: Date

    // MARK: - AI Description

    /// A 2-3 sentence poetic description of how this language sounds and feels
    var languageDescription: String?

    init(
        id: UUID = UUID(),
        name: String,
        moodProfile: MoodProfile = .neutral,
        phonology: Phonology = Phonology(consonants: [], vowels: [], phonotacticRules: [], stressPattern: ""),
        grammar: Grammar = Grammar(
            wordOrder: "SVO", morphologicalType: "isolating", nounCases: nil,
            verbConjugation: "", pluralFormation: "", possessiveSystem: "",
            tenseSystem: [], negation: "", questionFormation: "", rules: []
        ),
        lexicon: [LexiconEntry] = [],
        samplePhrases: [Phrase] = [],
        inspirationSources: [InspirationSource] = [],
        tuningParameters: TuningParameters = .defaultValues,
        identity: LanguageIdentity? = nil,
        collaborators: [Collaborator]? = nil,
        untranslatableArchive: [LoanwordEntry] = [],
        loanwords: [LoanwordEntry] = [],
        phraseBook: PhraseBook? = nil,
        cosmology: Cosmology? = nil,
        curseWords: [CurseWord] = [],
        masteryTracker: VocabularyMasteryTracker? = nil,
        fluencyTracker: FluencyTracker? = nil,
        runeSystem: RuneSystem? = nil,
        backgroundPreferences: BackgroundPreferences = .defaultPreferences,
        vocabularyEmotionMap: [String: MoodVector] = [:],
        privacySettings: PrivacySettings = .defaultSettings,
        scenarios: [Scenario] = [],
        codePhrases: [CodePhrase] = [],
        lineage: LanguageLineage? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        languageDescription: String? = nil
    ) {
        self.id = id
        self.name = name
        self.moodProfile = moodProfile
        self.phonology = phonology
        self.grammar = grammar
        self.lexicon = lexicon
        self.samplePhrases = samplePhrases
        self.inspirationSources = inspirationSources
        self.tuningParameters = tuningParameters
        self.identity = identity
        self.collaborators = collaborators
        self.untranslatableArchive = untranslatableArchive
        self.loanwords = loanwords
        self.phraseBook = phraseBook
        self.cosmology = cosmology
        self.curseWords = curseWords
        self.masteryTracker = masteryTracker
        self.fluencyTracker = fluencyTracker
        self.runeSystem = runeSystem
        self.backgroundPreferences = backgroundPreferences
        self.vocabularyEmotionMap = vocabularyEmotionMap
        self.privacySettings = privacySettings
        self.scenarios = scenarios
        self.codePhrases = codePhrases
        self.lineage = lineage
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.languageDescription = languageDescription
    }
}

// MARK: - Language Component (for partial regeneration)

/// Identifies which component of a language to regenerate after a tuning change.
enum LanguageComponent: String, Codable {
    case phonology
    case grammar
    case lexicon
    case phrases
    case identity
    case runes
    case all
}
