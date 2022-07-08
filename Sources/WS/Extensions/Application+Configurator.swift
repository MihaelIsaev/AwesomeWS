import Vapor

extension Application {
    /// Configure WebSocket through this variable
    ///
    /// Declare WebSocketID in extension
    /// ```swift
    /// extension WebSocketID {
    ///     static var customObserver: WebSocketID<YourWSObserverClass> { .init() }
    /// }
    /// ```
    ///
    /// Configure endpoint and start it serving
    /// ```swift
    /// app.webSocketConfigurator.build(.customObserver).at("ws").middlewares(...).serve()
    /// app.webSocketConfigurator.setDefault(.customObserver)
    /// ```
    ///
    /// Use it later on `Request`
    /// ```swift
    /// req.webSocketObserver().send(...)
    /// req.webSocketObserver(.customObserver).send(...)
    /// ```
    /// or `Application`
    /// ```swift
    /// app.webSocketConfigurator.observer().send(...)
    /// app.webSocketConfigurator.observer(.customObserver).send(...)
    /// ```
    ///
    public var webSocketConfigurator: Configurator { .init(self) }
}
