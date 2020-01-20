import Vapor

extension Application {
    /// Configure WS through this variable
    ///
    /// Declare WSID in extension
    /// ```swift
    /// extension WSID {
    ///     static var my: WSID<YourWSObserverClass> { .init() }
    /// }
    /// ```
    ///
    /// Configure endpoint and start it serving
    /// ```swift
    /// app.ws.build(.my).at("ws").middlewares(...).serve()
    /// app.ws.setDefault(.my)
    /// ```
    ///
    /// Use it later on `Request`
    /// ```swift
    /// req.ws().send(...)
    /// req.ws(.my).send(...)
    /// ```
    /// or `Application`
    /// ```swift
    /// app.ws.observer().send(...)
    /// app.ws.observer(.my).send(...)
    /// ```
    ///
    public var ws: Configurator { .init(self) }
}
