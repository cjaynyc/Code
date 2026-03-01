import SwiftUI

@main
struct SynesthesiaApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}

/// Root application state shared across all views.
@MainActor
final class AppState: ObservableObject {
    @Published var languages: [Language] = []
    @Published var activeLanguage: Language?
    @Published var isGenerating = false

    let apiService: ClaudeAPIService
    let imageAnalysis: ImageAnalysisService
    let languageGeneration: LanguageGenerationService
    let audioService: AudioService

    init() {
        let config = APIConfiguration()
        let api = ClaudeAPIService(configuration: config)
        self.apiService = api
        self.imageAnalysis = ImageAnalysisService(api: api)
        self.languageGeneration = LanguageGenerationService(api: api)
        self.audioService = AudioService()
    }

    func createLanguage(
        from sources: [InspirationSource],
        tuning: TuningParameters,
        userName: String? = nil
    ) async throws -> Language {
        isGenerating = true
        defer { isGenerating = false }

        let mood = try await imageAnalysis.analyzeAndBlend(sources: sources)
        let generated = try await languageGeneration.generateLanguage(
            mood: mood, tuning: tuning, userName: userName
        )

        var identity: LanguageIdentity?
        if let flag = generated.flag, let sigil = generated.sigil {
            identity = LanguageIdentity(
                flag: FlagSpec(
                    colors: flag.colors,
                    division: FlagDivision(rawValue: flag.division) ?? .bicolorHorizontal,
                    chargePosition: ChargePosition(rawValue: flag.chargePosition) ?? .center,
                    description: flag.description
                ),
                sigil: SigilSpec(
                    baseShape: SigilBaseShape(rawValue: sigil.baseShape) ?? .circle,
                    internalComplexity: sigil.internalComplexity,
                    strokeStyle: SigilStrokeStyle(rawValue: sigil.strokeStyle) ?? .clean,
                    symmetry: SymmetryType(rawValue: sigil.symmetry) ?? .bilateral,
                    primaryColor: generated.flag?.colors.first ?? "#FFFFFF",
                    paths: [],
                    description: sigil.description
                )
            )
        }

        let language = Language(
            name: generated.name,
            moodProfile: mood,
            phonology: generated.phonology,
            grammar: generated.grammar,
            lexicon: generated.lexicon,
            samplePhrases: generated.samplePhrases,
            inspirationSources: sources,
            tuningParameters: tuning,
            identity: identity,
            languageDescription: generated.description
        )

        languages.append(language)
        activeLanguage = language
        return language
    }
}
