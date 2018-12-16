import Foundation
import Vapor
import WebSocket

public class WSClient {
    public let uid = UUID()
    public var connection: WebSocket
    public var req: Request
    public var rooms = Set<String>()
    public init (_ connection: WebSocket, _ req: Request) {
        self.connection = connection
        self.req = req
    }
}
