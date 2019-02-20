import Foundation
import Vapor

extension WS: WSBroadcastable {
    @discardableResult
    public func broadcast(_ text: String, to clients: Set<WSClient>, on container: Container) throws -> Future<Void> {
        return clients.map { $0.emit(text, on: container) }.flatten(on: container)
    }
    
    @discardableResult
    public func broadcast(_ binary: Data, to clients: Set<WSClient>, on container: Container) throws -> Future<Void> {
        return clients.map { $0.emit(binary, on: container) }.flatten(on: container)
    }
    
    @discardableResult
    public func broadcast(_ text: String, to channels: [String], on container: Container) throws -> Future<Void> {
        return try broadcast(text, to: channels, on: container)
    }
    
    @discardableResult
    public func broadcast(_ text: String, to channel: String..., on container: Container) throws -> Future<Void> {
        if channel.isEmpty {
            return try broadcast(text, to: clients, on: container)
        }
        return try broadcast(text, to: channel, on: container)
    }
    
    @discardableResult
    public func broadcast(_ binary: Data, to channels: [String], on container: Container) throws -> Future<Void> {
        return try broadcast(binary, to: channels, on: container)
    }
    
    @discardableResult
    public func broadcast(_ binary: Data, to channel: String..., on container: Container) throws -> Future<Void> {
        if channel.isEmpty {
            return try broadcast(binary, to: clients, on: container)
        }
        return try broadcast(binary, to: channel, on: container)
    }
    
    @discardableResult
    public func broadcast<T: Codable>(asText event: WSEventIdentifier<T>, _ payload: T? = nil, to channels: [String], on container: Container) throws -> Future<Void> {
        return try broadcast(asText: WSOutgoingEvent(event.uid, payload: payload), to: channels, on: container)
    }
    
    @discardableResult
    public func broadcast<T: Codable>(asText event: WSEventIdentifier<T>, _ payload: T? = nil, to channel: String..., on container: Container) throws -> Future<Void> {
        if channel.isEmpty {
            return try broadcast(asText: WSOutgoingEvent(event.uid, payload: payload), to: clients, on: container)
        }
        return try broadcast(asText: WSOutgoingEvent(event.uid, payload: payload), to: channel, on: container)
    }
    
    @discardableResult
    public func broadcast<T: Codable>(asBinary event: WSEventIdentifier<T>, _ payload: T? = nil, to channels: [String], on container: Container) throws -> Future<Void> {
        return try broadcast(asBinary: WSOutgoingEvent(event.uid, payload: payload), to: channels, on: container)
    }
    
    @discardableResult
    public func broadcast<T: Codable>(asBinary event: WSEventIdentifier<T>, _ payload: T? = nil, to channel: String..., on container: Container) throws -> Future<Void> {
        if channel.isEmpty {
            return try broadcast(asBinary: WSOutgoingEvent(event.uid, payload: payload), to: clients, on: container)
        }
        return try broadcast(asBinary: WSOutgoingEvent(event.uid, payload: payload), to: channel, on: container)
    }
    
    @discardableResult
    func broadcast<T: Codable>(asText event: WSOutgoingEvent<T>, to channels: [String], on container: Container) throws -> Future<Void> {
        let clients = self.channels.clients(in: channels)
        return try broadcast(asText: event, to: clients, on: container)
    }
    
    @discardableResult
    func broadcast<T: Codable>(asText event: WSOutgoingEvent<T>, to clients: Set<WSClient>, on container: Container) throws -> Future<Void> {
        let jsonData = try JSONEncoder().encode(event)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw WSError(reason: "Unable to preapare JSON string for broadcast message")
        }
        return try clients.broadcast(jsonString, on: container)
    }
    
    @discardableResult
    func broadcast<T: Codable>(asBinary event: WSOutgoingEvent<T>, to channels: [String], on container: Container) throws -> Future<Void> {
        let clients = self.channels.clients(in: channels)
        return try broadcast(asBinary: event, to: clients, on: container)
    }
    
    @discardableResult
    func broadcast<T: Codable>(asBinary event: WSOutgoingEvent<T>, to clients: Set<WSClient>, on container: Container) throws -> Future<Void> {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = try container.make(WS.self).dateEncodingStrategy
        let jsonData = try jsonEncoder.encode(event)
        return try clients.broadcast(jsonData, on: container)
    }
}
