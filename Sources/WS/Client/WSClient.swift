import Foundation
import Vapor
import WebSocket

public class WSClient {
    public let cid = UUID()
    
    let connection: WebSocket
    public let req: Request
    public let eventLoop: EventLoop
    public var channels = Set<String>()
    
    weak var logger: WSLoggable?
    weak var broadcastable: WSBroadcastable?
    func broadcaster() throws -> WSBroadcastable {
        guard let broadcastable = broadcastable else {
            throw WSError(reason: "Unable to unwrap broadcastable")
        }
        return broadcastable
    }
    
    init (_ connection: WebSocket, _ req: Request, ws: (WSLoggable & WSBroadcastable)) {
        self.connection = connection
        self.req = req
        self.eventLoop = req.eventLoop
        self.logger = ws
        self.broadcastable = ws
    }
}
