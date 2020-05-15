import Foundation

extension URLSession {
    public func webSocket(with url: URL) -> WebSocket {
        WebSocket(task: webSocketTask(with: url))
    }

    public func webSocket(with urlRequest: URLRequest) -> WebSocket {
        WebSocket(task: webSocketTask(with: urlRequest))
    }

    public func webSocket(with url: URL, protocols: [String]) -> WebSocket {
        WebSocket(task: webSocketTask(with: url, protocols: protocols))
    }
}
