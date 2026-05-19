import Foundation

/**
 List and describe the various models available in the API.
 */
public struct Model: Codable, Sendable {
    public let id: String
    public let object: String
    public let created: Date
    public let ownedBy: String
    public let permission: [Permission]
    public let root: String
    public let parent: String?
}

extension Model {
    public struct Permission: Codable, Sendable {
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

public protocol ModelId: Sendable {
    var id: String { get }
}

extension Model {
    public enum xAI: String, ModelId {
        // https://docs.x.ai/developers/models
        // https://docs.x.ai/developers/pricing
        // grok-3-mini and grok-4* fast/code variants retired on 2026-05-15.
        // Both models below: $1.25 / 1M input, $2.50 / 1M output.
        case grok = "grok-4.20-non-reasoning" // 2M context, non-reasoning chat workloads
        case grokReasoner = "grok-4.3"        // 1M context, supports low/medium/high reasoning effort
    }

    public enum openAI: String, ModelId {
        // https://platform.openai.com/docs/pricing
        // Note: the gpt-5 family is optimized for the Responses API:
        // https://platform.openai.com/docs/guides/migrate-to-responses
        case gpt = "gpt-5-nano"          // cheapest: $0.05 / 1M input, $0.40 / 1M output
        case gptMini = "gpt-5-mini"      // mid-tier: $0.25 / 1M input, $2.00 / 1M output
        case gpt41Nano = "gpt-4.1-nano"  // Chat-Completions-friendly: $0.10 / 1M input, $0.40 / 1M output
    }

    public enum deepSeek: String, ModelId {
        // https://api-docs.deepseek.com/quick_start/pricing
        // Legacy ids `deepseek-chat` / `deepseek-reasoner` are deprecated and
        // will stop working after 2026-07-24. V4 unifies thinking and
        // non-thinking modes under a single model id (toggled via API param).
        case chat = "deepseek-v4-flash" // $0.14 / 1M input (cache miss), $0.28 / 1M output
        case pro = "deepseek-v4-pro"    // $0.435 / $0.87 (promo until 2026-05-31), $1.74 / $3.48 standard
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
