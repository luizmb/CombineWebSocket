import Combine
import Foundation

public struct WebSocketPublisher: Publisher {
    public typealias Output = Result<URLSessionWebSocketTask.Message, Error>
    public typealias Failure = Never
    private let startTask: () -> URLSessionWebSocketTaskProtocol

    public init<Session: WebSocketSessionProtocol>(request: URLRequest, session: Session) {
        self.startTask = { session.webSocketTask(with: request) }
    }

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let task = startTask()
        let subscription = WebSocketSubscription(subscriber: subscriber, task: task)
        subscriber.receive(subscription: subscription)
    }
}

extension Publisher where Output == Result<URLSessionWebSocketTask.Message, Error>, Failure == Never {
    public func start(
        onString: @escaping (String) -> Void = { _ in },
        onData: @escaping (Data) -> Void = { _ in },
        onError: @escaping (Error) -> Void = { _ in },
        onCompletion: @escaping () -> Void = { }
    ) -> WebSocketSubscription {
        let wsSubscriber = WebSocketSubscriber(onString: onString, onData: onData, onError: onError, onCompletion: onCompletion)
        self.subscribe(wsSubscriber)
        return wsSubscriber.subscription!
    }
}
