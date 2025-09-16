public struct ModerationProvider: Sendable {
    
    private let requestHandler: RequestHandler
    
    init(requestHandler: RequestHandler) {
        self.requestHandler = requestHandler
    }
    
    /**
     Create moderation
     POST
      
     https://platform.openai.com/docs/models/omni-moderation-latest
     
     Classifies if text violates OpenAI's Content Policy
     */
    public func createModeration(
        input: String,
        model: Moderation.Model = .stable
    ) async throws -> Moderation {
        
        let request = try CreateModerationRequest(
            input: input,
            model: model
        )

        return try await requestHandler.perform(request: request)
    }
}
