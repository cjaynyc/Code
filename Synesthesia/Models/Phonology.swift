import Foundation

/// Phonological system defining the sound inventory and rules of a language.
struct Phonology: Codable, Equatable {
    var consonants: [Phoneme]
    var vowels: [Phoneme]
    /// Syllable structure templates, e.g. "CV", "CVC", "CCVC"
    var phonotacticRules: [String]
    /// Stress pattern description, e.g. "penultimate", "initial", "final"
    var stressPattern: String
    /// Tone system description, or nil if the language is non-tonal
    var toneSystem: String?
}

/// A single sound unit in the language's phonological inventory.
struct Phoneme: Codable, Identifiable, Equatable {
    let id: UUID
    /// IPA symbol, e.g. "p", "t", "a"
    var symbol: String
    /// Human-readable description, e.g. "voiceless bilabial stop"
    var description: String
    /// How this phoneme is written in the conlang's romanization
    var romanization: String

    init(id: UUID = UUID(), symbol: String, description: String, romanization: String) {
        self.id = id
        self.symbol = symbol
        self.description = description
        self.romanization = romanization
    }
}
