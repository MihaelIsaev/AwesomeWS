import Vapor
import WebSocket
import Foundation

open class WS: Service, WebSocketServer {
    var server = NIOWebSocketServer.default()
    var middlewares: [Middleware] = []
    
    public internal(set) var clients = Set<WSClient>()
    var clientsCache: [String: WSClient] = [:]
    var channels = Set<WSChannel>()
    
    var delegate: WSControllerable?
    
    public var logger = WSLogger(.off)
    public var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .formatted(WSDefaultDateFormatter())
    
    // MARK: - Initialization
    
    public init(at path: [PathComponent], protectedBy middlewares: [Middleware]? = nil, delegate: WSControllerable? = nil) {
        self.middlewares = middlewares ?? []
        self.delegate = delegate
        self.delegate?.logger = self
        server.get(at: path, use: handleConnection)
    }
    
    public convenience init(at path: PathComponent..., protectedBy middlewares: [Middleware]? = nil, delegate: WSControllerable? = nil) {
        self.init(at: path, protectedBy: middlewares, delegate: delegate)
    }
    
    public convenience init(at path: PathComponentsRepresentable..., protectedBy middlewares: [Middleware]? = nil, delegate: WSControllerable? = nil) {
        self.init(at: path.convertToPathComponents(), protectedBy: middlewares, delegate: delegate)
    }
    
    //MARK: -
    
    func insertClient(_ client: WSClient) -> Bool {
        if clients.insert(client).inserted {
            return true
        }
        client.connection.close(code: .unexpectedServerError)
        return false
    }
    
    func removeClient(_ client: WSClient) {
        clients.remove(client)
        for (key, value) in clientsCache {
            if value.cid == client.cid {
                clientsCache.removeValue(forKey: key)
                break
            }
        }
        channels.forEach { $0.clients.remove(client) }
    }
    
    //MARK: - Connection Handler
    
    func handleConnection(_ ws: WebSocket, _ req: Request) {
        let client = WSClient(ws, req, ws: self)
        delegate?.wsOnOpen(self, client)
        logger.log(.info("onOpen"),
                       .debug("onOpen cid: " + client.cid.uuidString + "headers: \(req.http.headers)"), on: req)
        ws.onText { [weak self] ws, text in
            guard let self = self else { return }
            self.logger.log(.info("onText"),
                                 .debug("onText: " + text), on: req)
            self.delegate?.wsOnText(self, client, text)
        }
        ws.onBinary { [weak self] ws, data in
            guard let self = self else { return }
            self.logger.log(.info("onBinary"),
                                 .debug("onBinary: \(data.count) bytes"), on: req)
            self.delegate?.wsOnBinary(self, client, data)
        }
        ws.onClose.always {
            self.logger.log(.info("onClose"),
                                 .debug("onClose cid: " + client.cid.uuidString), on: req)
            self.delegate?.wsOnClose(self, client)
        }
        ws.onError { [weak self] ws, error in
            guard let self = self else { return }
            self.logger.log(.error("onError: \(error)"), on: req)
            self.delegate?.wsOnError(self, client, error)
        }
    }
}
