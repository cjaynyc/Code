import Foundation

/// Generates constructed languages from mood profiles and tuning parameters using Claude.
final class LanguageGenerationService {
    private let api: ClaudeAPIService

    init(api: ClaudeAPIService) {
        self.api = api
    }

    // MARK: - Full Language Generation

    /// Generate a complete language specification from a mood profile and tuning parameters.
    func generateLanguage(
        mood: MoodProfile,
        tuning: TuningParameters,
        userName: String? = nil
    ) async throws -> GeneratedLanguage {
        let prompt = buildGenerationPrompt(mood: mood, tuning: tuning, userName: userName)
        return try await api.sendAndDecode(prompt, as: GeneratedLanguage.self, maxTokens: 8192)
    }

    /// Regenerate a specific component of a language after a tuning change.
    func regenerateComponent(
        component: LanguageComponent,
        mood: MoodProfile,
        tuning: TuningParameters,
        existingLanguage: Language
    ) async throws -> String {
        let prompt = buildRegenerationPrompt(
            component: component,
            mood: mood,
            tuning: tuning,
            existingLanguage: existingLanguage
        )
        return try await api.sendMessage(prompt, maxTokens: 4096)
    }

    // MARK: - Name Transliteration

    /// Transliterate a name into the constructed language's phonological system.
    func transliterateName(
        name: String,
        phonology: Phonology,
        tuning: TuningParameters
    ) async throws -> TransliteratedName {
        let prompt = buildNamePrompt(name: name, phonology: phonology, tuning: tuning)
        return try await api.sendAndDecode(prompt, as: TransliteratedName.self, maxTokens: 1024)
    }

    // MARK: - Translation

    /// Translate an English phrase into the constructed language.
    func translate(
        english: String,
        language: Language
    ) async throws -> Phrase {
        let prompt = buildTranslationPrompt(english: english, language: language)
        return try await api.sendAndDecode(prompt, as: Phrase.self, maxTokens: 1024)
    }

    // MARK: - Loanword Processing

    /// Process a word through the loanword adaptation pipeline.
    func adaptLoanword(
        word: String,
        definition: String,
        language: Language
    ) async throws -> LoanwordAdaptation {
        let prompt = buildLoanwordPrompt(word: word, definition: definition, language: language)
        return try await api.sendAndDecode(prompt, as: LoanwordAdaptation.self, maxTokens: 2048)
    }

    // MARK: - Prompt Builders

    private func buildGenerationPrompt(
        mood: MoodProfile,
        tuning: TuningParameters,
        userName: String?
    ) -> String {
        let moodJSON = encodeToJSONString(mood)
        let tuningJSON = encodeToJSONString(tuning)
        let nameClause = userName.map { "\nThe user's name is \"\($0)\". Include a transliteration of this name in the language's phonological system." } ?? ""

        return """
        You are a master conlanger (constructed language creator) with expertise in \
        phonology, morphology, syntax, and typological universals.

        Based on the following mood profile and tuning parameters, generate a complete \
        constructed language specification.

        MOOD PROFILE: \(moodJSON)

        TUNING PARAMETERS: \(tuningJSON)

        Tuning parameter guide:
        - harshToMelodic (0=harsh, 1=melodic): Controls consonant-to-vowel ratio, \
          presence of stops/fricatives vs liquids/nasals
        - ancientToModern (0=ancient, 1=modern): Controls morphological complexity, \
          case systems, irregular forms
        - sparseToOrnate (0=sparse, 1=ornate): Controls word length, grammar \
          complexity, honorific/politeness systems
        - organicToMechanical (0=organic, 1=mechanical): Controls whether vocabulary \
          roots derive from nature or abstraction
        - intimateToFormal (0=intimate, 1=formal): Controls pronoun complexity, \
          register systems
        - aggressionLevel (0=peaceful, 1=aggressive): Controls plosives, gutturals, \
          consonant clusters
        - musicality (0=monotone, 1=musical): Controls tonal qualities, vowel harmony, \
          rhythmic patterns
        - alienFamiliar (0=alien, 1=familiar): Controls adherence to human language \
          typological universals
        \(nameClause)

        Generate and return a JSON object with:
        1. "name": A name for this language (in the language itself)
        2. "description": A 2-3 sentence poetic description of how this language sounds and feels
        3. "phonology": { "consonants", "vowels" (each with "symbol", "description", "romanization"), \
           "phonotacticRules", "stressPattern", "toneSystem" }
        4. "grammar": { "wordOrder", "morphologicalType", "nounCases", "verbConjugation", \
           "pluralFormation", "possessiveSystem", "tenseSystem", "negation", "questionFormation", "rules" }
        5. "lexicon": 50 core vocabulary words, each with "word", "pronunciation" (IPA), \
           "partOfSpeech", "englishTranslation", "rootWord". Include: pronouns, numbers 1-10, \
           common nouns (water, fire, earth, sky, person, home, food, love, war, death), \
           common verbs (be, go, see, speak, give, take, make, know), common adjectives \
           (good, bad, big, small, old, new)
        6. "samplePhrases": 10 example sentences with "conlang", "english", "pronunciation" (IPA), \
           and "literalTranslation" (word-by-word). Include: greeting, farewell, "I love you", \
           "What is your name?", "The sun rises", and 5 others that showcase the language's character
        7. "flag": { "colors" (3-5 hex), "division", "chargePosition", "description" }
        8. "sigil": { "baseShape", "internalComplexity" (1-5), "strokeStyle", "symmetry", "description" }

        All vocabulary must be systematically derived from root words. The language \
        should feel organic and internally consistent, not random.

        Return ONLY the JSON object, no other text.
        """
    }

    private func buildNamePrompt(
        name: String,
        phonology: Phonology,
        tuning: TuningParameters
    ) -> String {
        let phonologyJSON = encodeToJSONString(phonology)
        let tuningJSON = encodeToJSONString(tuning)

        return """
        Transliterate the name "\(name)" into a constructed language with this phonological system:

        PHONOLOGY: \(phonologyJSON)
        TUNING: \(tuningJSON)

        Process:
        1. Analyze the source name's phonemes
        2. Map each phoneme to the closest equivalent in the conlang's inventory
        3. Restructure syllables to match the conlang's phonotactic rules
        4. Apply the conlang's stress pattern

        Return a JSON object:
        {
          "transliterated": "the name in the conlang",
          "pronunciation": "IPA pronunciation",
          "poeticDescription": "1-2 sentence emotional interpretation of what the name feels like in this language"
        }

        Return ONLY the JSON, no other text.
        """
    }

    private func buildTranslationPrompt(english: String, language: Language) -> String {
        let lexiconSummary = language.lexicon.prefix(100).map {
            "\($0.englishTranslation): \($0.word) [\($0.pronunciation)]"
        }.joined(separator: "\n")

        let grammarJSON = encodeToJSONString(language.grammar)

        return """
        Translate the following English phrase into a constructed language.

        ENGLISH: "\(english)"

        GRAMMAR: \(grammarJSON)

        EXISTING VOCABULARY:
        \(lexiconSummary)

        Using the grammar rules and existing vocabulary, translate the phrase. \
        Create new words consistent with the language's phonology if needed.

        Return a JSON object:
        {
          "conlang": "the translated phrase",
          "english": "\(english)",
          "pronunciation": "IPA pronunciation",
          "literalTranslation": "word-by-word gloss"
        }

        Return ONLY the JSON, no other text.
        """
    }

    private func buildLoanwordPrompt(word: String, definition: String, language: Language) -> String {
        let phonologyJSON = encodeToJSONString(language.phonology)
        let sampleRoots = language.lexicon.prefix(20).compactMap { $0.rootWord }.joined(separator: ", ")

        return """
        A user wants to handle the word "\(word)" (\(definition)) in their constructed language.

        LANGUAGE PHONOLOGY: \(phonologyJSON)
        EXISTING ROOTS: \(sampleRoots)

        Provide two options:

        1. "adopted": Phonetically adapt "\(word)" to fit the conlang's sound system. \
           Apply phonotactic rules, map to available phonemes, restructure syllables.
        2. "derived": Build a new compound word from the language's existing roots and \
           morphological patterns. Break the concept into semantic components and combine them.

        Return a JSON object:
        {
          "adopted": {
            "word": "adapted form",
            "pronunciation": "IPA",
            "explanation": "how the adaptation was done"
          },
          "derived": {
            "word": "compound form",
            "pronunciation": "IPA",
            "etymology": "root1 (meaning) + root2 (meaning) + affix",
            "literalMeaning": "what the compound literally translates to"
          },
          "whyComplex": "brief explanation of why this concept resists simple translation"
        }

        Return ONLY the JSON, no other text.
        """
    }

    private func buildRegenerationPrompt(
        component: LanguageComponent,
        mood: MoodProfile,
        tuning: TuningParameters,
        existingLanguage: Language
    ) -> String {
        let moodJSON = encodeToJSONString(mood)
        let tuningJSON = encodeToJSONString(tuning)

        return """
        Regenerate the \(component.rawValue) component of a constructed language \
        named "\(existingLanguage.name)" based on updated parameters.

        MOOD PROFILE: \(moodJSON)
        TUNING PARAMETERS: \(tuningJSON)

        Maintain consistency with the existing language where possible, \
        but adapt the \(component.rawValue) to reflect the new tuning.

        Return ONLY the updated \(component.rawValue) as a JSON object.
        """
    }

    // MARK: - Helpers

    private func encodeToJSONString<T: Encodable>(_ value: T) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(value),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }
}

// MARK: - Response Types

/// The full language specification returned by the generation API.
struct GeneratedLanguage: Decodable {
    let name: String
    let description: String
    let phonology: Phonology
    let grammar: Grammar
    let lexicon: [LexiconEntry]
    let samplePhrases: [Phrase]
    let flag: GeneratedFlag?
    let sigil: GeneratedSigil?
}

struct GeneratedFlag: Decodable {
    let colors: [String]
    let division: String
    let chargePosition: String
    let description: String?
}

struct GeneratedSigil: Decodable {
    let baseShape: String
    let internalComplexity: Int
    let strokeStyle: String
    let symmetry: String
    let description: String?
}

/// Result of name transliteration.
struct TransliteratedName: Decodable {
    let transliterated: String
    let pronunciation: String
    let poeticDescription: String
}

/// Result of loanword adaptation (both paths).
struct LoanwordAdaptation: Decodable {
    let adopted: AdoptedWord
    let derived: DerivedWord
    let whyComplex: String

    struct AdoptedWord: Decodable {
        let word: String
        let pronunciation: String
        let explanation: String
    }

    struct DerivedWord: Decodable {
        let word: String
        let pronunciation: String
        let etymology: String
        let literalMeaning: String
    }
}
