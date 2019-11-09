//
//  WebSocketSessionProtocol.swift
//  
//
//  Created by Luiz Rodrigo Martins Barbosa on 09.11.19.
//

import Foundation

public protocol WebSocketSessionProtocol {
    associatedtype Task: URLSessionWebSocketTaskProtocol
    func webSocketTask(with: URLRequest) -> Task
}

extension URLSession: WebSocketSessionProtocol { }
