import Vapor
import WebSocket
import Foundation

open class WS: Service, WebSocketServer {
    var server = NIOWebSocketServer.default()
    var middlewares: [Middleware] = []
    
    var clients = Set<WSClient>()
    var channels = Set<WSChannel>()
    
    var delegate: WSDelegate?
    
    public var logger = WSLogger(.off)
    
    // MARK: Initialization
    
    public init(at path: [PathComponent], protectedBy middlewares: [Middleware]? = nil, delegate: WSDelegate? = nil) {
        self.middlewares = middlewares ?? []
        self.delegate = delegate
        server.get(at: path, use: handleConnection)
    }
    
    public convenience init(at path: PathComponent..., protectedBy middlewares: [Middleware]? = nil, delegate: WSDelegate? = nil) {
        self.init(at: path, protectedBy: middlewares, delegate: delegate)
    }
    
    public convenience init(at path: PathComponentsRepresentable..., protectedBy middlewares: [Middleware]? = nil, delegate: WSDelegate? = nil) {
        self.init(at: path.convertToPathComponents(), protectedBy: middlewares, delegate: delegate)
    }
    
    public func pure() -> WSPure {
        let pure = WSPure()
        delegate = pure
        return pure
    }
    
    public func bindable() -> WSBind {
        let pure = WSBind()
        delegate = pure
        return pure
    }
    
    //MARK: Connection Handler
    
    func handleConnection(_ ws: WebSocket, _ req: Request) {
        let client = WSClient(ws, req, ws: self)
        delegate?.wsOnOpen(self, client)
        logger.log(.info("onOpen"), .debug("onOpen cid: " + client.cid.uuidString + "headers: \(req.http.headers)"))
        ws.onText { [weak self] ws, text in
            guard let self = self else { return }
            self.logger.log(.info("onText"), .debug("onText: " + text))
            self.delegate?.wsOnText(self, client, text)
        }
        ws.onBinary { [weak self] ws, data in
            guard let self = self else { return }
            self.logger.log(.info("onBinary"), .debug("onBinary: \(data.count) bytes"))
            self.delegate?.wsOnBinary(self, client, data)
        }
        ws.onClose.always {
            self.logger.log(.info("onClose"), .debug("onClose cid: " + client.cid.uuidString))
            self.delegate?.wsOnClose(self, client)
        }
        ws.onError { [weak self] ws, error in
            guard let self = self else { return }
            self.logger.log(.error("onError: \(error)"))
            self.delegate?.wsOnError(self, client, error)
        }
    }
}

extension WS: WSLoggable {
    func log(_ message: WSLogger.Message...) {
        logger.log(message)
    }
}
