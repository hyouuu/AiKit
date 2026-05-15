import Foundation

/**
 Given a prompt, the model will return one or more predicted chat completions, and can also return the probabilities of alternative tokens at each position.
 */
public struct Chat: Codable, Sendable {
    public let id: String
    public let object: String
    public let created: Date
    public let model: String
    public let choices: [Choice]
    public let usage: Usage
}

extension Chat {
    public struct Choice: Codable, Sendable {
        public let index: Int
        public let message: Message
        public let finishReason: FinishReason?
    }
}

extension Chat {
    public enum Message: Sendable {
        case system(content: String)
        case user(content: String)
        case userMultipart(parts: [ContentPart])
        case assistant(content: String)
    }

    public enum ContentPart: Sendable {
        case text(String)
        case imageURL(url: String, detail: ImageDetail = .auto)
    }

    public enum ImageDetail: String, Sendable, Codable {
        case auto, low, high
    }
}

extension Chat.ContentPart: Encodable {
    private enum CodingKeys: String, CodingKey {
        case type
        case text
        case imageURL = "image_url"
    }

    private enum ImageURLKeys: String, CodingKey {
        case url
        case detail
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .text)
        case .imageURL(let url, let detail):
            try container.encode("image_url", forKey: .type)
            var nested = container.nestedContainer(keyedBy: ImageURLKeys.self, forKey: .imageURL)
            try nested.encode(url, forKey: .url)
            try nested.encode(detail, forKey: .detail)
        }
    }
}

extension Chat.Message: Codable {
    private enum CodingKeys: String, CodingKey {
        case role
        case content
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let role = try container.decode(String.self, forKey: .role)
        let content = try container.decode(String.self, forKey: .content)
        switch role {
        case "system":
            self = .system(content: content)
        case "user":
            self = .user(content: content)
        case "assistant":
            self = .assistant(content: content)
        default:
            throw DecodingError.dataCorruptedError(forKey: .role, in: container, debugDescription: "Invalid type")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .system(let content):
            try container.encode("system", forKey: .role)
            try container.encode(content, forKey: .content)
        case .user(let content):
            try container.encode("user", forKey: .role)
            try container.encode(content, forKey: .content)
        case .userMultipart(let parts):
            try container.encode("user", forKey: .role)
            try container.encode(parts, forKey: .content)
        case .assistant(let content):
            try container.encode("assistant", forKey: .role)
            try container.encode(content, forKey: .content)
        }
    }
}

extension Chat.Message {
    public static func user(
        content: String,
        imageURLs: [String],
        detail: Chat.ImageDetail = .auto
    ) -> Self {
        var parts: [Chat.ContentPart] = []
        if !content.isEmpty {
            parts.append(.text(content))
        }
        for url in imageURLs {
            parts.append(.imageURL(url: url, detail: detail))
        }
        return .userMultipart(parts: parts)
    }

    public static func user(
        content: String,
        imageData: Data,
        mimeType: String = "image/jpeg",
        detail: Chat.ImageDetail = .auto
    ) -> Self {
        let dataURL = "data:\(mimeType);base64,\(imageData.base64EncodedString())"
        var parts: [Chat.ContentPart] = []
        if !content.isEmpty {
            parts.append(.text(content))
        }
        parts.append(.imageURL(url: dataURL, detail: detail))
        return .userMultipart(parts: parts)
    }
}

extension Chat.Message {
    public var content: String {
        get {
            switch self {
            case .system(let content), .user(let content), .assistant(let content):
                return content
            case .userMultipart(let parts):
                return parts.compactMap { part in
                    if case .text(let text) = part { return text }
                    return nil
                }.joined(separator: "\n")
            }
        }
        set {
            switch self {
            case .system: self = .system(content: newValue)
            case .user: self = .user(content: newValue)
            case .assistant: self = .assistant(content: newValue)
            case .userMultipart(let parts):
                let images = parts.filter { if case .imageURL = $0 { return true } else { return false } }
                var newParts: [Chat.ContentPart] = []
                if !newValue.isEmpty {
                    newParts.append(.text(newValue))
                }
                newParts.append(contentsOf: images)
                self = .userMultipart(parts: newParts)
            }
        }
    }
}
