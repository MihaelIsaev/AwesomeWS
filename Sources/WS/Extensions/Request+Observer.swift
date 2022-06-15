import Vapor

extension Request {
    /// Default websocket observer
    public func ws() -> AnyObserver { application.webSocketConfigurator.observer() }
    
    /// Selected websocket observer
    public func ws<Observer>(_ wsid: WebSocketID<Observer>) -> Observer { application.webSocketConfigurator.observer(wsid) }
}
