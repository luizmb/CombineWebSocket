import Combine
import Foundation

public class WebSocketSubscriber: Subscriber {
    public typealias Input = Result<URLSessionWebSocketTask.Message, Error>
    public typealias Failure = Never

    var subscription: WebSocketSubscription?
    private let subscriber: AnySubscriber<Input, Failure>

    public init(
        onString: @escaping (String) -> Void = { _ in },
        onData: @escaping (Data) -> Void = { _ in },
        onError: @escaping (Error) -> Void = { _ in },
        onCompletion: @escaping () -> Void = { }
    ) {
        let sinkSubscriber = Subscribers.Sink<Result<URLSessionWebSocketTask.Message, Error>, Never>(
            receiveCompletion: { _ in
                onCompletion()
            },
            receiveValue: { result in
                switch result {
                case let .failure(error): onError(error)
                case let .success(.string(string)): onString(string)
                case let .success(.data(data)): onData(data)
                case .success: fatalError()
                }
            }
        )
        subscriber = .init(sinkSubscriber)
    }

    public func receive(subscription: Subscription) {
        guard let wsSubscription = subscription as? WebSocketSubscription else {
            return
        }

        self.subscription = wsSubscription
        subscriber.receive(subscription: subscription)
    }

    public func receive(_ input: Result<URLSessionWebSocketTask.Message, Error>) -> Subscribers.Demand {
        subscriber.receive(input)
    }

    public func receive(completion: Subscribers.Completion<Never>) {
        subscriber.receive(completion: completion)
    }
}
