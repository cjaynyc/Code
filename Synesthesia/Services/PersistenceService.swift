import Foundation

/// JSON-to-disk persistence for languages and app settings.
/// Stores each language as a separate JSON file in the app's documents directory.
final class PersistenceService {
    private let fileManager = FileManager.default

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var languagesDirectory: URL {
        documentsDirectory.appendingPathComponent("Languages", isDirectory: true)
    }

    private var settingsURL: URL {
        documentsDirectory.appendingPathComponent("settings.json")
    }

    init() {
        ensureDirectoryExists(languagesDirectory)
    }

    // MARK: - Languages

    /// Save a single language to disk.
    func save(_ language: Language) throws {
        let url = languageURL(for: language.id)
        let data = try encoder.encode(language)
        try data.write(to: url, options: .atomic)
    }

    /// Save all languages to disk (full sync).
    func saveAll(_ languages: [Language]) throws {
        // Remove files for languages that no longer exist
        let existingIDs = Set(languages.map { $0.id.uuidString })
        if let files = try? fileManager.contentsOfDirectory(at: languagesDirectory, includingPropertiesForKeys: nil) {
            for file in files where file.pathExtension == "json" {
                let stem = file.deletingPathExtension().lastPathComponent
                if !existingIDs.contains(stem) {
                    try? fileManager.removeItem(at: file)
                }
            }
        }
        for language in languages {
            try save(language)
        }
    }

    /// Load all saved languages from disk.
    func loadAll() -> [Language] {
        guard let files = try? fileManager.contentsOfDirectory(
            at: languagesDirectory, includingPropertiesForKeys: [.contentModificationDateKey]
        ) else { return [] }

        return files
            .filter { $0.pathExtension == "json" }
            .compactMap { url -> Language? in
                guard let data = try? Data(contentsOf: url) else { return nil }
                return try? decoder.decode(Language.self, from: data)
            }
            .sorted { $0.createdAt < $1.createdAt }
    }

    /// Delete a language from disk.
    func delete(_ language: Language) throws {
        let url = languageURL(for: language.id)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }

    // MARK: - Settings

    /// Save app settings to disk.
    func saveSettings(_ settings: AppSettings) throws {
        let data = try encoder.encode(settings)
        try data.write(to: settingsURL, options: .atomic)
    }

    /// Load app settings from disk.
    func loadSettings() -> AppSettings {
        guard let data = try? Data(contentsOf: settingsURL),
              let settings = try? decoder.decode(AppSettings.self, from: data) else {
            return AppSettings()
        }
        return settings
    }

    // MARK: - Private

    private func languageURL(for id: UUID) -> URL {
        languagesDirectory.appendingPathComponent("\(id.uuidString).json")
    }

    private func ensureDirectoryExists(_ url: URL) {
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }

    private var encoder: JSONEncoder {
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        return enc
    }

    private var decoder: JSONDecoder {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        return dec
    }
}

// MARK: - App Settings

/// Persisted app-wide settings including API key.
struct AppSettings: Codable {
    var apiKey: String = ""
    var preferredModel: String = APIConfiguration.defaultModel
    var hapticFeedbackEnabled: Bool = true
    var autoSaveEnabled: Bool = true

    var hasAPIKey: Bool { !apiKey.isEmpty }
}
