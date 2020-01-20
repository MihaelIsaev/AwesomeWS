import Vapor

extension Request {
    /// Default websocket observer
    public func ws() -> AnyObserver { application.ws.observer() }
    
    /// Selected websocket observer
    public func ws<Observer>(_ wsid: WSID<Observer>) -> Observer { application.ws.observer(wsid) }
}
