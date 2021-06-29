import Vapor

public class EndpointBuilder<Observer: AnyObserver> {
    let application: Application
    let wsid: WSID<Observer>
    
    var path: [PathComponent] = []
    var middlewares: [Middleware] = []
    var exchangeMode: ExchangeMode = .both
    var encoder: Encoder?
    var decoder: Decoder?
    
    init (_ application: Application, _ wsid: WSID<Observer>) {
        self.application = application
        self.wsid = wsid
    }
    
    /// Path where websocket should listen to
    public func at(_ path: PathComponent...) -> Self {
        at(path)
    }
    
    /// Path where websocket should listen to
    public func at(_ path: [PathComponent]) -> Self {
        self.path.append(contentsOf: path)
        return self
    }
    
    /// Middlewares to protect websocket endpoint
    public func middlewares(_ middlewares: Middleware...) -> Self {
        self.middlewares(middlewares)
    }
    
    /// Middlewares to protect websocket endpoint
    public func middlewares(_ middlewares: [Middleware]) -> Self {
        self.middlewares.append(contentsOf: middlewares)
        return self
    }
    
    /// Observer data exchange mode.
    /// Can be `text`, `binary` or `both`.
    /// It is `both` by default.
    public func mode(_ mode: ExchangeMode) -> Self {
        exchangeMode = mode
        return self
    }
    
    /// Custom observer outgoing data encoder. `JSONEncoder` by default. May be needed for `Bindable` observer.
    public func encoder(_ value: Encoder) -> Self {
        encoder = value
        return self
    }
    
    /// Custom observer incoming data decoder. `JSONDecoder` by default. May be needed for `Bindable` observer.
    public func decoder(_ value: Decoder) -> Self {
        decoder = value
        return self
    }
    
    /// Starts websocket to listen on configured enpoint
    @discardableResult
    public func serve() -> Observer {
        _ = application.ws.knownEventLoop
        let observer = Observer.init(app: application, key: wsid.key, path: path.string, exchangeMode: exchangeMode)
        
        if let encoder = encoder {
            observer.encoder = encoder
        }
        if let decoder = decoder {
            observer.decoder = decoder
        }
        
        application.wsStorage[wsid.key] = observer
        WSRoute(root: application.grouped(middlewares), path: path).webSocket(onUpgrade: observer.handle)
        
        let observerType = String(describing: Observer.self)
        application.logger.notice("[⚡️] 🚀 \(observerType) starting on \(application.http.server.configuration.address)/\(path.string)")
        
        return observer
    }
}

fileprivate final class WSRoute: RoutesBuilder {
    /// Router to cascade to.
    let root: RoutesBuilder
    
    /// Additional components.
    let path: [PathComponent]
    
    /// Creates a new `PathGroup`.
    init(root: RoutesBuilder, path: [PathComponent]) {
        self.root = root
        self.path = path
    }
    
    /// See `HTTPRoutesBuilder`.
    func add(_ route: Route) {
        route.path = self.path + route.path
        self.root.add(route)
    }
}
