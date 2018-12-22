import Foundation
import Vapor

public protocol WSBroadcastable: class {
    @discardableResult
    func broadcast(on container: Container, to clients: Set<WSClient>, _ text: String) throws -> Future<Void>
    @discardableResult
    func broadcast(on container: Container, to clients: Set<WSClient>, _ binary: Data) throws -> Future<Void>
    
    //MARK: Text
    @discardableResult
    func broadcast(on container: Container, _ text: String) throws -> Future<Void>
    @discardableResult
    func broadcast(on container: Container, to channel: String, _ text: String) throws -> Future<Void>
    
    //MARK: Binary
    @discardableResult
    func broadcast(on container: Container, _ binary: Data) throws -> Future<Void>
    @discardableResult
    func broadcast(on container: Container, to channel: String, _ binary: Data) throws -> Future<Void>
    
    //MARK: Codable
    @discardableResult
    func broadcast<T: Codable>(on container: Container, _ event: WSEventIdentifier<T>, _ payload: T?) throws -> Future<Void>
    @discardableResult
    func broadcast<T: Codable>(on container: Container, to channel: String, _ event: WSEventIdentifier<T>, _ payload: T?) throws -> Future<Void>
}
