import Foundation
import Vapor

struct NextResponder: Responder {
    typealias NextCallback = () throws -> ()
    
    let next: NextCallback
    
    init(next: @escaping NextCallback) {
        self.next = next
    }
    
    func respond(to req: Request) throws -> Future<Response> {
        try next()
        let resp = Response(http: HTTPResponse(status: .ok,
                                               version: HTTPVersion.init(major: 1, minor: 1),
                                               headers: HTTPHeaders(),
                                               body: ""), using: req)
        return req.eventLoop.newSucceededFuture(result: resp)
    }
}
