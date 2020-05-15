import Combine
import Foundation

public class WebSocket {
    private let task: URLSessionWebSocketTaskProtocol

    init(task: URLSessionWebSocketTaskProtocol) {
        self.task = task
    }

    public var publisher: WebSocketPublisher {
        task.publisher
    }

    public func send(_ string: String) -> Future<Void, Error> {
        Future { completion in
            self.task.send(.string(string)) { maybeError in
                completion(maybeError.map(Result.failure) ?? .success(()))
            }
        }
    }

    public func send(_ data: Data) -> Future<Void, Error> {
        Future { completion in
            self.task.send(.data(data)) { maybeError in
                completion(maybeError.map(Result.failure) ?? .success(()))
            }
        }
    }

    public func ping() -> Future<Void, Error> {
        Future { completion in
            self.task.sendPing { maybeError in
                completion(maybeError.map(Result.failure) ?? .success(()))
            }
        }
    }

    public func startPinging(every: TimeInterval) -> AnyPublisher<Void, Error> {
        Timer
            .publish(every: every, on: .main, in: .common)
            .autoconnect()
            .mapError { _ -> Error in }
            .flatMap(maxPublishers: .max(1)) { _ -> AnyPublisher<Void, Error> in
                self.ping().eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
