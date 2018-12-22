import Foundation
import Vapor

public protocol WSBroadcastable: class {
    func broadcast(on container: Container, to clients: Set<WSClient>, _ text: String) throws -> Future<Void>
    func broadcast(on container: Container, to clients: Set<WSClient>, _ binary: Data) throws -> Future<Void>
    
    //MARK: Text
    func broadcast(on container: Container, _ text: String) throws -> Future<Void>
    func broadcast(on container: Container, to channel: String, _ text: String) throws -> Future<Void>
    
    //MARK: Binary
    func broadcast(on container: Container, _ binary: Data) throws -> Future<Void>
    func broadcast(on container: Container, to channel: String, _ binary: Data) throws -> Future<Void>
    
    //MARK: Codable
    func broadcast<T: Codable>(on container: Container, _ event: WSEventIdentifier<T>, _ payload: T?) throws -> Future<Void>
    func broadcast<T: Codable>(on container: Container, to channel: String, _ event: WSEventIdentifier<T>, _ payload: T?) throws -> Future<Void>
}
