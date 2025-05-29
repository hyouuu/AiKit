//
//  ModelProviders.swift
//  AiKit
//
//  Created by hyouuu on 2/17/25.
//

public enum AiProvider: String, Sendable {
    case openAI, xAI, deepSeek //, google

    public var api: AiKit.API? {
        switch self {
            case .openAI: return nil
            case .xAI: return API(scheme: .https, host: "api.x.ai")
            case .deepSeek: return API(scheme: .https, host: "api.deepseek.com")
//            case .google: return API(scheme: .https, host: "generativelanguage.googleapis.com/v1beta/openai")
        }
    }

    public var chatModel: ModelId {
        switch self {
            case .openAI: Model.openAI.gpt
            case .xAI: Model.xAI.grok
            case .deepSeek: Model.deepSeek.chat
//            case .google: Model.deepSeek.chat
        }
    }

    public var reasoningModel: ModelId {
        switch self {
            case .openAI: Model.openAI.o4
            case .xAI: Model.xAI.grok
            case .deepSeek: Model.deepSeek.reasoner
//            case .google: Model.deepSeek.reasoner
        }
    }
}
