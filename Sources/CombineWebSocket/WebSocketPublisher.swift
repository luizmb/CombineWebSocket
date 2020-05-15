import Combine
import Foundation

public struct WebSocketPublisher {
    private let task: URLSessionWebSocketTaskProtocol

    public init(task: URLSessionWebSocketTaskProtocol) {
        self.task = task
    }
}

extension WebSocketPublisher: Publisher {
    public typealias Output = URLSessionWebSocketTask.Message
    public typealias Failure = Error

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = Subscription(subscriber: subscriber, task: task)
        subscriber.receive(subscription: subscription)
    }
}

extension WebSocketPublisher {
    private class Subscription<SubscriberType: Subscriber>: NSObject, Combine.Subscription
    where SubscriberType.Input == Output, SubscriberType.Failure == Failure {
        private var buffer: DemandBuffer<SubscriberType>?
        private let task: URLSessionWebSocketTaskProtocol

        // We need a lock to update the state machine of this Subscription
        private let lock = NSRecursiveLock()
        // The state machine here is only a boolean checking if the websocket is subscribed or not
        // If should start browsing when there's demand for the first time (not necessarily on subscription)
        // Only demand starts the side-effect, so we have to be very lazy and postpone the side-effects as much as possible
        private var started: Bool = false

        init(subscriber: SubscriberType, task: URLSessionWebSocketTaskProtocol) {
            self.task = task
            self.buffer = DemandBuffer(subscriber: subscriber)
            super.init()
        }

        public func request(_ demand: Subscribers.Demand) {
            guard let buffer = self.buffer else { return }

            lock.lock()

            if !started && demand > .none {
                // There's demand, and it's the first demanded value, so we start browsing
                started = true
                lock.unlock()

                start()
            } else {
                lock.unlock()
            }

            // Flush buffer
            // If subscriber asked for 10 but we had only 3 in the buffer, it will return 7 representing the remaining demand
            // We actually don't care about that number, as once we buffer more items they will be flushed right away, so simply ignore it
            _ = buffer.demand(demand)
        }

        public func cancel() {
            buffer = nil
            started = false
            stop()
        }

        private func start() {
            startReceiving()
            task.resume()
        }

        private func stop() {
            task.cancel(with: .normalClosure, reason: nil)
            buffer?.complete(completion: .finished)
        }

        private func startReceiving() {
            task.receive { [weak self] result in
                guard let self = self else { return }

                switch result {
                case let .success(message):
                    _ = self.buffer?.buffer(value: message)
                    self.startReceiving()
                case let .failure(error):
                    self.buffer?.complete(completion: .failure(error))
                }
            }
        }
    }
}
