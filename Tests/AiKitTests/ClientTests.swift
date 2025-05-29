import XCTest
import NIOPosix
import AsyncHTTPClient
@testable import AiKit

final class ClientTests: XCTestCase {

    private var httpClient: HTTPClient!
    private var client: Client!
    
    override func setUp() {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        
        let configuration = Configuration(apiKey: AiProvider.openAI.apiKey, api: AiProvider.openAI.api)
//        let configuration = Configuration(apiKey: AiProvider.xAI.apiKey, api: AiProvider.xAI.api)
//        let configuration = Configuration(apiKey: AiProvider.deepSeek.apiKey, api: AiProvider.deepSeek.api)

        client = Client(
            httpClient: httpClient,
            configuration: configuration
        )
    }
    
    override func tearDownWithError() throws {
        try httpClient.syncShutdown()
    }

    func test_createChat() async throws {
        print("start createChat")
        let completion = try await client.chats.create(
            model: Model.openAI.gpt,
//            model: Model.openAI.o4,
//            model: Model.xAI.grok,
//            model: Model.deepSeek.chat,
//            model: Model.deepSeek.reasoner,
            messages: [ .user(content: "Write a haiki") ]
        )
        
        print(completion)
    }

    func test_createChatStream() async throws {
        print("start createChatStream")
        let stream = try await client.chats.stream(
            model: Model.openAI.gpt,
            messages: [
                .user(content: "Write a haiki")
            ]
        )
        
        for try await chat in stream {
            if let message = chat.choices.first?.delta.content {
                print(message)
            }
        }        
    }

    /*
    func test_completion() async throws {
        let messages: [Chat.Message] = [
            .system(content: "You are a fairytale storyteller. Create a fairytale about the subject in the next message under 100 words."),
            .user(content: "a happy wolf in the forrest")
        ]

        let completion = try await client.chats.create(
            model: Model.openAI.gpt,
            messages: messages
        )

        print(completion)
    }
     */

    /*

    func test_createModeration() async throws {
        let moderation = try await client.moderations.createModeration(input: "I want to kill them.")

        print(moderation)
    }

    func test_listModels() async throws {
        let models = try await client.models.list()
        print(models)
    }

    func test_retrieveModel() async throws {
        let models = try await client.models.retrieve(id: Model.GPT3.davinci.id)
        print(models)
    }

    func test_error() async throws {
        do {
           _ = try await client.files.retrieve(id: "NOT-VALID-ID")
        } catch {
           print(error)
        }
    }

    func test_createEdit() async throws {
        let edit = try await client.edits.create(
            input: "Whay day of the wek is it?",
            instruction: "Fix the spelling mistakes"
        )
        
        print(edit)
    }

    func test_createImage() async throws {
        let image = try await client.images.create(prompt: "Tiger Woods eating soup")
        
        print(image)
    }
    
    func test_createEditImage() async throws {
        let url = Bundle.module.url(forResource: "logo", withExtension: "png")!
        
        let data = try Data(contentsOf: url)
        
        let image = try await client.images.createEdit(
            image: data,
            mask: data,
            prompt: "Change background color to blue"
        )
        
        print(image)
    }
    
    func test_createImageVariation() async throws {
        let url = Bundle.module.url(forResource: "logo", withExtension: "png")!
        
        let data = try Data(contentsOf: url)
        
        let image = try await client.images.createVariation(image: data)
        
        print(image)
    }
    
    func test_createEmbedding() async throws {
        let embedding = try await client.embeddings.create(input: "he food was delicious and the waiter...")
        
        print(embedding)
    }
    
    func test_listFiles() async throws {
        let files = try await client.files.list()
        
        print(files)
    }
    
    func test_file_uploadRetrieveDelete() async throws {
        let url = Bundle.module.url(forResource: "example", withExtension: "jsonl")!
        
        let data = try Data(contentsOf: url)
        
        let uploadedFile = try await client.files.upload(
            file: data,
            fileName: "\(UUID().uuidString).jsonl",
            purpose: .fineTune
        )
        
        let retrievedFile = try await client.files.retrieve(id: uploadedFile.id)
        
        let _: SingleLineJSONL = try await client.files.retrieveFileContent(id: retrievedFile.id)
        
        let response = try await client.files.delete(id: retrievedFile.id)
                
        XCTAssertEqual(response.id, retrievedFile.id)
    }

    func test_createTranscription() async throws {
        let url = Bundle.module.url(forResource: "9000", withExtension: "mp3")!
        
        let data = try Data(contentsOf: url)
        
        let transcription = try await client.audio.transcribe(
            file: data,
            fileName: "9000.mp3",
            mimeType: .mpeg,
            language: .english
        )
        
        print(transcription)
    }
    
    func test_createTranslation() async throws {
        let url = Bundle.module.url(forResource: "cena", withExtension: "mp3")!
        
        let data = try Data(contentsOf: url)
        
        let translation = try await client.audio.translate(
            file: data,
            fileName: "cena.mp3",
            mimeType: .mpeg
        )
        
        print(translation)
    }
     */
}
