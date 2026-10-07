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
            ),
            deadline: .now() + .seconds(180)
        ).get()

        guard (200..<300).contains(response.status.code) else {
            let errorBody = response.body.map { String(buffer: $0) } ?? ""
            throw ProviderHTTPError(status: Int(response.status.code), body: errorBody)
        }

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

        decoder.keyDecodingStrategy = request.keyDecodingStrategy
        decoder.dateDecodingStrategy = request.dateDecodingStrategy

        let response = try await httpClient.execute(httpClientRequest, timeout: .seconds(25))

        guard (200..<300).contains(response.status.code) else {
            let errorBody = (try? await response.body.collect(upTo: 64 * 1024)).map { String(buffer: $0) } ?? ""
            throw ProviderHTTPError(status: Int(response.status.code), body: errorBody)
        }

        return AsyncThrowingStream<T, Error> { @Sendable continuation in
            let task = Task(priority: .userInitiated) {
                do {
                    var leftover = Data()

                    func processLine(_ lineData: Data) {
                        guard let line = String(data: lineData, encoding: .utf8) else { return }
                        let components = line.components(separatedBy: "data: ")
                            .filter { $0 != "data: " }
                        for component in components {
                            guard let data = component.data(using: .utf8),
                                  let value = try? self.decoder.decode(T.self, from: data) else {
                                continue
                            }
                            continuation.yield(value)
                        }
                    }

                    for try await buffer in response.body {
                        try Task.checkCancellation()
                        leftover.append(Data(buffer: buffer))

                        while let nlIdx = leftover.firstIndex(of: 0x0A) {
                            let lineData = leftover.subdata(in: leftover.startIndex..<nlIdx)
                            leftover.removeSubrange(leftover.startIndex...nlIdx)
                            processLine(lineData)
                        }
                    }

                    if !leftover.isEmpty {
                        processLine(leftover)
                    }
                    continuation.finish()
                } catch is CancellationError {
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
}
