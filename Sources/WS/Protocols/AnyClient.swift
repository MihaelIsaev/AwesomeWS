import Foundation
import Vapor
import NIOWebSocket

public protocol AnyClient: Broadcastable, Disconnectable, Subscribable, Sendable {
    var id: UUID { get }
    var application: Application { get }
    var eventLoop: EventLoop { get }
    var originalRequest: Request { get }
    var channels: Set<String> { get }
    var socket: WebSocket { get }
    var observer: AnyObserver { get }
}

internal protocol _AnyClient: AnyClient, _Disconnectable, _Subscribable, _Sendable {
    var _observer: _AnyObserver { get }
    var channels: Set<String> { get set }
}

extension AnyClient {
    public var eventLoop: EventLoop { application.webSocketConfigurator.knownEventLoop }
    public var logger: Logger { application.logger }
    
    /// See `Broadcastable`
    public var broadcast: Broadcaster {
        observer.broadcast
    }
}

extension _AnyClient {
    public var exchangeMode: ExchangeMode { observer.exchangeMode }
    var _encoder: Encoder { observer._encoder }
}
