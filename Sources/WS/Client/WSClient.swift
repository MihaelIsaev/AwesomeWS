import Foundation
import Vapor
import WebSocket

public class WSClient: Container {
    public let cid = UUID()
    let connection: WebSocket
    
    public var config: Config
    public var environment: Environment
    public var services: Services
    public var serviceCache: ServiceCache
    public let http: HTTPRequest
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
        
        self.config = req.config
        self.environment = req.environment
        self.services = req.services
        self.serviceCache = req.serviceCache
        self.http = req.http
        self.eventLoop = req.eventLoop
        
        self.logger = ws
        self.broadcastable = ws
    }
}
