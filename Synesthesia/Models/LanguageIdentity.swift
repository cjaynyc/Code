import Foundation
#if canImport(CoreGraphics)
import CoreGraphics
#endif

/// Visual identity of a language: its flag and sigil.
struct LanguageIdentity: Codable, Equatable {
    var flag: FlagSpec
    var sigil: SigilSpec
}

// MARK: - Flag

/// Specification for a programmatically rendered language flag.
struct FlagSpec: Codable, Equatable {
    /// Hex color array derived from mood profile and inspiration images
    var colors: [String]
    /// How the flag field is divided
    var division: FlagDivision
    /// Where the charge (sigil/emblem) is placed
    var chargePosition: ChargePosition
    /// Optional border treatment
    var borderStyle: BorderStyle?
    /// Optional pattern overlay (e.g. "wave", "grid", "dots")
    var patternOverlay: String?
    /// Brief description of the flag's symbolism
    var description: String?
}

enum FlagDivision: String, Codable {
    case bicolorHorizontal
    case bicolorVertical
    case bicolorDiagonal
    case tricolorHorizontal
    case tricolorVertical
    case chevron
    case saltire
    case quartered
    case radial
}

enum ChargePosition: String, Codable {
    case center
    case canton
    case offset
}

enum BorderStyle: String, Codable {
    case thin
    case thick
    case double
    case fimbriated
    case none
}

// MARK: - Sigil

/// Specification for a compact monochrome-capable symbol representing the language.
struct SigilSpec: Codable, Equatable {
    /// Geometric base shape
    var baseShape: SigilBaseShape
    /// 1-5 layers of internal geometric detail
    var internalComplexity: Int
    /// Visual stroke treatment
    var strokeStyle: SigilStrokeStyle
    /// Symmetry type
    var symmetry: SymmetryType
    /// Primary hex color
    var primaryColor: String
    /// Bezier path data for rendering
    var paths: [SigilPath]
    /// What the sigil represents
    var description: String?
}

enum SigilBaseShape: String, Codable {
    case circle
    case square
    case triangle
    case hexagon
    case diamond
    case octagon
}

enum SigilStrokeStyle: String, Codable {
    case rough
    case clean
    case calligraphic
    case angular
    case organic
}

enum SymmetryType: String, Codable {
    case bilateral
    case radial
    case asymmetric
}

/// A single bezier path segment for sigil rendering.
struct SigilPath: Codable, Equatable {
    var points: [CodablePoint]
    var controlPoints: [CodablePoint]?
    var strokeWidth: Double
    var closed: Bool
}

/// Platform-independent 2D point for Codable serialization.
struct CodablePoint: Codable, Equatable {
    var x: Double
    var y: Double

    #if canImport(CoreGraphics)
    var cgPoint: CGPoint { CGPoint(x: x, y: y) }

    init(_ cgPoint: CGPoint) {
        self.x = cgPoint.x
        self.y = cgPoint.y
    }
    #endif

    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}
