import Foundation

public struct Usage: Sendable {
    public let promptTokens: Int
    public let completionTokens: Int?
    public let totalTokens: Int
    public let promptTokensDetails: PromptTokensDetails?
    /// DeepSeek reports cache hits here instead of `promptTokensDetails`.
    public let promptCacheHitTokens: Int?

    /// Prompt tokens served from the provider's prompt cache.
    public var cachedTokens: Int {
        promptTokensDetails?.cachedTokens ?? promptCacheHitTokens ?? 0
    }
}

public struct PromptTokensDetails: Sendable, Codable {
    public let cachedTokens: Int?
}

extension Usage: Codable {}
