import Foundation

public struct ChatStream: Codable, Sendable {
    public let id: String
    public let object: String
    public let created: Date
    public let model: String
    public let choices: [ChatStream.Choice]
    /// Present on the final chunk when the request set `includeUsage`.
    public let usage: Usage?
}

extension ChatStream {
    public struct Choice: Codable, Sendable {
        public let index: Int
        public let finishReason: FinishReason?
        public let delta: ChatStream.Choice.Message
    }
}

extension ChatStream.Choice {
    public struct Message: Codable, Sendable {
        public let content: String?
        public let role: String?
    }
}


