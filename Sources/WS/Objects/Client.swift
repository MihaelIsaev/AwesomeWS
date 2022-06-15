import Foundation
import Vapor
import NIOWebSocket

class Client: _AnyClient {
    /// See `AnyClient`
    public let id: UUID = .init()
    public let originalRequest: Request
    public let application: Application
    
    /// See `Loggable`
    public let logger: Logger
    
    /// See `_Sendable`
    let observer: AnyObserver
    let _observer: _AnyObserver
    let socket: WebSocketKit.WebSocket
    var sockets: [WebSocket] { [socket] }
    
    /// See `AnyClient`
    public internal(set) var channels: Set<String> = []
    
    /// See `Subscribable`
    var clients: [_AnyClient] { [self] }
    
    init (_ observer: _AnyObserver, _ request: Vapor.Request, _ socket: WebSocketKit.WebSocket, logger: Logger) {
        self.observer = observer
        self._observer = observer
        self.originalRequest = request
        self.application = request.application
        self.logger = logger
        self.socket = socket
    }
}

/// See `Sendable`

extension Client {
    public func send<S>(text: S) -> EventLoopFuture<Void> where S : Collection, S.Element == Character {
        _send(text: text)
    }

    public func send(bytes: [UInt8]) -> EventLoopFuture<Void> {
        _send(bytes: bytes)
    }

    public func send<Data>(data: Data) -> EventLoopFuture<Void> where Data : DataProtocol {
        _send(data: data)
    }
    
    public func send<Data>(data: Data, opcode: WebSocketOpcode) -> EventLoopFuture<Void> where Data: DataProtocol {
        _send(data: data, opcode: opcode)
    }
    
    public func send<C>(model: C) -> EventLoopFuture<Void> where C: Encodable {
        _send(model: model)
    }
    
    public func send<C>(model: C, encoder: Encoder) -> EventLoopFuture<Void> where C: Encodable {
        _send(model: model, encoder: encoder)
    }
    
    public func send<T: Codable>(event: EventID<T>) -> EventLoopFuture<Void> {
        _send(event: event, payload: nil)
    }
    
    public func send<T: Codable>(event: EventID<T>, payload: T?) -> EventLoopFuture<Void> {
        _send(event: event, payload: payload)
    }
    
    public func sendPing() -> EventLoopFuture<Void> {
        _sendPing()
    }
}
