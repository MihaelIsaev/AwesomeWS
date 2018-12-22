import Foundation
import Vapor

extension WSClient: WSBroadcastable {
    @discardableResult
    public func broadcast(on container: Container, to clients: Set<WSClient>, _ text: String) throws -> Future<Void> {
        return try broadcaster().broadcast(on: container, to: clients, text)
    }
    
    @discardableResult
    public func broadcast(on container: Container, to clients: Set<WSClient>, _ binary: Data) throws -> Future<Void> {
        return try broadcaster().broadcast(on: container, to: clients, binary)
    }
    
    @discardableResult
    public func broadcast(on container: Container, _ text: String) throws -> Future<Void> {
        return try broadcaster().broadcast(on: container, text)
    }
    
    @discardableResult
    public func broadcast(on container: Container, to channel: String, _ text: String) throws -> Future<Void> {
        return try broadcaster().broadcast(on: container, to: channel, text)
    }
    
    @discardableResult
    public func broadcast(on container: Container, _ binary: Data) throws -> Future<Void> {
        return try broadcaster().broadcast(on: container, binary)
    }
    
    @discardableResult
    public func broadcast(on container: Container, to channel: String, _ binary: Data) throws -> Future<Void> {
        return try broadcaster().broadcast(on: container, to: channel, binary)
    }
    
    @discardableResult
    public func broadcast<T>(on container: Container, _ event: WSEventIdentifier<T>, _ payload: T?) throws -> Future<Void> where T : Decodable, T : Encodable {
        return try broadcaster().broadcast(on: container, event, payload)
    }
    
    @discardableResult
    public func broadcast<T>(on container: Container, to channel: String, _ event: WSEventIdentifier<T>, _ payload: T?) throws -> Future<Void> where T : Decodable, T : Encodable {
        return try broadcaster().broadcast(on: container, to: channel, event, payload)
    }
}
