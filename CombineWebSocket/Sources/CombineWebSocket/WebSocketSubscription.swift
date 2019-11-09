//
//  WebSocketSubscription.swift
//  
//
//  Created by Luiz Rodrigo Martins Barbosa on 09.11.19.
//

import Combine
import Foundation

public class WebSocketSubscription: Subscription {
    private let subscriber: AnySubscriber<Result<URLSessionWebSocketTask.Message, Error>, Never>
    private let task: URLSessionWebSocketTaskProtocol
    private var published: Int = 0
    private var demand: Subscribers.Demand = .none

    init<S: Subscriber>(subscriber: S, task: URLSessionWebSocketTaskProtocol)
        where S.Input == Result<URLSessionWebSocketTask.Message, Error>, S.Failure == Never {
        self.subscriber = .init(subscriber)
        self.task = task
    }

    public func request(_ demand: Subscribers.Demand) {
        self.demand = demand
        guard self.demand > published else { return }

        task.resume()
        startReceiving()
    }

    public func cancel() {
        task.cancel(with: .goingAway, reason: nil)
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
        Swift.print("ping 1")
        return Future { completion in
            Swift.print("ping 2")
            return self.task.sendPing { maybeError in
                Swift.print("ping 3")
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

    private func startReceiving() {
        task.receive { [weak self] result in
            guard let self = self else { return }
            self.startReceiving()
            self.publishIfDemand(result: result)
        }
    }

    private func publishIfDemand(result: Result<URLSessionWebSocketTask.Message, Error>) {
        DispatchQueue.main.async {
            guard self.demand > self.published else { return }
            self.published += 1

            self.demand += self.subscriber.receive(result)
        }
    }
}
