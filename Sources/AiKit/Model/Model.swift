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
        // GPT-5.6 family (2026-06-25): 1M context, 128K output, knowledge cutoff
        // 2026-02-16. Every model is reasoning-capable; pass reasoning_effort
        // "none" for classic low-latency chat behaviour (no reasoning tokens).
        case luna = "gpt-5.6-luna"       // nano tier: $0.20 / 1M input, $1.20 / 1M output
        case terra = "gpt-5.6-terra"     // mini tier: $2.00 / 1M input, $12.00 / 1M output
        case sol = "gpt-5.6-sol"         // flagship: $4.00 / 1M input, $20.00 / 1M output (promo)

        // Original gpt-5 family. Dated snapshots shut down 2026-12-11; only
        // support reasoning_effort down to "minimal", never "none".
        case gpt = "gpt-5-nano"          // $0.05 / 1M input, $0.40 / 1M output
        case gptMini = "gpt-5-mini"      // $0.25 / 1M input, $2.00 / 1M output
        case gpt41Nano = "gpt-4.1-nano"  // shuts down 2026-10-23
    }

    public enum deepSeek: String, ModelId {
        // https://api-docs.deepseek.com/quick_start/pricing
        // Legacy ids `deepseek-chat` / `deepseek-reasoner` are deprecated and
        // will stop working after 2026-07-24. V4 unifies thinking and
        // non-thinking modes under a single model id (toggled via API param).
        case chat = "deepseek-v4-flash" // $0.14 / 1M input (cache miss), $0.28 / 1M output
        case pro = "deepseek-v4-pro"    // $0.435 / $0.87 (promo until 2026-05-31), $1.74 / $3.48 standard
    }

    public enum anthropic: String, ModelId {
        // https://platform.claude.com/docs/en/about-claude/pricing
        // Served via Anthropic's OpenAI-compatible layer at /v1/chat/completions
        // (Authorization: Bearer, SSE streaming supported). Caveats: n must be 1,
        // temperature capped at 1, presence/frequency penalties and logit_bias ignored.
        case haiku = "claude-haiku-4-5"   // $1 / 1M input, $5 / 1M output, 200K context
        case sonnet = "claude-sonnet-5"   // $2 / 1M input, $10 / 1M output, 1M context
        case opus = "claude-opus-5"       // $5 / 1M input, $25 / 1M output, 1M context
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
