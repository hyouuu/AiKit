import Foundation

#if !os(Linux)
struct URLSessionRequestHandler: RequestHandler {
    let session: URLSession
    let configuration: Configuration
    let decoder: JSONDecoder
    
    init(
        session: URLSession,
        configuration: Configuration,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.configuration = configuration
        self.decoder = decoder
    }
    
    func perform<T>(request: Request) async throws -> T where T : Decodable {
        let urlRequest = try makeUrlRequest(request: request)
        let (data, _) = try await session.data(for: urlRequest)
        decoder.keyDecodingStrategy = request.keyDecodingStrategy
        decoder.dateDecodingStrategy = request.dateDecodingStrategy
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw try decoder.decode(APIErrorResponse.self, from: data)
        }
    }
    
    func stream<T>(request: Request) async throws -> AsyncThrowingStream<T, Error> where T : Decodable & Sendable {
        let urlRequest = try makeUrlRequest(request: request)
        let finalRequest: URLRequest = {
            var request = urlRequest
            request.timeoutInterval = 25
            return request
        }()
        
        // Use a local decoder to avoid crossing concurrency domains with self.decoder
        let localDecoder = JSONDecoder()
        localDecoder.keyDecodingStrategy = request.keyDecodingStrategy
        localDecoder.dateDecodingStrategy = request.dateDecodingStrategy
        
        return AsyncThrowingStream<T, Error> { @Sendable [localDecoder] continuation in
            Task(priority: .userInitiated) {
                do {
                    let (bytes, _) = try await session.bytes(for: finalRequest)
                    for try await buffer in bytes.lines {
                        let components = buffer.components(separatedBy: "data: ")
                            .filter { $0 != "data: " }
                        // Process sequentially to keep ordering and avoid data races
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
    
    private func makeUrlRequest(request: Request) throws -> URLRequest {
        let urlString = try request.generateURL(configuration)
        guard let url = URL(string: urlString) else {
            throw RequestHandlerError.invalidURLGenerated
        }
        var urlRequest = URLRequest(url: url)
        for (key, value) in configuration.headers {
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        for (key, value) in request.headers {
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        return urlRequest
    }
}
#endif
