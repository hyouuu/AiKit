import Foundation

public struct APIError: Error, Decodable {
    public let message: String
    public let type: String
    public let param: String?
    public let code: String?
}

public struct APIErrorResponse: Error, Decodable {
    public let error: APIError
}

/// Non-2xx response from a provider. Providers disagree on the error body
/// (OpenAI nests `error.message`, xAI sends `error` as a string), so the raw
/// body is kept alongside a best-effort message.
public struct ProviderHTTPError: Error, LocalizedError, Sendable {
    public let status: Int
    public let body: String

    public init(status: Int, body: String) {
        self.status = status
        self.body = body
    }

    public var message: String {
        guard let data = body.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return String(body.prefix(300)) }
        if let error = json["error"] as? [String: Any], let message = error["message"] as? String {
            return message
        }
        if let error = json["error"] as? String {
            return error
        }
        if let message = json["message"] as? String {
            return message
        }
        return String(body.prefix(300))
    }

    public var errorDescription: String? {
        "HTTP \(status): \(message)"
    }
}
