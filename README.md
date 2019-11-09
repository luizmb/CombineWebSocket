# Combine WebSocket wrappers

iOS 13, macOS 10.15, tvOS 13 and watchOS 6 came with the amazing new framework Combine, an Apple implementation of Reactive Streams with deep integration in the foundation classes, such as `URLSession`.

These new versions of the platforms also came with a new `URLSessionWebSocketTask`, allowing us to use natively WebSockets without having to import external dependencies or deal with complex C APIs for the first time.

A websocket is basically a pub/sub protocol, and Combine is basically a pub/sub framework, so we should expect them to be dancing the same song, together, right?

Unfortunately, up to now Apple didn't implement Combine wrappers for `URLSessionWebSocketTask`, although it would make a lot of sense. We expect that sooner or later this will happen, hopefully sooner, but for those hunger for that it shouldn't be so hard to implement that thanks to the very powerful extensibility of Combine.

This first implementation uses the `WebSocketSubscription` to keep the subscription alive and also to send messages or start pinging. Probably it would be better to create a dedicated class for that with multiple publishers for messages and also connectivity delegates, but for now let's start simple and make this thing a bit useful.

```
let urlRequest = makeURLRequest()
let webSocket = WebSocketPublisher(request: urlRequest, session: URLSession.shared)
    .start(
        onString: { print("Got string: \($0)") },
        onData: { print("Got data: \(String(data: $0, encoding: .utf8)!)") },
        onError: { print("Got error: \($0)") },
        onCompletion: { print("Done") }
    )

webSocket.send("Send and forget")

webSocket.send("Send and check for errors").sink(
    receivedCompletion: { result in
        print("Sending result: \(result)")
    },
    receivedValue: { _ in },
)

webSocket.send(Data())

webSocket.ping()

webSocket.startPinging(every: 5)
```