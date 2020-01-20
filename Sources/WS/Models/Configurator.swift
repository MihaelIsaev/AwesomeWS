import Vapor

public struct Configurator {
    let application: Application
    
    init (_ application: Application) {
        self.application = application
    }
    
    // MARK: - Build
    
    /// Websocket endpoint builder.
    /// Don't forget to call `.serve()` in the end.
    public func build<Observer: AnyObserver>(_ wsid: WSID<Observer>) -> EndpointBuilder<Observer> {
        .init(application, wsid)
    }
    
    // MARK: - Observer
    
    /// Returns default observer.
    /// Works only after `.build()`, otherwise fatal error.
    public func observer() -> AnyObserver {
        var anywsid: AnyWSID? = application.ws.default
        if anywsid == nil, let key = application.wsStorage.items.values.first?.key {
            anywsid = _WSID(key: key)
            application.logger.warning("[⚡️] 🚩 Default websocket observer is nil. Use app.ws.setDefault(...). Used first available websocket.")
        }
        guard let wsid = anywsid else {
            fatalError("[⚡️] 🚩Default websocket observer is nil. Use app.ws.default(...)")
        }
        guard let observer = application.wsStorage[wsid.key] else {
            fatalError("[⚡️] 🚩Unable to get websocket observer with key `\(wsid.key)`")
        }
        return observer
    }
    
    /// Returns observer for WSID.
    /// Works only after `.build()`, otherwise fatal error.
    public func observer<Observer>(_ wsid: WSID<Observer>) -> Observer {
        guard let observer = application.wsStorage[wsid.key] as? Observer else {
            fatalError("[⚡️] 🚩Websokcet with key `\(wsid.key)` is not running. Use app.ws.build(...).serve()")
        }
        return observer
    }

    // MARK: - Default WSID storage
    
    /// Saves WSID as default.
    /// After that you could call just `req.ws().send(...)` without providing WSID.
    public func setDefault<Observer>(_ wsid: WSID<Observer>) {
        self.default = wsid
    }
    
    struct DefaultWSIDKey: StorageKey {
        typealias Value = AnyWSID
    }
    
    var `default`: AnyWSID? {
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
}
