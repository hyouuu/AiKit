import AsyncHTTPClient
import NIOHTTP1
import Foundation

struct CreateChatRequest: Request {
    let method: HTTPMethod = .POST
    let path = "/v1/chat/completions"
    let body: Data?
    
    init(
        model: String,
        messages: [Chat.Message],
        temperature: Double?,
        topP: Double?,
        n: Int?,
        stream: Bool,
        stops: [String],
        maxTokens: Int?,
        maxCompletionTokens: Int? = nil,
        presencePenalty: Double?,
        frequencyPenalty: Double?,
        logitBias: [String: Int],
        user: String?,
        reasoningEffort: ReasoningEffort? = nil,
        promptCacheKey: String? = nil,
        promptCacheRetention: PromptCacheRetention? = nil
    ) throws {
        
        let body = Body(
            model: model,
            messages: messages,
            temperature: temperature,
            topP: topP,
            n: n,
            stream: stream,
            stops: stops,
            maxTokens: maxTokens,
            maxCompletionTokens: maxCompletionTokens,
            presencePenalty: presencePenalty,
            frequencyPenalty: frequencyPenalty,
            logitBias: logitBias,
            user: user,
            reasoningEffort: reasoningEffort,
            promptCacheKey: promptCacheKey,
            promptCacheRetention: promptCacheRetention
        )
                
        self.body = try Self.encoder.encode(body)
    }
}

extension CreateChatRequest {
    struct Body: Encodable {
        let model: String
        let messages: [Chat.Message]
        let temperature: Double?
        let topP: Double?
        let n: Int?
        let stream: Bool
        let stops: [String]
        let maxTokens: Int?
        /// OpenAI gpt-5 / o-series reject `max_tokens` and want this instead.
        let maxCompletionTokens: Int?
        let presencePenalty: Double?
        let frequencyPenalty: Double?
        let logitBias: [String: Int]
        let user: String?
        let reasoningEffort: ReasoningEffort?
        let promptCacheKey: String?
        let promptCacheRetention: PromptCacheRetention?
            
        enum CodingKeys: CodingKey {
            case model
            case messages
            case temperature
            case topP
            case n
            case stream
            case stop
            case maxTokens
            case maxCompletionTokens
            case presencePenalty
            case frequencyPenalty
            case logitBias
            case user
            case reasoningEffort
            case promptCacheKey
            case promptCacheRetention
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(model, forKey: .model)
            
            if !messages.isEmpty {
                try container.encode(messages, forKey: .messages)
            }

            if let temperature {
                try container.encode(temperature, forKey: .temperature)
            }
            if let topP {
                try container.encode(topP, forKey: .topP)
            }
            if let n {
                try container.encode(n, forKey: .n)
            }
            try container.encode(stream, forKey: .stream)
            
            if !stops.isEmpty {
                try container.encode(stops, forKey: .stop)
            }
            
            if let maxTokens {
                try container.encode(maxTokens, forKey: .maxTokens)
            }
            if let maxCompletionTokens {
                try container.encode(maxCompletionTokens, forKey: .maxCompletionTokens)
            }

            if let presencePenalty {
                try container.encode(presencePenalty, forKey: .presencePenalty)
            }

            if let frequencyPenalty {
                try container.encode(frequencyPenalty, forKey: .frequencyPenalty)
            }

            if !logitBias.isEmpty {
                try container.encode(logitBias, forKey: .logitBias)
            }
            
            try container.encodeIfPresent(user, forKey: .user)
            try container.encodeIfPresent(reasoningEffort, forKey: .reasoningEffort)
            try container.encodeIfPresent(promptCacheKey, forKey: .promptCacheKey)
            try container.encodeIfPresent(promptCacheRetention, forKey: .promptCacheRetention)
        }
    }
}

/// How much hidden reasoning a reasoning model (gpt-5 family, grok reasoner,
/// o-series) does before answering. Lower effort means the first visible
/// token arrives sooner and costs less.
/// - `off` (wire value "none") disables reasoning tokens entirely; supported
///   on gpt-5.1 and later, the replacement for classic non-reasoning models.
/// - `minimal` is the floor for the original gpt-5 family (nano/mini/gpt).
/// - xAI reasoners accept `low`/`high`.
public enum ReasoningEffort: String, Encodable, Sendable {
    case off = "none"
    case minimal
    case low
    case medium
    case high
}

/// OpenAI prompt cache lifetime. Caching itself is automatic for prompts of
/// 1024+ tokens; `extended` keeps cached prefixes up to 24h instead of a few
/// minutes. OpenAI-only: other providers may reject the field.
public enum PromptCacheRetention: String, Encodable, Sendable {
    case inMemory = "in_memory"
    case extended = "24h"
}
