import Foundation
import Vapor

open class BaseObserver {
    public let key: String
    public let path: String
    public let logger: Logger
    public let application: Application
    public let exchangeMode: ExchangeMode
    public var encoder: Encoder?
    public var decoder: Decoder?

    public internal(set) var clients: [AnyClient] = []
    var _clients: [_AnyClient] = []

    public required init (app: Application, key: String, path: String, exchangeMode: ExchangeMode) {
        self.application = app
        self.logger = app.logger
        self.key = key
        self.path = path.count > 0 ? path : "/"
        self.exchangeMode = exchangeMode
        setup()
    }
    
    open func setup() {}
    
    // MARK: see `AnyObserver`
    
    open func on(open client: AnyClient) {}
    open func on(close client: AnyClient) {}
    open func on(ping client: AnyClient) {}
    open func on(pong client: AnyClient) {}
    open func on(text: String, client: AnyClient) {}
    open func on(byteBuffer: ByteBuffer, client: AnyClient) {}
    open func on(data: Data, client: AnyClient) {}
}
