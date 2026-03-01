import Foundation

/// Grammar rules defining the syntactic and morphological structure of a language.
struct Grammar: Codable, Equatable {
    /// Basic word order, e.g. "SOV", "SVO", "VSO"
    var wordOrder: String
    /// Morphological type: "agglutinative", "fusional", "isolating", "polysynthetic"
    var morphologicalType: String
    /// Noun case system, e.g. ["nominative", "accusative", "dative"], or nil if none
    var nounCases: [String]?
    /// Verb conjugation pattern description
    var verbConjugation: String
    /// How plurals are formed
    var pluralFormation: String
    /// How possession is expressed
    var possessiveSystem: String
    /// Available tenses, e.g. ["past", "present", "future"]
    var tenseSystem: [String]
    /// How negation works
    var negation: String
    /// How questions are formed
    var questionFormation: String
    /// Human-readable grammar rules
    var rules: [String]
}
