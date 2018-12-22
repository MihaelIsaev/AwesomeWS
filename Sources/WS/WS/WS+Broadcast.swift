import Foundation
import Vapor

extension WS: WSBroadcastable {
    @discardableResult
    public func broadcast(_ text: String, to clients: Set<WSClient>, on container: Container) throws -> Future<Void> {
        return clients.map { $0.emit(text) }.flatten(on: container)
    }
    
    @discardableResult
    public func broadcast(_ binary: Data, to clients: Set<WSClient>, on container: Container) throws -> Future<Void> {
        return clients.map { $0.emit(binary) }.flatten(on: container)
    }
    
    @discardableResult
    public func broadcast(_ text: String, on container: Container) throws -> Future<Void> {
        return try broadcast(text, to: clients, on: container)
    }
    
    @discardableResult
    public func broadcast(_ text: String, to channel: String, on container: Container) throws -> Future<Void> {
        return try broadcast(text, to: channels.first(where: { $0.cid == channel })?.clients ?? [], on: container)
    }
    
    @discardableResult
    public func broadcast(_ binary: Data, on container: Container) throws -> Future<Void> {
        return try broadcast(binary, to: clients, on: container)
    }
    
    @discardableResult
    public func broadcast(_ binary: Data, to channel: String, on container: Container) throws -> Future<Void> {
        return try broadcast(binary, to: channels.first(where: { $0.cid == channel })?.clients ?? [], on: container)
    }
    
    @discardableResult
    public func broadcast<T: Codable>(asText event: WSEventIdentifier<T>, _ payload: T? = nil, on container: Container) throws -> Future<Void> {
        return try broadcast(asText: WSOutgoingEvent(event.uid, payload: payload), to: clients, on: container)
    }
    
    @discardableResult
    public func broadcast<T: Codable>(asText event: WSEventIdentifier<T>, _ payload: T? = nil, to channel: String, on container: Container) throws -> Future<Void> {
        return try broadcast(asText: WSOutgoingEvent(event.uid, payload: payload), to: channels.first(where: { $0.cid == channel })?.clients ?? [], on: container)
    }
    
    @discardableResult
    public func broadcast<T: Codable>(asBinary event: WSEventIdentifier<T>, _ payload: T? = nil, on container: Container) throws -> Future<Void> {
        return try broadcast(asBinary: WSOutgoingEvent(event.uid, payload: payload), to: clients, on: container)
    }
    
    @discardableResult
    public func broadcast<T: Codable>(asBinary event: WSEventIdentifier<T>, _ payload: T? = nil, to channel: String, on container: Container) throws -> Future<Void> {
        return try broadcast(asBinary: WSOutgoingEvent(event.uid, payload: payload), to: channels.first(where: { $0.cid == channel })?.clients ?? [], on: container)
    }
    
    @discardableResult
    func broadcast<T: Codable>(asText event: WSOutgoingEvent<T>, to clients: Set<WSClient>, on container: Container) throws -> Future<Void> {
        let jsonData = try JSONEncoder().encode(event)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw WSError(reason: "Unable to preapare JSON string for broadcast message")
        }
        return clients.map { $0.emit(jsonString) }.flatten(on: container)
    }
    
    @discardableResult
    func broadcast<T: Codable>(asBinary event: WSOutgoingEvent<T>, to clients: Set<WSClient>, on container: Container) throws -> Future<Void> {
        let jsonData = try JSONEncoder().encode(event)
        return clients.map { $0.emit(jsonData) }.flatten(on: container)
    }
}
