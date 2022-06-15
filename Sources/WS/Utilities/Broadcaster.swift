import WebSocketKit
import Logging
import Foundation
import NIOWebSocket

public class Broadcaster: Disconnectable, _Disconnectable, Sendable, _Sendable, Subscribable {
    let eventLoop: EventLoop
    var clients: [AnyClient]
    let exchangeMode: ExchangeMode
    let logger: Logger
    var encoder: Encoder?
    let defaultEncoder: Encoder?
    
    var _encoder: Encoder {
        if let encoder = self.encoder {
            return encoder
        }
        if let encoder = self.defaultEncoder {
            return encoder
        }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DefaultDateFormatter())
        return encoder
    }
    
    var excludedClients: Set<UUID> = []
    
    init (eventLoop: EventLoop, clients: [AnyClient], exchangeMode: ExchangeMode, logger: Logger, encoder: Encoder?, defaultEncoder: Encoder?) {
        self.eventLoop = eventLoop
        self.clients = clients
        self.exchangeMode = exchangeMode
        self.logger = logger
        self.encoder = encoder
        self.defaultEncoder = defaultEncoder
    }
    
    /// Set custom data encoder
    public func encoder(_ encoder: Encoder) -> Self {
        self.encoder = encoder
        return self
    }
    
    /// Filtered clients
    private var filteredClients: [AnyClient] {
        clients.filter { client in
            !excludedClients.contains { $0 == client.id }
        }
    }
    
    /// Cached filtered sockets
    var cachedSockets: [WebSocket]?
    
    /// Filtered sockets
    var sockets: [WebSocket] {
        if let cachedSockets = cachedSockets {
            return cachedSockets
        }
        let sockets = filteredClients.map { $0.socket }
        cachedSockets = sockets
        return sockets
    }
    
    /// Quantity of filtered sockets
    public var count: Int { cachedSockets?.count ?? sockets.count }
    
    /// Excludes provided clients from broadcast
    public func exclude(_ clients: AnyClient...) -> Self {
        exclude(clients)
    }
    
    /// Exclude provided clients from recipients
    public func exclude(_ clients: [AnyClient]) -> Self {
        cachedSockets = nil
        clients.forEach {
            excludedClients.insert($0.id)
        }
        return self
    }
    
    /// Filter recipients by closure result
    public func filter(_ filter: @escaping (AnyClient) -> Bool) -> Self {
        clients.removeAll { !filter($0) }
        return self
    }
    
    /// Filter recipients by closure result
    public func filter(_ filter: @escaping (AnyClient) -> EventLoopFuture<Bool>) -> EventLoopFuture<Broadcaster> {
        var ids: Set<UUID> = []
        return clients.map { client in
            filter(client).map { leave in
                if !leave {
                    ids.insert(client.id)
                }
            }
        }.flatten(on: eventLoop).map {
            self.clients.removeAll { ids.contains($0.id) }
        }.transform(to: self)
    }
    
    /// Filter recipients by provided channels
    public func channels(_ channels: String...) -> Self {
        self.channels(channels)
    }
    
    /// Filter recipients by provided channels
    public func channels(_ channels: [String]) -> Self {
        clients.removeAll {
            !$0.channels.contains(where: channels.contains)
        }
        return self
    }
    
    /// See `Subscribable`
    
    /// Subscribe filtered clients to channels
    public func subscribe(to channels: [String], on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        clients.map {
            $0.subscribe(to: channels, on: eventLoop)
        }.flatten(on: eventLoop)
    }
    
    /// Unsubscribe filtered clients from channels
    public func unsubscribe(from channels: [String], on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        clients.map {
            $0.unsubscribe(from: channels, on: eventLoop)
        }.flatten(on: eventLoop)
    }
    
    /// See `Disconnectable`
    
    public func disconnect() -> EventLoopFuture<Void> {
        _disconnect()
    }

    public func disconnect(code: WebSocketErrorCode) -> EventLoopFuture<Void> {
        _disconnect(code: code)
    }
    
    /// See `Sendable`
    
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
