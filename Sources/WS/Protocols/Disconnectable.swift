import Vapor
import NIOWebSocket

public protocol Disconnectable {
    @discardableResult
    func disconnect() -> EventLoopFuture<Void>
    @discardableResult
    func disconnect(code: WebSocketErrorCode) -> EventLoopFuture<Void>
}

internal protocol _Disconnectable: Disconnectable {
    var eventLoop: EventLoop { get }
    var sockets: [WebSocket] { get }
}

extension _Disconnectable {
    public func disconnect() -> EventLoopFuture<Void> {
        _disconnect()
    }

    public func disconnect(code: WebSocketErrorCode) -> EventLoopFuture<Void> {
        _disconnect(code: code)
    }
    
    func _disconnect() -> EventLoopFuture<Void> {
        eventLoop.future().flatMap {
            self._disconnect(code: .goingAway)
        }
    }

    func _disconnect(code: WebSocketErrorCode) -> EventLoopFuture<Void> {
        guard sockets.count > 0 else { return eventLoop.future() }
        return sockets.map {
            $0.close(code: code)
        }.flatten(on: eventLoop)
    }
}

// MARK: - EventLoopFuture

extension EventLoopFuture: Disconnectable where Value: Disconnectable {
    public func disconnect() -> EventLoopFuture<Void> {
        flatMap { $0.disconnect() }
    }
    
    public func disconnect(code: WebSocketErrorCode) -> EventLoopFuture<Void> {
        flatMap { $0.disconnect(code: code) }
    }
}
