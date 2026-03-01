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
    @Published var settings: AppSettings

    let persistence: PersistenceService
    private(set) var apiService: ClaudeAPIService
    private(set) var imageAnalysis: ImageAnalysisService
    private(set) var languageGeneration: LanguageGenerationService
    let audioService: AudioService

    init() {
        let persistence = PersistenceService()
        self.persistence = persistence

        let loadedSettings = persistence.loadSettings()
        self.settings = loadedSettings

        // Build API services using saved key if available
        let config = APIConfiguration(
            apiKey: loadedSettings.hasAPIKey ? loadedSettings.apiKey : nil,
            model: loadedSettings.preferredModel
        )
        let api = ClaudeAPIService(configuration: config)
        self.apiService = api
        self.imageAnalysis = ImageAnalysisService(api: api)
        self.languageGeneration = LanguageGenerationService(api: api)
        self.audioService = AudioService()

        // Load saved languages
        self.languages = persistence.loadAll()
    }

    /// Update the API key and rebuild services.
    func updateAPIKey(_ key: String) {
        settings.apiKey = key
        try? persistence.saveSettings(settings)

        let config = APIConfiguration(apiKey: key, model: settings.preferredModel)
        let api = ClaudeAPIService(configuration: config)
        self.apiService = api
        self.imageAnalysis = ImageAnalysisService(api: api)
        self.languageGeneration = LanguageGenerationService(api: api)
    }

    /// Save current settings to disk.
    func saveSettings() {
        try? persistence.saveSettings(settings)
    }

    /// Persist a language after creation or update.
    func persistLanguage(_ language: Language) {
        try? persistence.save(language)
    }

    /// Delete a language from memory and disk.
    func deleteLanguage(_ language: Language) {
        languages.removeAll { $0.id == language.id }
        if activeLanguage?.id == language.id { activeLanguage = nil }
        try? persistence.delete(language)
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
        persistLanguage(language)
        return language
    }
}
