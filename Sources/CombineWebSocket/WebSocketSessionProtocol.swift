import Foundation

public protocol WebSocketSessionProtocol {
    associatedtype Task: URLSessionWebSocketTaskProtocol
    func webSocketTask(with: URLRequest) -> Task
}

extension URLSession: WebSocketSessionProtocol { }
