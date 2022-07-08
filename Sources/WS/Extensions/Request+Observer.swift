import Vapor

extension Request {
    /// Default websocket observer
    public func webSocketObserver() -> AnyObserver { application.webSocketConfigurator.observer() }
    
    /// Selected websocket observer
    public func webSocketObserver<Observer>(_ wsid: WebSocketID<Observer>) -> Observer { application.webSocketConfigurator.observer(wsid) }
}
