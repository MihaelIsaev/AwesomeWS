import Foundation
import Vapor

public protocol WSBroadcastable: class {
    func broadcast(_ text: String, to clients: Set<WSClient>, on container: Container) throws -> Future<Void>
    func broadcast(_ binary: Data, to clients: Set<WSClient>, on container: Container) throws -> Future<Void>
    
    //MARK: Text
    func broadcast(_ text: String, to channels: [String], on container: Container) throws -> Future<Void>
    func broadcast(_ text: String, to channel: String..., on container: Container) throws -> Future<Void>
    
    //MARK: Binary
    func broadcast(_ binary: Data, to channels: [String], on container: Container) throws -> Future<Void>
    func broadcast(_ binary: Data, to channel: String..., on container: Container) throws -> Future<Void>
    
    //MARK: Codable
    func broadcast<T: Codable>(asText event: WSEventIdentifier<T>, _ payload: T?, to channels: [String], on container: Container) throws -> Future<Void>
    func broadcast<T: Codable>(asText event: WSEventIdentifier<T>, _ payload: T?, to channel: String..., on container: Container) throws -> Future<Void>
    func broadcast<T: Codable>(asBinary event: WSEventIdentifier<T>, _ payload: T?, to channels: [String], on container: Container) throws -> Future<Void>
    func broadcast<T: Codable>(asBinary event: WSEventIdentifier<T>, _ payload: T?, to channel: String..., on container: Container) throws -> Future<Void>
}
