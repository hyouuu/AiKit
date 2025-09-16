import AsyncHTTPClient
import NIO
import NIOHTTP1
import NIOFoundationCompat
import Foundation

struct NIORequestHandler: RequestHandler {
    let httpClient: HTTPClient
    let configuration: Configuration
    let decoder: JSONDecoder
    
    init(
        httpClient: HTTPClient,
        configuration: Configuration,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.httpClient = httpClient
        self.configuration = configuration
        self.decoder = decoder
    }
    
    func generateURL(for request: Request) throws -> String {
        var components = URLComponents()
        components.scheme = configuration.api?.scheme.value ?? request.scheme.value
        components.host = configuration.api?.host ?? request.host
        components.path = [configuration.api?.path, request.path]
            .compactMap { $0 }
            .joined()
            
        guard let url = components.url else {
            throw RequestHandlerError.invalidURLGenerated
        }
    
        return url.absoluteString
    }
    
    func perform<T: Decodable>(request: Request) async throws -> T {
        var headers = configuration.headers
        
        headers.add(contentsOf: request.headers)
        
        let url = try request.generateURL(configuration)

        let body: HTTPClient.Body? = {
            guard let data = request.body else { return nil }
            return .data(data)
        }()
        
        let response = try await httpClient.execute(
            request: HTTPClient.Request(
                url: url,
                method: request.method,
                headers: headers,
                body: body
            )
        ).get()
        
        
        guard let byteBuffer = response.body else {
            throw RequestHandlerError.responseBodyMissing
        }
        
        decoder.keyDecodingStrategy = request.keyDecodingStrategy
        decoder.dateDecodingStrategy = request.dateDecodingStrategy

        do {
            return try decoder.decode(T.self, from: byteBuffer)
        } catch {
            print(error.localizedDescription.debugDescription)
            throw try decoder.decode(APIErrorResponse.self, from: byteBuffer)
        }
    }
    
    func stream<T: Decodable & Sendable>(request: Request) async throws -> AsyncThrowingStream<T, Error> {
        
        let url = try request.generateURL(configuration)

        var httpClientRequest = HTTPClientRequest(url: url)
        
        httpClientRequest.headers.add(contentsOf: configuration.headers)
        httpClientRequest.headers.add(contentsOf: request.headers)
        
        httpClientRequest.method = request.method

        if let body = request.body {
            httpClientRequest.body = .bytes(body)
        }
        
        // Create a local decoder to avoid crossing concurrency domains with self.decoder
        let localDecoder = JSONDecoder()

        localDecoder.keyDecodingStrategy = request.keyDecodingStrategy
        localDecoder.dateDecodingStrategy = request.dateDecodingStrategy
        
        let response = try await httpClient.execute(httpClientRequest, timeout: .seconds(25))
        
        return AsyncThrowingStream<T, Error> { @Sendable [localDecoder] continuation in
            Task(priority: .userInitiated) {
                do {
                    for try await buffer in response.body {
                        let components = String(buffer: buffer)
                            .components(separatedBy: "data: ")
                            .filter { $0 != "data: " }
                        
                        // Process components sequentially to maintain order
                        for component in components {
                            guard let data = component.data(using: .utf8),
                                  let value = try? localDecoder.decode(T.self, from: data) else {
                                continue
                            }
                            continuation.yield(value)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

