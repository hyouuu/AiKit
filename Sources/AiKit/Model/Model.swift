import Foundation

/**
 List and describe the various models available in the API.
 */
public struct Model: Codable {
    public let id: String
    public let object: String
    public let created: Date
    public let ownedBy: String
    public let permission: [Permission]
    public let root: String
    public let parent: String?
}

extension Model {
    public struct Permission: Codable {
        public let id: String
        public let object: String
        public let created: Date
        public let allowCreateEngine: Bool
        public let allowSampling: Bool
        public let allowLogprobs: Bool
        public let allowSearchIndices: Bool
        public let allowView: Bool
        public let allowFineTuning: Bool
        public let organization: String
        public let group: String?
        public let isBlocking: Bool
    }
}

public protocol ModelId {
    var id: String { get }
}

extension Model {
    public enum xAI: String, ModelId {
        // https://docs.x.ai/docs/models
        case grok = "grok-3-mini"
    }

    public enum openAI: String, ModelId {
        // https://openai.com/api/pricing/
        // https://platform.openai.com/docs/guides/tools-web-search?api-mode=chat
//        case gpt = "gpt-4o-mini"
        case gpt = "gpt-4o-mini-search-preview"
        case o3 = "o3-mini"
    }

    public enum deepSeek: String, ModelId {
        // https://api-docs.deepseek.com/quick_start/pricing
        case chat = "deepseek-chat"
        case reasoner = "deepseek-reasoner"
    }

    // Used for edits etc 
    public enum GPT3: String, ModelId {
        case gpt3_5Turbo = "gpt-3.5-turbo"
        case gpt3_5Turbo16K = "gpt-3.5-turbo-16k"
        case gpt3_5Turbo0301 = "gpt-3.5-turbo-0301"
        case textDavinci003 = "text-davinci-003"
        case textDavinci002 = "text-davinci-002"
        case textCurie001 = "text-curie-001"
        case textBabbage001 = "text-babbage-001"
        case textAda001 = "text-ada-001"
        case textEmbeddingAda002 = "text-embedding-ada-002"
        case textDavinci001 = "text-davinci-001"
        case textDavinciEdit001 = "text-davinci-edit-001"
        case davinciInstructBeta = "davinci-instruct-beta"
        case davinci
        case curieInstructBeta = "curie-instruct-beta"
        case curie
        case ada
        case babbage
    }

    public enum Codex: String, ModelId {
        case codeDavinci002 = "code-davinci-002"
        case codeCushman001 = "code-cushman-001"
        case codeDavinci001 = "code-davinci-001"
        case codeDavinciEdit001 = "code-davinci-edit-001"
    }

    public enum Whisper: String, ModelId {
        case whisper1 = "whisper-1"
    }
}

extension RawRepresentable where RawValue == String {
    public var id: String {
        rawValue
    }
}
