import AsyncHTTPClient
import NIOHTTP1
import Foundation

public protocol Request: Sendable {
    var method: HTTPMethod { get }
    var scheme: API.Scheme { get }
    var host: String { get }
    var path: String { get }
    var body: Data? { get }
    var headers: HTTPHeaders { get }
    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { get }
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get }
}

extension Request {
    static var encoder: JSONEncoder { .requestEncoder }

    var scheme: API.Scheme { .https }
    var host: String { "api.openai.com" }
    var body: Data? { nil }
    
    var headers: HTTPHeaders {
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: "application/json")
        return headers
    }
    
    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { .convertFromSnakeCase }
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { .secondsSince1970 }

    func generateURL(_ configuration: Configuration) throws -> String {
        var components = URLComponents()
        components.scheme = configuration.api?.scheme.value ?? scheme.value
        components.host = configuration.api?.host ?? host
        components.path = [configuration.api?.path, path]
            .compactMap { $0 }
            .joined()

        guard let url = components.url else {
            throw RequestHandlerError.invalidURLGenerated
        }

        return url.absoluteString
    }
}

extension JSONEncoder {
    static var requestEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}
