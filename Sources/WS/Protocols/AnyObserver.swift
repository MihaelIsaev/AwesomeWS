import Vapor

public protocol AnyObserver: class, Broadcastable, CustomStringConvertible, Disconnectable, Sendable, Loggable {
    var key: String { get }
    var path: String { get }
    
    var application: Application { get }
    var eventLoop: EventLoop { get }
    var clients: [AnyClient] { get }
    var encoder: Encoder? { get set }
    var decoder: Decoder? { get set }
    var exchangeMode: ExchangeMode { get }
    
    init (app: Application, key: String, path: String, exchangeMode: ExchangeMode)
    
    func setup()
    
    func on(open client: AnyClient)
    func on(close client: AnyClient)
    func on(ping client: AnyClient)
    func on(pong client: AnyClient)
    func on(text: String, client: AnyClient)
    func on(byteBuffer: ByteBuffer, client: AnyClient)
    func on(data: Data, client: AnyClient)
}

internal protocol _AnyObserver: AnyObserver, _Disconnectable, _Sendable {
    var _clients: [_AnyClient] { get set }
    var _encoder: Encoder { get }
    var _decoder: Decoder { get }
    
    func _on(open client: _AnyClient)
    func _on(close client: _AnyClient)
    func _on(ping client: _AnyClient)
    func _on(pong client: _AnyClient)
    func _on(text: String, client: _AnyClient)
    func _on(byteBuffer: ByteBuffer, client: _AnyClient)
    func _on(data: Data, client: _AnyClient)
}

// MARK: - Default implementation

extension AnyObserver {
    public var eventLoop: EventLoop { application.ws.knownEventLoop }
   
    var _encoder: Encoder {
        if let encoder = self.encoder {
            return encoder
        }
        if let encoder = application.ws.encoder {
            return encoder
        }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DefaultDateFormatter())
        return encoder
    }
    
    var _decoder: Decoder {
        if let decoder = self.decoder {
            return decoder
        }
        if let decoder = application.ws.decoder {
            return decoder
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DefaultDateFormatter())
        return decoder
    }
    
    func handle(_ req: Request, _ ws: WebSocketKit.WebSocket) {
        guard let self = self as? _AnyObserver else { return }
        self.handle(req, ws)
    }
    
    /// See `Broadcastable`
    
    public var broadcast: Broadcaster {
        .init(eventLoop: eventLoop,
               clients: clients,
               exchangeMode: exchangeMode,
               logger: application.logger,
               encoder: encoder,
               defaultEncoder: application.ws.encoder)
    }
    
    /// see `CustomStringConvertible`
    public var description: String {
        "\(String(describing: Self.self))(key: \"\(key)\", at: \"\(path)\")"
    }
}

extension _AnyObserver {
    var clients: [AnyClient] { _clients }
    var observer: _AnyObserver { self }
    var sockets: [WebSocket] { _clients.flatMap { $0.sockets } }
    
    /// Internal handler
    
    func handle(_ req: Request, _ ws: WebSocketKit.WebSocket) {
        let client = Client(self, req, ws, logger: logger)
        _clients.append(client)
        
        _on(open: client)
        on(open: client)
        logger.info("[⚡️] 🟢 new connection \(client.id)")
        
        _ = ws.onClose.map {
            self.logger.info("[⚡️] 🔴 connection closed \(client.id)")
            self._clients.removeAll(where: { $0 === client })
            self._on(close: client)
            self.on(close: client)
        }
        
        ws.onPing { _ in
            self.logger.debug("[⚡️] 🏓 ping \(client.id)")
            self._on(ping: client)
            self.on(ping: client)
        }
        
        ws.onPong { _ in
            self.logger.debug("[⚡️] 🏓 pong \(client.id)")
            self._on(pong: client)
            self.on(pong: client)
        }
        
        ws.onText { _, text in
            guard self.exchangeMode != .binary else {
                self.logger.warning("[⚡️] ❗️📤❗️incoming text event has been rejected. Observer is in `binary` mode.")
                return
            }
            self.logger.debug("[⚡️] 📥 \(client.id) text: \(text)")
            self._on(text: text, client: client)
            self.on(text: text, client: client)
        }
        
        ws.onBinary { _, byteBuffer in
            guard self.exchangeMode != .text else {
                self.logger.warning("[⚡️] ❗️📤❗️incoming binary event has been rejected. Observer is in `text` mode.")
                return
            }
            self.logger.debug("[⚡️] 📥 \(client.id) data: \(byteBuffer.readableBytes)")
            self._on(byteBuffer: byteBuffer, client: client)
            self.on(byteBuffer: byteBuffer, client: client)
            guard byteBuffer.readableBytes > 0 else { return }
            var bytes: [UInt8] = byteBuffer.getBytes(at: byteBuffer.readerIndex, length: byteBuffer.readableBytes) ?? []
            let data = Data(bytes: &bytes, count: byteBuffer.readableBytes)
            self._on(data: data, client: client)
            self.on(data: data, client: client)
        }
    }
    
    public func on(open client: AnyClient) {}
    public func on(close client: AnyClient) {}
    public func on(ping client: AnyClient) {}
    public func on(pong client: AnyClient) {}
    public func on(text: String, client: AnyClient) {}
    public func on(byteBuffer: ByteBuffer, client: AnyClient) {}
    public func on(data: Data, client: AnyClient) {}
    
    func _on(open client: _AnyClient) {}
    func _on(close client: _AnyClient) {}
    func _on(ping client: _AnyClient) {}
    func _on(pong client: _AnyClient) {}
    func _on(text: String, client: _AnyClient) {}
    func _on(byteBuffer: ByteBuffer, client: _AnyClient) {}
    func _on(data: Data, client: _AnyClient) {}
}
