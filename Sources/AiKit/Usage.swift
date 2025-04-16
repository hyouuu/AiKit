import Foundation

public struct Usage: Sendable {
    public let promptTokens: Int
    public let completionTokens: Int?
    public let totalTokens: Int
}

extension Usage: Codable {}
