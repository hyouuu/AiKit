//
//  ModelProviders.swift
//  AiKit
//
//  Created by hyouuu on 2/17/25.
//

public enum AiProvider: String, Sendable {
    case openAI, xAI, deepSeek, anthropic //, google

    public var api: AiKit.API? {
        switch self {
            case .openAI: return nil
            case .xAI: return API(scheme: .https, host: "api.x.ai")
            case .deepSeek: return API(scheme: .https, host: "api.deepseek.com")
            case .anthropic: return API(scheme: .https, host: "api.anthropic.com")
//            case .google: return API(scheme: .https, host: "generativelanguage.googleapis.com/v1beta/openai")
        }
    }

    public var chatModel: ModelId {
        switch self {
            case .openAI: Model.openAI.gpt
            case .xAI: Model.xAI.grok
            case .deepSeek: Model.deepSeek.chat
            case .anthropic: Model.anthropic.haiku
//            case .google: Model.deepSeek.chat
        }
    }

    public var reasoningModel: ModelId {
        switch self {
            case .openAI: Model.openAI.gptMini
            case .xAI: Model.xAI.grokReasoner
            case .deepSeek: Model.deepSeek.chat
            case .anthropic: Model.anthropic.sonnet
//            case .google: Model.deepSeek.chat
        }
    }
}
