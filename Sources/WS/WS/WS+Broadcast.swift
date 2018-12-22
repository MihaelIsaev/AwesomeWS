import Foundation
import Vapor

extension WS: WSBroadcastable {
    public func broadcast(on container: Container, to clients: Set<WSClient>, _ text: String) throws -> Future<Void> {
        return clients.map { $0.emit(text) }.flatten(on: container)
    }
    
    public func broadcast(on container: Container, to clients: Set<WSClient>, _ binary: Data) throws -> Future<Void> {
        return clients.map { $0.emit(binary) }.flatten(on: container)
    }
    
    func broadcast<T: Codable>(on container: Container, to clients: Set<WSClient>, _ event: WSOutgoingEvent<T>) throws -> Future<Void> {
        let jsonData = try JSONEncoder().encode(event)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw WSError(reason: "Unable to preapare JSON string for broadcast message")
        }
        return clients.map { $0.emit(jsonString) }.flatten(on: container)
    }
    
    public func broadcast(on container: Container, _ text: String) throws -> Future<Void> {
        return try broadcast(on: container, to: clients, text)
    }
    
    public func broadcast(on container: Container, to channel: String, _ text: String) throws -> Future<Void> {
        return try broadcast(on: container, to: channels.first(where: { $0.cid == channel })?.clients ?? [], text)
    }
    
    public func broadcast(on container: Container, _ binary: Data) throws -> Future<Void> {
        return try broadcast(on: container, to: clients, binary)
    }
    
    public func broadcast(on container: Container, to channel: String, _ binary: Data) throws -> Future<Void> {
        return try broadcast(on: container, to: channels.first(where: { $0.cid == channel })?.clients ?? [], binary)
    }
    
    public func broadcast<T>(on container: Container, _ event: WSEventIdentifier<T>, _ payload: T?) throws -> Future<Void> where T : Decodable, T : Encodable {
        return try broadcast(on: container, to: clients, WSOutgoingEvent(event.uid, payload: payload))
    }
    
    public func broadcast<T>(on container: Container, to channel: String, _ event: WSEventIdentifier<T>, _ payload: T?) throws -> Future<Void> where T : Decodable, T : Encodable {
        return try broadcast(on: container, to: channels.first(where: { $0.cid == channel })?.clients ?? [], WSOutgoingEvent(event.uid, payload: payload))
    }
}
