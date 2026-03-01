import Foundation

/// Configuration for the Anthropic Claude API.
/// API key is resolved from (in order): explicit value, environment variable, or Info.plist.
struct APIConfiguration {
    let apiKey: String
    let baseURL: URL
    let model: String
    let anthropicVersion: String

    static let defaultBaseURL = URL(string: "https://api.anthropic.com/v1")!
    static let defaultModel = "claude-sonnet-4-5-20250929"
    static let defaultAnthropicVersion = "2023-06-01"

    init(
        apiKey: String? = nil,
        baseURL: URL = APIConfiguration.defaultBaseURL,
        model: String = APIConfiguration.defaultModel,
        anthropicVersion: String = APIConfiguration.defaultAnthropicVersion
    ) {
        if let key = apiKey {
            self.apiKey = key
        } else if let envKey = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] {
            self.apiKey = envKey
        } else if let plistKey = Bundle.main.infoDictionary?["ANTHROPIC_API_KEY"] as? String {
            self.apiKey = plistKey
        } else {
            self.apiKey = ""
        }
        self.baseURL = baseURL
        self.model = model
        self.anthropicVersion = anthropicVersion
    }

    var isConfigured: Bool {
        !apiKey.isEmpty
    }
}
