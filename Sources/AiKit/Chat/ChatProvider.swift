public struct ChatProvider: Sendable {
    
    private let requestHandler: RequestHandler
    
    init(requestHandler: RequestHandler) {
        self.requestHandler = requestHandler
    }
    
    /**
     Create chat completion
     POST
      
     https://api.openai.com/v1/chat/completions

     Creates a chat completion for the provided prompt and parameters
     */
    public func create(
        model: ModelId,
        messages: [Chat.Message] = [],
        temperature: Double? = nil,
        topP: Double? = nil,
        n: Int? = nil,
        stops: [String] = [],
        maxTokens: Int? = nil,
        maxCompletionTokens: Int? = nil,
        presencePenalty: Double? = nil,
        frequencyPenalty: Double? = nil,
        logitBias: [String : Int] = [:],
        user: String? = nil,
        reasoningEffort: ReasoningEffort? = nil,
        promptCacheKey: String? = nil,
        promptCacheRetention: PromptCacheRetention? = nil
    ) async throws -> Chat {
        
        let request = try CreateChatRequest(
            model: model.id,
            messages: messages,
            temperature: temperature,
            topP: topP,
            n: n,
            stream: false,
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
    
        return try await requestHandler.perform(request: request)

    }
    
    /**
     Create chat completion
     POST
      
     https://api.openai.com/v1/chat/completions

     Creates a chat completion for the provided prompt and parameters
     
     stream If set, partial message deltas will be sent, like in ChatGPT.
     Tokens will be sent as data-only server-sent events as they become available, with the stream terminated by a data: [DONE] message.
     
     https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#event_stream_format
     */
    public func stream(
        model: ModelId,
        messages: [Chat.Message] = [],
        temperature: Double? = nil,
        topP: Double? = nil,
        n: Int? = nil,
        stops: [String] = [],
        maxTokens: Int? = nil,
        maxCompletionTokens: Int? = nil,
        presencePenalty: Double? = nil,
        frequencyPenalty: Double? = nil,
        logitBias: [String : Int] = [:],
        user: String? = nil,
        reasoningEffort: ReasoningEffort? = nil,
        promptCacheKey: String? = nil,
        promptCacheRetention: PromptCacheRetention? = nil,
        includeUsage: Bool = false
    ) async throws -> AsyncThrowingStream<ChatStream, Error> {
        
        let request = try CreateChatRequest(
            model: model.id,
            messages: messages,
            temperature: temperature,
            topP: topP,
            n: n,
            stream: true,
            stops: stops,
            maxTokens: maxTokens,
            maxCompletionTokens: maxCompletionTokens,
            presencePenalty: presencePenalty,
            frequencyPenalty: frequencyPenalty,
            logitBias: logitBias,
            user: user,
            reasoningEffort: reasoningEffort,
            promptCacheKey: promptCacheKey,
            promptCacheRetention: promptCacheRetention,
            includeUsage: includeUsage
        )
    
        return try await requestHandler.stream(request: request)
                
    }
}
