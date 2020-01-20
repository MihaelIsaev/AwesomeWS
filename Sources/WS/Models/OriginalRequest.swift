//import Vapor
//import NIO
//
///// Represent an original HTTP request of WebSocket client connection
//public struct OriginalRequest: CustomStringConvertible {
//    /// The HTTP method for this request.
//    ///
//    ///     httpReq.method = .GET
//    ///
//    public let method: HTTPMethod
//    
//    /// The URL used on this request.
//    public let url: URI
//    
//    /// The version for this HTTP request.
//    public let version: HTTPVersion
//    
//    /// The header fields for this HTTP request.
//    /// The `"Content-Length"` and `"Transfer-Encoding"` headers will be set automatically
//    /// when the `body` property is mutated.
//    public let headers: HTTPHeaders
//    
//    // MARK: Metadata
//    
//    /// Route object we found for this request.
//    /// This holds metadata that can be used for (for example) Metrics.
//    ///
//    ///     req.route?.description // "GET /hello/:name"
//    ///
//    public let route: Route?
//
//    // MARK: Content
//
//    public let query: URLQueryContainer
//
//    public let content: ContentContainer
//    
//    public let body: Request.Body
//    
//    /// Get and set `HTTPCookies` for this `HTTPRequest`
//    /// This accesses the `"Cookie"` header.
//    public let cookies: HTTPCookies
//    
//    /// See `CustomStringConvertible`
//    public let description: String
//
//    public let remoteAddress: SocketAddress?
//    
//    public let eventLoop: EventLoop
//    
//    public let parameters: Parameters
//    
//    public let userInfo: [AnyHashable: Any]
//    
//    init(_ request: Request) {
//        method = request.method
//        url = request.url
//        version = request.version
//        headers = request.headers
//        route = request.route
//        query = request.query
//        content = request.content
//        body = request.body
//        cookies = request.cookies
//        description = request.description
//        remoteAddress = request.remoteAddress
//        eventLoop = request.eventLoop
//        parameters = request.parameters
//        userInfo = request.userInfo
//    }
//}
