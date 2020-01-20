import Vapor

public protocol AnyWSID {
    var key: String { get }
}

struct _WSID: AnyWSID {
    let key: String
}

public struct WSID<Observer: AnyObserver>: AnyWSID {
    public let key: String
    
    public init(_ key: String? = nil) {
        self.key = key ?? String(describing: Observer.self)
    }
}

/// Set WSIDs in your app exactly the same way
extension WSID {
    public static var `default`: WSID<DeclarativeObserver> { .init("ws") }
}
