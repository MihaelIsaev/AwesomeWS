import Foundation
import Vapor
import WebSocket

public class WSClient: Container, DatabaseConnectable {
    public let cid = UUID()
    let connection: WebSocket
    public let req: Request
    
    public var config: Config { return req.config }
    public var environment: Environment { return req.environment }
    public var services: Services { return req.services }
    public var serviceCache: ServiceCache { return req.serviceCache }
    public var http: HTTPRequest { return req.http }
    public var eventLoop: EventLoop { return req.eventLoop }
    
    public var channels = Set<String>()
    
    weak var logger: WSLoggable?
    weak var broadcastable: WSBroadcastable?
    weak var channelable: WSChannelable?
    
    init (_ connection: WebSocket, _ req: Request, ws: (WSLoggable & WSBroadcastable & WSChannelable)) {
        self.connection = connection
        self.req = req
        self.logger = ws
        self.broadcastable = ws
        self.channelable = ws
    }
    
    //MARK: -
    
    public func subscribe(to channels: String...) {
        subscribe(to: channels)
    }
    
    public func subscribe(to channels: [String]) {
        channelable?.subscribe(self, to: channels)
    }
    
    public func unsubscribe(from channels: String...) {
        unsubscribe(from: channels)
    }
    
    public func unsubscribe(from channels: [String]) {
        channelable?.unsubscribe(self, from: channels)
    }
    
    //MARK: - WSBroadcastable
    
    func broadcaster() throws -> WSBroadcastable {
        guard let broadcastable = broadcastable else {
            throw WSError(reason: "Unable to unwrap broadcastable")
        }
        return broadcastable
    }
    
    //MARK: - DatabaseConnectable
    
    public func databaseConnection<D>(to database: DatabaseIdentifier<D>?) -> Future<D.Connection> {
        return req.databaseConnection(to: database)
    }
}
