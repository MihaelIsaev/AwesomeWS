[![Mihael Isaev](https://user-images.githubusercontent.com/1272610/50386554-68238c80-0702-11e9-88ad-965ebfd75812.png)](http://mihaelisaev.com)

<p align="center">
    <a href="LICENSE">
        <img src="https://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://swift.org">
        <img src="https://img.shields.io/badge/swift-4.2-brightgreen.svg" alt="Swift 4.2">
    </a>
    <a href="https://twitter.com/VaporRussia">
        <img src="https://img.shields.io/badge/twitter-VaporRussia-5AA9E7.svg" alt="Twitter">
    </a>
</p>
<br>

Receive & send websocket messages through convenient providers

**🚧 This project is under active development and API's and ideology may be changed or renamed until v1.0.0 🚧**

### Install through Swift Package Manager

Edit your `Package.swift`

```swift
//add this repo to dependencies
.package(url: "https://github.com/MihaelIsaev/WS.git", from: "0.10.0")
//and don't forget about targets
//"WS"
```

### Setup in configure.swift

```swift
import WS

let ws = WS(at: "ws", protectedBy: [someMiddleware1, someMiddleware2], delegate: SOME_CONTROLLER)
// ws.logger.level = .debug
services.register(ws, as: WebSocketServer.self)
```
Let's take a look at WS initializations params.
First param is path of endpoint where you'd like to listen for websocket connection, in this example is `/ws`, but you should provide any as you do it for any enpoint in Vapor router.
Second param is optional, it's an array of middlewares which are protecting your websocket endpoint. e.g. you could use here 
```swift
let tokenAuthMiddleware = User.tokenAuthMiddleware()
let guardAuthMiddleware = User.guardAuthMiddleware()
```
middlewares for protecting your ws endpoint by bearer token.
Third parameter is a delegate object which will receive and handle all ws events like onOpen, onClose, onText, onBinary, onError.

### Controllers

#### Pure controller (classic)

```swift
let pureController = WSPureController()
pureController.onOpen = { client in
    
}
pureController.onClose = {
    
}
pureController.onError = { client, error in
    
}
pureController.onBinary = { client, data in
    
}
pureController.onText = { client, text in
    
}
```

#### Custom controller

You could create some class which inherit from `WSObserver` and describe your own logic.

#### Bind controller

You could create custom controller wich is inherit from `WSBindController`

Let's take a look how it may look like
```swift
class WSController: WSBindController {
    override func onOpen(_ client: WSClient) {
        
    }
    override func onClose(_ client: WSClient) {
        
    }
}
```
Then you could bind to some events, but you should describe these events first.

e.g. we'd like to describe `message` event for our chat
```swift
struct MessagePayload: Codable {
    var fromUser: User.Public
    var text: String
}

extension WSEventIdentifier {
    static var message: WSEventIdentifier<MessagePayload> { return .init("message") }
    // Payload is optional, so if you don't want any payload you could provide `NoPayload` as a paylaod class.
}
```
Ok, then now we can bind to this event in our custom bind controller:
```swift
class WSController: WSBindController {
    override func onOpen(_ client: WSClient) {
        bind(.message, message)
    }
    override func onClose(_ client: WSClient) {
        
    }
}

extension WSController {
    func message(_ client: WSClient, _ payload: MessagePayload) { //or without payload if it's not needed!
        //handle incoming message here
    }
}
```
Easy, right?

Yeah, but you should know how its protocol works.

`WSBindController` listening for `onText` and `onBinary`, it expect that incoming data is json object in this format:
```json
{
    "event": "some_event_name",
    "payload": {}
}
```
or just (cause payload is optional)
```json
{
    "event": "some_event_name",
}
```
It is actual for both sending and receiving events.

## WSClient

As you may see in every handler in both pure and bind controllers you always have `client` object. This object is `WSClient` class which contains a lot of useful things inside, like

**variables**
- `cid` - UUID
- `req` - original Request
- `eventLoop` - EventLoop
- `channels` - a list of channels of that user

**methods**
- subscribe(to channels: [String]) - use it to subscribe client to some channels
- unsubscribe(to channels: [String]) - use it to unsubscribe client to some channels
- broadcast - a lot of broadcast variations, just use autocompletion to determine needed one

More than that, it is `DatabaseConnectable`, so you could run your queries like this
```swift
User.query(on: client).all()
```

Original `req` gives you ability to e.g. determine connected user:
```swift
let user = try client.req.requireAuthenticated(User.self)
```

Ok this is all about receiving websocket events.. what about sending?

## Sending events

You could get an instance of `WS` anywhere where you have `Container`.

### Broadcasting to some channel
e.g. in any request handler use broadcast method on `ws` object like this:
```swift
import WS

func sampleGetRequestHandler(_ req: Request) throws -> Future<HTTPStatus> {
    let user = try req.requireAuthenticated(User.self)
    let ws = try req.make(WS.self)
    let payload = MessagePayload(fromUser: User.Public(user), text: "Some text")
    return try ws.broadcast(asBinary: .message, payload, to: "some channel", on: req)
                 .transform(to: .ok)
}
```

### Sending some event to concrete client
e.g. in any request handler find needed client from `ws.clients` set and then use `emit` or `broadcast` method
```swift
import WS

func sampleGetRequestHandler(_ req: Request) throws -> Future<HTTPStatus> {
    let user = try req.requireAuthenticated(User.self)
    let ws = try req.make(WS.self)
    let payload = MessagePayload(fromUser: User.Public(user), text: "Some text")
    return ws.clients.first!.emit("hello world", on: req).transform(to: .ok) //do not use force unwraiing in production!
}
```

## How to connect from iOS, macOS, etc?

For example you could use [Starscream lib](https://github.com/daltoniam/Starscream)

## How to connect from Android?

Use any lib which support pure websockets protocol, e.g. not SocketIO cause it uses its own protocol.

## Examples

Yeah, we have them!

AlexoChat project [server](https://github.com/MihaelIsaev/AlexoChat) and [client](https://github.com/emvakar/Chat_client)

## Contacts

Please feel free to contact me in Vapor's discord my nickname is `iMike`

## Contribution

Feel free to contribute!
