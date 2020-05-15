import Foundation

extension URLSessionWebSocketTaskProtocol {
    var publisher: WebSocketPublisher {
        .init(task: self)
    }
}
