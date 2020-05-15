# Combine WebSocket wrappers

iOS 13, macOS 10.15, tvOS 13 and watchOS 6 came with the amazing new framework Combine, an Apple implementation of Reactive Streams with deep integration in the foundation classes, such as `URLSession`.

These new versions of the platforms also came with a new `URLSessionWebSocketTask`, allowing us to use natively WebSockets without having to import external dependencies or deal with complex C APIs for the first time.

A websocket is basically a pub/sub protocol, and Combine is basically a pub/sub framework, so we should expect them to be dancing the same song, together, right?

Unfortunately, up to now Apple didn't implement Combine wrappers for `URLSessionWebSocketTask`, although it would make a lot of sense. We expect that sooner or later this will happen, hopefully sooner, but for those hunger for that it shouldn't be so hard to implement that thanks to the very powerful extensibility of Combine.

This library implements basic WebSocket functionality using Combine.

## Usage:

```swift
open class BypassCertificateValidation: NSObject, URLSessionDelegate {
    open func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        }
    }
}

let bypass = BypassCertificateValidation()
let session = URLSession(configuration: .default, delegate: bypass, delegateQueue: .main)
let urlRequest = URLRequest(url: URL(string: "wss://10.0.1.24:47367/myEndpoint")!)

// Create the WebSocket instance. This is the entry-point for sending and receiving messages
let webSocket = session.webSocket(with: urlRequest)

// Subscribe to the WebSocket. This will connect to the remote server and start listening
// for messages (URLSessionWebSocketTask.Message).
// URLSessionWebSocketTask.Message is an enum for either Data or String
let c0 = webSocket
    .publisher
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) } )

// You can optionally ping. This is a future of Void, it completes with success if it's
// reaching the remote server.
let c1 = webSocket.ping()
    .sink(receiveCompletion: { print($0) }, receiveValue: { _ in print("ping") })

// You can optionally keep pinging every 3 seconds. This is a Publisher of Void, if sends
// Void every successful ping or completes at the first failure
let c2 = webSocket.startPinging(every: 3)
    .sink(receiveCompletion: { print($0) }, receiveValue: { _ in print("ping") })

// You can send Data. This is a future of Void, it completes with success if it's
// message was sent without error.
let c3 = webSocket.send(Data()).sink(receiveCompletion: { print($0) }, receiveValue: { print($0) } )

// You can send String. This is a future of Void, it completes with success if it's
// message was sent without error.
let c4 = webSocket.send("Some Message").sink(receiveCompletion: { print($0) }, receiveValue: { print($0) } )

DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
    // You can stop pinging
    c2.cancel()

    // You can stop the WebSocket subscription, disconnecting from remote server.
    c0.cancel()
}

PlaygroundPage.current.needsIndefiniteExecution = true
```

## Installation:

```swift
.package(url: "https://github.com/teufelaudio/CombineWebSocket.git", .branch("master"))
```
