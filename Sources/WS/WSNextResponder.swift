import Foundation
import Vapor

struct WSNextResponder: Responder {
    typealias NextCallback = () throws -> ()
    
    let next: NextCallback
    
    init(next: @escaping NextCallback) {
        self.next = next
    }
    
    func respond(to req: Request) throws -> Future<Response> {
        try next()
        let resp = Response(http: HTTPResponse(status: .ok,
                                               version: req.http.version,
                                               headers: req.http.headers,
                                               body: req.http.body), using: req)
        return req.eventLoop.newSucceededFuture(result: resp)
    }
}
