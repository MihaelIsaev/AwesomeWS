import Foundation
import Vapor
import NIOWebSocket

open class BindableObserver: BaseObserver, Bindable, _Bindable {
    var binds: [String : BindHandler] = [:]
    
    public func bind<P>(_ identifier: EID<P>, _ handler: @escaping (AnyClient) -> Void) where P: Codable {
        _bind(identifier, handler)
    }
    
    public func bindOptional<P>(_ identifier: EID<P>, _ handler: @escaping (AnyClient, P?) -> Void) where P : Codable {
        _bindOptional(identifier, handler)
    }
    
    public func bind<P>(_ identifier: EID<P>, _ handler: @escaping (AnyClient, P) -> Void) where P : Codable {
        _bind(identifier, handler)
    }
}

/// See `Sendable`
extension BindableObserver {
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
    
    public func send<T: Codable>(event: EID<T>) -> EventLoopFuture<Void> {
        _send(event: event, payload: nil)
    }
    
    public func send<T: Codable>(event: EID<T>, payload: T?) -> EventLoopFuture<Void> {
        _send(event: event, payload: payload)
    }
    
    public func sendPing() -> EventLoopFuture<Void> {
        _sendPing()
    }
}
