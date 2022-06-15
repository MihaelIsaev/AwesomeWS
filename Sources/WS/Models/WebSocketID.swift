import Vapor

public protocol AnyWebSocketID {
    var key: String { get }
}

struct _WebSocketID: AnyWebSocketID {
    let key: String
}

public struct WebSocketID<Observer: AnyObserver>: AnyWebSocketID {
    public let key: String
    
    public init(_ key: String? = nil) {
        self.key = key ?? String(describing: Observer.self)
    }
}

/// Set WebSocketIDs in your app exactly the same way
extension WebSocketID {
    public static var `default`: WebSocketID<DeclarativeObserver> { .init("webSocket") }
}
