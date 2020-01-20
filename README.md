[![Mihael Isaev](https://user-images.githubusercontent.com/1272610/72756525-ee045680-3be6-11ea-8a15-49414a453f8f.png)](http://mihaelisaev.com)

<p align="center">
    <a href="LICENSE">
        <img src="https://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://swift.org">
        <img src="https://img.shields.io/badge/swift-5.1-brightgreen.svg" alt="Swift 5.1">
    </a>
</p>
<br>
Receive & send websocket messages through convenient observers. Even multiple observers on different endpoints!

> 💡Types of observers: Classic, Declarative, Bindable. Read about all of them below.

Built for Vapor4.
> 💡Vapor3 version is available in `vapor3` branch and from `1.0.0` tag

If you have great ideas of how to improve this package write me (@iMike#3049) in [Vapor's discord chat](http://vapor.team) or just send pull request.

### Install through Swift Package Manager

Edit your `Package.swift`

```swift
//add this repo to dependencies
.package(url: "https://github.com/MihaelIsaev/AwesomeWS.git", from: "2.0.0")
//and don't forget about targets
.target(name: "App", dependencies: ["Vapor", "WS"]),
```

### How it works ?

### Declarative observer

WS lib have `.default` WSID which represents `DeclarativeObserver`.
> 💡You can declare your own WSID with another type of observer and your custom class.

You can start working with it this easy way
```swift
app.ws.build(.default).serve()
```
In this case it will start listening for websocket connections at `/`, but you can change it before you call `.serve()`
```swift
app.ws.build(.default).at("ws").serve()
```
Ok now it is listening at `/ws`

Also you can protect your websocket endpoint with middlewares, e.g. you can check auth before connection will be established.
```swift
app.ws.build(.default).at("ws").middlewares(AuthMiddleware()).serve()
```
Ok, looks good, but how to handle incoming data?

As we use `.default` WSID which represents `Declarative` observer we can handle incoming data like this
```swift
app.ws.build(.default).at("ws").middlewares(AuthMiddleware()).serve().onOpen { client in
    print("client just connected \(client.id)")
}.onText { client, text in
    print("client \(client.id) text: \(text)")
}
```
there are also available: `onClose`, `onPing`, `onPong`, `onBinary`, `onByteBuffer` handlers.
> 💡Set `app.logger.logLevel = .info` or `app.logger.logLevel = .debug` to see more info about connections

### Classic observer
You should create new class which inherit from `ClassicObserver`
```swift
import WS

class MyClassicWebSocket: ClassicObserver {
    override func on(open client: AnyClient) {}
    override func on(close client: AnyClient) {}

    override func on(text: String, client: AnyClient) {}
    /// also you can override: `on(ping:)`, `on(pong:)`, `on(binary:)`, `on(byteBuffer:)`
}
```
and you must declare a WSID for it
```swift
extension WSID {
    static var myClassic: WSID<MyClassicWebSocket> { .init() }
}
```
so then start serving it
```swift
app.ws.build(.myClassic).at("ws").serve()
```

### Bindable observer

This kind of observer designed to send and receive events in special format, e.g. in JSON:
```json
{ "event": "<event name>", "payload": <anything> }
```
or just
```json
{ "event": "<event name>" }
```
> 💡By default lib uses `JSONEncoder` and `JSONDecoder`, but you can replace them with anything else in `setup` method.

First of all declare any possible events in `EID` extension like this
```swift
struct Hello: Codable {
  let firstName, lastName: String
}
struct Bye: Codable {
  let firstName, lastName: String
}
extension EID {
    static var hello: EID<Hello> { .init("hello") }
    static var bye: EID<Bye> { .init("bye") }
    // Use `EID<Nothing>` if you don't want any payload
}
```

Then create your custom bindable observer class
```swift
class MyBindableWebsocket: BindableObserver {
    // register all EIDs here
    override func setup() {
        bind(.hello, hello)
        bind(.bye, bye)
        // optionally setup here custom encoder/decoder
        encoder = JSONEncoder() // e.g. with custom `dateEncodingStrategy`
        decoder = JSONDecoder() // e.g. with custom `dateDecodingStrategy`
    }

    // hello EID handler
    func hello(client: AnyClient, payload: Hello) {
        print("Hello \(payload.firstName) \(payload.lastName)")
    }

    // bye EID handler
    func bye(client: AnyClient, payload: Bye) {
        print("Bye \(payload.firstName) \(payload.lastName)")
    }
}
```
declare a WSID
```swift
extension WSID {
    static var myBindable: WSID<MyBindableWebsocket> { .init() }
}
```
then start serving it
```swift
app.ws.build(.myBindable).at("ws").serve()
```
> 💡Here you also could provide custom encoder/decoder
>  e,g, `app.ws.build(.myBindable).at("ws").encoder(JSONEncoder()).encoder(JSONDecoder()).serve()`

### How to send data

Data sending works through `Sendable` protocol, which have several methods
```swift
.send(text: <StringProtocol>) // send message with text
.send(bytes: <[UInt8]>) // send message with bytes
.send(data: <Data>) // send message with binary data
.send(model: <Encodable>) // send message with Encodable model
.send(model: <Encodable>, encoder: Encoder)
.send(event: <EID>) // send bindable event
.send(event: <EID>, payload: T?)
```
> all these methods returns `EventLoopFuture<Void>`

Using methods listed above you could send messages to one or multiple clients.

#### To one client e.g. in `on(open:)` or `on(text:)`
```swift
client.send(...)
```

#### To all clients
```swift
client.broadcast.send(...)
client.broadcast.exclude(client).send(...) // excluding himself
req.ws(.mywsid).broadcast.send(...)
```

#### To clients in channels
```swift
client.broadcast.channels("news", "updates").send(...)
req.ws(.mywsid).broadcast.channels("news", "updates").send(...)
```

#### To custom filtered clients
e.g. you want to find all ws connections of the current user to send a message to all his devices
```swift
req.ws(.mywsid).broadcast.filter { client in
    req.headers[.authorization].first == client.originalRequest.headers[.authorization].first
}.send(...)
```

### Broadcast

You could reach `broadcast` obejct on `app.ws.observer(.mywsid)` or `req.ws(.mywsid).broadcast` or `client.broadcast`.

This object is a builder, so using it you should filter recipients like this `client.broadcast.one(...).two(...).three(...).send()`

Available methods
```swift
.encoder(Encoder) // set custom data encoder
.exclude([AnyClient]) // exclude provided clients from clients
.filter((AnyClient) -> Bool) // filter clients by closure result
.channels([String]) // filter clients by provided channels
.subscribe([String]) // subscribe filtered clients to channels
.unsubscribe([String]) // unsubscribe filtered clients from channels
.disconnect() // disconnect filtered clients
.send(...) // send message to filtered clients
.count // number of filtered clients
```

### Channels

#### Subscribe
```swift
client.subscribe(to: ...) // will subscribe client to provided channels
```
To subscribe to `news` and `updates` call it like this `client.subscribe(to: "news", "updates")`

#### Unsubscribe
```swift
client.unsubscribe(from: ...) // will unsubscribe client from provided channels
```

#### List
```swift
client.channels // will return a list of client channels
```

### Defaults

If you have only one observer in the app you can set it as default. It will give you ability to use it without providing its WSID all the time, so you will call just `req.ws()` instead of `req.ws(.mywsid)`.
```swift
// configure.swift

app.ws.setDefault(.myBindable)
```
Also you can set custom encoder/decoder for all the observers
```swift
// configure.swift

let encoder = JSONEncoder()
encoder.dateEncodingStrategy = .secondsSince1970
app.ws.encoder = encoder

let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .secondsSince1970
app.ws.decoder = decoder
```

### Client

As you may see in every handler you always have `client` object. This object conforms to `AnyClient` protocol which contains useful things inside

**variables**
- `id` - UUID
- `originalRequest` - original `Request`
- `eventLoop` - next `EventLoop`
- `application` - pointer to `Application`
- `channels` - an array of channels that client subscribed to
- `logger` - pointer to `Logger`
- `observer` - this client's observer
- `sockets` - original socket connection of the client
- `exchangeMode` - client's observer exchange mode

**conformanses**
- `Sendable` - so you can use `.send(...)`
- `Subscribable` - so you can use `.subscribe(...)`, `.unsubscribe(...)`
- `Disconnectable` - so you can call `.disconnect()` to disconnect that user

Original request gives you ability to e.g. determine connected user:
```swift
let user = try client.originalRequest.requireAuthenticated(User.self)
```

## How to connect from iOS, macOS, etc?

You could use pure `URLSession` websockets functionality since iOS13, or for example you could use my [CodyFire lib](https://github.com/MihaelIsaev/CodyFire) or classic [Starscream lib](https://github.com/daltoniam/Starscream)

## How to connect from Android?

Use any lib which support pure websockets protocol, e.g. not SocketIO cause it uses its own protocol.

## Examples

There are no examples for Vapor 4 yet unfortunately.

## Contacts

Please feel free to contact me in Vapor's discord my nickname is `iMike#3049`

## Contribution

Feel free to contribute!
