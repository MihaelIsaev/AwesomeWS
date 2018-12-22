import Foundation
import Vapor

extension WSClient: WSBroadcastable {
    @discardableResult
    public func broadcast(_ text: String, to clients: Set<WSClient>, on container: Container) throws -> Future<Void> {
        return try broadcaster().broadcast(text, to: clients, on: container)
    }
    
    @discardableResult
    public func broadcast(_ binary: Data, to clients: Set<WSClient>, on container: Container) throws -> Future<Void> {
        return try broadcaster().broadcast(binary, to: clients, on: container)
    }
    
    @discardableResult
    public func broadcast(_ text: String, on container: Container) throws -> Future<Void> {
        return try broadcaster().broadcast(text, on: container)
    }
    
    @discardableResult
    public func broadcast(_ text: String, to channel: String, on container: Container) throws -> Future<Void> {
        return try broadcaster().broadcast(text, to: channel, on: container)
    }
    
    @discardableResult
    public func broadcast(_ binary: Data, on container: Container) throws -> Future<Void> {
        return try broadcaster().broadcast(binary, on: container)
    }
    
    @discardableResult
    public func broadcast(_ binary: Data, to channel: String, on container: Container) throws -> Future<Void> {
        return try broadcaster().broadcast(binary, to: channel, on: container)
    }
    
    @discardableResult
    public func broadcast<T: Codable>(asText event: WSEventIdentifier<T>, _ payload: T? = nil, on container: Container) throws -> Future<Void> {
        return try broadcaster().broadcast(asText: event, payload, on: container)
    }
    
    @discardableResult
    public func broadcast<T: Codable>(asText event: WSEventIdentifier<T>, _ payload: T? = nil, to channel: String, on container: Container) throws -> Future<Void> {
        return try broadcaster().broadcast(asText: event, payload, to: channel, on: container)
    }
    
    @discardableResult
    public func broadcast<T: Codable>(asBinary event: WSEventIdentifier<T>, _ payload: T? = nil, on container: Container) throws -> Future<Void> {
        return try broadcaster().broadcast(asBinary: event, payload, on: container)
    }
    
    @discardableResult
    public func broadcast<T: Codable>(asBinary event: WSEventIdentifier<T>, _ payload: T? = nil, to channel: String, on container: Container) throws -> Future<Void> {
        return try broadcaster().broadcast(asBinary: event, payload, to: channel, on: container)
    }
}
