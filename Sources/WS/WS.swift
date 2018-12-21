import Vapor
import WebSocket
import Foundation

open class WS: Service, WebSocketServer {
    var server = NIOWebSocketServer.default()
    var clients: [WSClient] = []
    var middlewares: [Middleware] = []
    
    // MARK: Initialization
    
    public init(at path: [PathComponent], protectedBy middlewares: [Middleware]? = nil, listener: WSListenable? = nil) {
        self.middlewares = middlewares ?? []
        server.get(at: path, use: handleConnection)
    }
    
    public convenience init(at path: PathComponent..., protectedBy middlewares: [Middleware]? = nil, listener: WSListenable? = nil) {
        self.init(at: path, protectedBy: middlewares, listener: listener)
    }
    
    public convenience init(at path: PathComponentsRepresentable..., protectedBy middlewares: [Middleware]? = nil, listener: WSListenable? = nil) {
        self.init(at: path.convertToPathComponents(), protectedBy: middlewares, listener: listener)
    }
    
    //MARK: Connection Handler
    
    public func handleConnection(_ ws: WebSocket, _ req: Request) {
        let client = WSClient(ws, req)
        clients.append(client)
        onOpen?(client)
        ws.onText { [weak self] ws, text in
            self?.onTextHandler(client, text)
        }
        ws.onBinary { [weak self] ws, data in
            self?.onBinaryHandler(client, data)
        }
        ws.onClose.always {
            self.onCloseHandler()
        }
        ws.onError { [weak self] ws, error in
            self?.onErrorHandler(client, error)
        }
    }
    
    public typealias OnOpenHandler = (WSClient) -> Void
    public var onOpen: OnOpenHandler?
    
    public typealias OnTextHandler = (WSClient, String) -> Void
    public var onText: OnTextHandler?
    
    private func onTextHandler(_ client: WSClient, _ text: String) {
        onText?(client, text)
        //self.onText?(client, text)
    }
    
    public typealias OnBinaryHandler = (WSClient, Data) -> Void
    public var onBinary: OnBinaryHandler?
    
    private func onBinaryHandler(_ client: WSClient, _ data: Data) {
        onBinary?(client, data)
//        do {
//            let message = try JSONDecoder().decode(DataMessage.self, from: data)
//            switch message.type {
//            case .subscribe:
//                if let data = message.data,
//                    let subscription = try? JSONDecoder().decode(SubscriptionData.self, from: data) {
//                    subscribe(client, subscription)
//                }
//            case .unsubscribe:
//                if let data = message.data,
//                    let subscription = try? JSONDecoder().decode(SubscriptionData.self, from: data) {
//                    unsubscribe(client, subscription)
//                }
//            default: break
//            }
//        } catch {
//            debugPrint("[WS] onData: can't decode: \(error)")
//        }
    }
    
    public typealias OnCloseHandler = () -> Void
    public var onClose: OnCloseHandler?
    
    private func onCloseHandler() {
        onClose?()
        //self.onClose?(client)
        //if let index = self.clients.index(where: { c -> Bool in
        //    return c === client
        //}) {
        //    self.clients.remove(at: index)
        //}
        //            DispatchQueue.global().async {
        //                sleep(2)
        //                print("[WS] onClose after 2 seconds: isClosed=\(ws.isClosed)")
        //                ws.send("check sending on closed ws")
        //            }
    }
    
    public typealias OnErrorHandler = (WSClient, Error) -> Void
    public var onError: OnErrorHandler?
    
    private func onErrorHandler(_ client: WSClient, _ error: Error) {
        onError?(client, error)
        //self.onError?(client, error)
        debugPrint("[WS] onError: \(error)")
    }
    
    //MARK: Text
    
    public func broadcast(_ text: String) throws {
        try broadcast(clients, text)
    }
    
    public func broadcast(room: String, _ text: String) throws {
        try broadcast(clients.filter { $0.channels.contains(room) }, text)
    }
    
    public func broadcast(_ clients: [WSClient], _ text: String) throws {
        clients.forEach { $0.connection.send(text) }
    }
    
    //MARK: JSON
    
    public func broadcast<T: Codable>(_ jsonPayload: T) throws {
        try broadcast(clients, jsonPayload)
    }
    
    public func broadcast<T: Codable>(room: String, _ jsonPayload: T) throws {
        try broadcast(clients.filter { $0.channels.contains(room) }, jsonPayload)
    }
    
    public func broadcast<T: Codable>(_ clients: [WSClient], _ jsonPayload: T) throws {
        let jsonData = try JSONEncoder().encode(jsonPayload)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw WSError(reason: "Unable to preapare JSON string for broadcast message")
        }
        clients.forEach { $0.connection.send(jsonString) }
    }
    
    //MARK: Binary
    
    public func broadcast(_ binary: Data) throws {
        try broadcast(clients, binary)
    }
    
    public func broadcast(room: String, _ binary: Data) throws {
        try broadcast(clients.filter { $0.channels.contains(room) }, binary)
    }
    
    public func broadcast(_ clients: [WSClient], _ binary: Data) throws {
        clients.forEach { $0.connection.send(binary) }
    }
}
