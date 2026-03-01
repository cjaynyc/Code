import Foundation

/// Core HTTP client for the Anthropic Claude Messages API.
/// Handles authentication, request building, and response parsing.
final class ClaudeAPIService: @unchecked Sendable {
    let configuration: APIConfiguration
    private let session: URLSession

    init(configuration: APIConfiguration = APIConfiguration(), session: URLSession = .shared) {
        self.configuration = configuration
        self.session = session
    }

    // MARK: - Public API

    /// Send a text-only message and receive a text response.
    func sendMessage(_ text: String, maxTokens: Int = 4096) async throws -> String {
        let messages = [Message(role: "user", content: .text(text))]
        let response = try await performRequest(messages: messages, maxTokens: maxTokens)
        return try extractText(from: response)
    }

    /// Send a message with an image (base64-encoded) and receive a text response.
    func sendMessageWithImage(
        text: String,
        imageData: Data,
        mediaType: ImageMediaType = .jpeg,
        maxTokens: Int = 4096
    ) async throws -> String {
        let base64 = imageData.base64EncodedString()
        let imageContent = ContentBlock.image(
            ImageSource(type: "base64", mediaType: mediaType.rawValue, data: base64)
        )
        let textContent = ContentBlock.text(text)
        let messages = [Message(role: "user", content: .blocks([imageContent, textContent]))]
        let response = try await performRequest(messages: messages, maxTokens: maxTokens)
        return try extractText(from: response)
    }

    /// Send a structured conversation (multiple messages) and receive a text response.
    func sendConversation(_ messages: [Message], maxTokens: Int = 4096) async throws -> String {
        let response = try await performRequest(messages: messages, maxTokens: maxTokens)
        return try extractText(from: response)
    }

    /// Send a message and parse the JSON response into a Decodable type.
    func sendAndDecode<T: Decodable>(
        _ text: String,
        as type: T.Type,
        maxTokens: Int = 4096
    ) async throws -> T {
        let responseText = try await sendMessage(text, maxTokens: maxTokens)
        let json = extractJSON(from: responseText)
        guard let data = json.data(using: .utf8) else {
            throw ClaudeAPIError.decodingFailed("Response is not valid UTF-8")
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw ClaudeAPIError.decodingFailed("Failed to decode \(T.self): \(error.localizedDescription)")
        }
    }

    /// Send a message with an image and parse the JSON response into a Decodable type.
    func sendImageAndDecode<T: Decodable>(
        text: String,
        imageData: Data,
        mediaType: ImageMediaType = .jpeg,
        as type: T.Type,
        maxTokens: Int = 4096
    ) async throws -> T {
        let responseText = try await sendMessageWithImage(
            text: text, imageData: imageData, mediaType: mediaType, maxTokens: maxTokens
        )
        let json = extractJSON(from: responseText)
        guard let data = json.data(using: .utf8) else {
            throw ClaudeAPIError.decodingFailed("Response is not valid UTF-8")
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw ClaudeAPIError.decodingFailed("Failed to decode \(T.self): \(error.localizedDescription)")
        }
    }

    // MARK: - Internal

    private func performRequest(messages: [Message], maxTokens: Int) async throws -> APIResponse {
        guard configuration.isConfigured else {
            throw ClaudeAPIError.notConfigured
        }

        let url = configuration.baseURL.appendingPathComponent("messages")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(configuration.apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(configuration.anthropicVersion, forHTTPHeaderField: "anthropic-version")

        let body = APIRequest(
            model: configuration.model,
            maxTokens: maxTokens,
            messages: messages
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, httpResponse) = try await session.data(for: request)

        guard let response = httpResponse as? HTTPURLResponse else {
            throw ClaudeAPIError.invalidResponse
        }

        switch response.statusCode {
        case 200:
            return try JSONDecoder().decode(APIResponse.self, from: data)
        case 401:
            throw ClaudeAPIError.unauthorized
        case 429:
            throw ClaudeAPIError.rateLimited
        case 400:
            let errorBody = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw ClaudeAPIError.badRequest(errorBody?.error.message ?? "Bad request")
        case 500...599:
            throw ClaudeAPIError.serverError(response.statusCode)
        default:
            throw ClaudeAPIError.httpError(response.statusCode)
        }
    }

    private func extractText(from response: APIResponse) throws -> String {
        guard let textBlock = response.content.first(where: {
            if case .text = $0 { return true }
            return false
        }) else {
            throw ClaudeAPIError.noTextInResponse
        }
        if case .text(let text) = textBlock {
            return text
        }
        throw ClaudeAPIError.noTextInResponse
    }

    /// Extract JSON from a response that may contain markdown fences or surrounding text.
    private func extractJSON(from text: String) -> String {
        // Try to find JSON within markdown code fences
        if let fenceRange = text.range(of: "```json\n"),
           let endRange = text.range(of: "\n```", range: fenceRange.upperBound..<text.endIndex) {
            return String(text[fenceRange.upperBound..<endRange.lowerBound])
        }
        if let fenceRange = text.range(of: "```\n"),
           let endRange = text.range(of: "\n```", range: fenceRange.upperBound..<text.endIndex) {
            return String(text[fenceRange.upperBound..<endRange.lowerBound])
        }

        // Try to find a JSON object or array directly
        if let start = text.firstIndex(of: "{"),
           let end = text.lastIndex(of: "}") {
            return String(text[start...end])
        }
        if let start = text.firstIndex(of: "["),
           let end = text.lastIndex(of: "]") {
            return String(text[start...end])
        }

        return text
    }
}

// MARK: - Request/Response Types

struct APIRequest: Encodable {
    let model: String
    let maxTokens: Int
    let messages: [Message]

    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case messages
    }
}

struct Message: Codable {
    let role: String
    let content: MessageContent
}

enum MessageContent: Codable {
    case text(String)
    case blocks([ContentBlock])

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .text(let string):
            try container.encode(string)
        case .blocks(let blocks):
            try container.encode(blocks)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .text(string)
        } else {
            let blocks = try container.decode([ContentBlock].self)
            self = .blocks(blocks)
        }
    }
}

enum ContentBlock: Codable {
    case text(String)
    case image(ImageSource)

    private enum CodingKeys: String, CodingKey {
        case type, text, source
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .text)
        case .image(let source):
            try container.encode("image", forKey: .type)
            try container.encode(source, forKey: .source)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "text":
            let text = try container.decode(String.self, forKey: .text)
            self = .text(text)
        case "image":
            let source = try container.decode(ImageSource.self, forKey: .source)
            self = .image(source)
        default:
            throw DecodingError.dataCorrupted(.init(
                codingPath: container.codingPath,
                debugDescription: "Unknown content block type: \(type)"
            ))
        }
    }
}

struct ImageSource: Codable {
    let type: String
    let mediaType: String
    let data: String

    enum CodingKeys: String, CodingKey {
        case type
        case mediaType = "media_type"
        case data
    }
}

enum ImageMediaType: String {
    case jpeg = "image/jpeg"
    case png = "image/png"
    case gif = "image/gif"
    case webp = "image/webp"
}

struct APIResponse: Decodable {
    let id: String
    let type: String
    let role: String
    let content: [ResponseContentBlock]
    let model: String
    let usage: Usage

    struct Usage: Decodable {
        let inputTokens: Int
        let outputTokens: Int

        enum CodingKeys: String, CodingKey {
            case inputTokens = "input_tokens"
            case outputTokens = "output_tokens"
        }
    }
}

enum ResponseContentBlock: Decodable {
    case text(String)

    private enum CodingKeys: String, CodingKey {
        case type, text
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "text":
            let text = try container.decode(String.self, forKey: .text)
            self = .text(text)
        default:
            self = .text("")
        }
    }
}

struct APIErrorResponse: Decodable {
    let type: String
    let error: APIErrorDetail
}

struct APIErrorDetail: Decodable {
    let type: String
    let message: String
}

// MARK: - Errors

enum ClaudeAPIError: LocalizedError {
    case notConfigured
    case unauthorized
    case rateLimited
    case badRequest(String)
    case serverError(Int)
    case httpError(Int)
    case invalidResponse
    case noTextInResponse
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "API key not configured. Set ANTHROPIC_API_KEY in environment or Info.plist."
        case .unauthorized:
            return "Invalid API key."
        case .rateLimited:
            return "Rate limited. Please wait and try again."
        case .badRequest(let message):
            return "Bad request: \(message)"
        case .serverError(let code):
            return "Server error (\(code)). Please try again."
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .invalidResponse:
            return "Invalid response from server."
        case .noTextInResponse:
            return "No text content in API response."
        case .decodingFailed(let message):
            return "Failed to parse response: \(message)"
        }
    }
}
