import Vapor

public struct Configurator {
    let application: Application
    
    init (_ application: Application) {
        self.application = application
    }
    
    // MARK: - Build
    
    /// Websocket endpoint builder.
    /// Don't forget to call `.serve()` in the end.
    public func build<Observer: AnyObserver>(_ webSocketID: WebSocketID<Observer>) -> EndpointBuilder<Observer> {
        .init(application, webSocketID)
    }
    
    // MARK: - Observer
    
    /// Returns default observer.
    /// Works only after `.build()`, otherwise fatal error.
    public func observer() -> AnyObserver {

        var anyWebSocketID: AnyWebSocketID? = application.webSocketConfigurator.default

        if anyWebSocketID == nil, let key = application.webSocketStorage.items.values.first?.key {

            anyWebSocketID = _WebSocketID(key: key)

            application.logger.warning("[⚡️] 🚩 Default websocket observer is nil. Use app.webSocketConfigurator.setDefault(...). Used first available websocket.")
        }

        guard let webSocket = anyWebSocketID
        else {
            fatalError("[⚡️] 🚩Default websocket observer is nil. Use app.webSocketConfigurator.default(...)")
        }

        guard let observer = application.webSocketStorage[webSocket.key]
        else {
            fatalError("[⚡️] 🚩Unable to get websocket observer with key `\(webSocket.key)`")
        }

        return observer
    }
    
    /// Returns observer for WebSocketID.
    /// Works only after `.build()`, otherwise fatal error.
    public func observer<Observer>(_ webSocketID: WebSocketID<Observer>) -> Observer {
        guard let observer = application.webSocketStorage[webSocketID.key] as? Observer else {
            fatalError("[⚡️] 🚩Websokcet with key `\(webSocketID.key)` is not running. Use app.webSocketConfigurator.build(...).serve()")
        }
        return observer
    }

    // MARK: - Default WebSocketID storage
    
    /// Saves WebSocketID as default.
    /// After that you could call just `req.webSocketObserver().send(...)` without providing WebSocketID.
    public func setDefault<Observer>(_ webSocketID: WebSocketID<Observer>) {
        self.default = webSocketID
    }
    
    struct DefaultWSIDKey: StorageKey {
        typealias Value = AnyWebSocketID
    }
    
    var `default`: AnyWebSocketID? {
        get {
            application.storage[DefaultWSIDKey.self]
        }
        nonmutating set {
            application.storage[DefaultWSIDKey.self] = newValue
        }
    }
    
    // MARK: - Default Encoder
    
    struct DefaultEncoderKey: StorageKey {
        typealias Value = Encoder
    }
    
    /// Default encoder for all the observers, if `nil` then `JSONEncoder` is used.
    public var encoder: Encoder? {
        get {
            application.storage[DefaultEncoderKey.self]
        }
        nonmutating set {
            application.storage[DefaultEncoderKey.self] = newValue
        }
    }
    
    // MARK: - Default Decoder
    
    struct DefaultDecoderKey: StorageKey {
        typealias Value = Decoder
    }
    
    /// Default encoder for all the observers, if `nil` then `JSONEncoder` is used.
    public var decoder: Decoder? {
        get {
            application.storage[DefaultDecoderKey.self]
        }
        nonmutating set {
            application.storage[DefaultDecoderKey.self] = newValue
        }
    }
    
    // MARK: - Default Decoder
    
    struct KnownEventLoopKey: StorageKey {
        typealias Value = EventLoop
    }
    
    /// Default encoder for all the observers, if `nil` then `JSONEncoder` is used.
    public var knownEventLoop: EventLoop {
        get {
            if let eventLoop = application.storage[KnownEventLoopKey.self] {
                return eventLoop
            } else {
                let eventLoop = application.eventLoopGroup.next()
                application.storage[KnownEventLoopKey.self] = eventLoop
                return eventLoop
            }
        }
        nonmutating set {
            application.storage[KnownEventLoopKey.self] = newValue
        }
    }
}
