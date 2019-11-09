//
//  URLSessionWebSocketTaskProtocol.swift
//  
//
//  Created by Luiz Rodrigo Martins Barbosa on 09.11.19.
//

import Foundation

public protocol URLSessionWebSocketTaskProtocol {
    func sendPing(pongReceiveHandler: @escaping (Error?) -> Void)
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping (Error?) -> Void)
    func receive(completionHandler: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void)
    func resume()
}

extension URLSessionWebSocketTask: URLSessionWebSocketTaskProtocol { }
