import Foundation

/// User-adjustable linguistic parameters that control language generation.
/// All values range from 0.0 to 1.0.
struct TuningParameters: Codable, Equatable {
    /// 0 = harsh consonants/stops, 1 = melodic liquids/nasals
    var harshToMelodic: Double
    /// 0 = archaic morphology/case systems, 1 = modern/simplified
    var ancientToModern: Double
    /// 0 = short words/simple grammar, 1 = long words/complex grammar
    var sparseToOrnate: Double
    /// 0 = nature-derived roots, 1 = abstract/mechanical roots
    var organicToMechanical: Double
    /// 0 = simple pronouns/intimate, 1 = complex registers/formal
    var intimateToFormal: Double
    /// 0 = soft onsets/open vowels, 1 = plosives/guttural clusters
    var aggressionLevel: Double
    /// 0 = monotone, 1 = tonal/vowel harmony/rhythmic
    var musicality: Double
    /// 0 = alien/unfamiliar, 1 = adheres to human typological universals
    var alienFamiliar: Double

    static let defaultValues = TuningParameters(
        harshToMelodic: 0.5,
        ancientToModern: 0.5,
        sparseToOrnate: 0.5,
        organicToMechanical: 0.5,
        intimateToFormal: 0.5,
        aggressionLevel: 0.5,
        musicality: 0.5,
        alienFamiliar: 0.5
    )
}
