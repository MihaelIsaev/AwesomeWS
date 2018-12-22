import Foundation
import Vapor

extension Set where Element == WSClient {
    @discardableResult
    public func broadcast(_ text: String, on container: Container) throws -> Future<Void> {
        return map { $0.emit(text, on: container) }.flatten(on: container)
    }
    
    @discardableResult
    public func broadcast(_ binary: Data, on container: Container) throws -> Future<Void> {
        return map { $0.emit(binary, on: container) }.flatten(on: container)
    }
    
    @discardableResult
    public func broadcast(_ text: String, to channel: String, on container: Container) throws -> Future<Void> {
        return filter { $0.channels.contains(channel) }.map { $0.emit(text, on: container) }.flatten(on: container)
    }
    
    @discardableResult
    public func broadcast(_ binary: Data, to channel: String, on container: Container) throws -> Future<Void> {
        return filter { $0.channels.contains(channel) }.map { $0.emit(binary, on: container) }.flatten(on: container)
    }
    
    @discardableResult
    public func broadcast<T: Codable>(asText event: WSEventIdentifier<T>, _ payload: T?, on container: Container) throws -> Future<Void> {
        return try broadcast(asText: WSOutgoingEvent(event.uid, payload: payload), to: self, on: container)
    }
    
    @discardableResult
    public func broadcast<T : Codable>(asText event: WSEventIdentifier<T>, _ payload: T?, to channel: String, on container: Container) throws -> Future<Void> {
        return try broadcast(asText: WSOutgoingEvent(event.uid, payload: payload),
                                      to: filter { $0.channels.contains(channel) },
                                      on: container)
    }
    
    @discardableResult
    public func broadcast<T: Codable>(asBinary event: WSEventIdentifier<T>, _ payload: T?, on container: Container) throws -> Future<Void> {
        return try broadcast(asBinary: WSOutgoingEvent(event.uid, payload: payload), to: self, on: container)
    }
    
    @discardableResult
    public func broadcast<T : Codable>(asBinary event: WSEventIdentifier<T>, _ payload: T?, to channel: String, on container: Container) throws -> Future<Void> {
        return try broadcast(asBinary: WSOutgoingEvent(event.uid, payload: payload),
                                      to: filter { $0.channels.contains(channel) },
                                      on: container)
    }
    
    @discardableResult
    func broadcast<T: Codable>(asText event: WSOutgoingEvent<T>, to clients: Set<WSClient>, on container: Container) throws -> Future<Void> {
        let jsonData = try JSONEncoder().encode(event)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw WSError(reason: "Unable to preapare JSON string for broadcast message")
        }
        return clients.map { $0.emit(jsonString, on: container) }.flatten(on: container)
    }
    
    @discardableResult
    func broadcast<T: Codable>(asBinary event: WSOutgoingEvent<T>, to clients: Set<WSClient>, on container: Container) throws -> Future<Void> {
        let jsonData = try JSONEncoder().encode(event)
        return clients.map { $0.emit(jsonData, on: container) }.flatten(on: container)
    }
}
