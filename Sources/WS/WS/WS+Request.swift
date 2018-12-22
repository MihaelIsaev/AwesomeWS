import Foundation
import Vapor

extension WS {
    public func requireClientByAuthToken(on req: Request) throws -> WSClient {
        guard let token = req.http.headers[.authorization].first else {
            throw WSError(reason: "Unable to get Authorization token from Request")
        }
        if let client = clientsCache[token] {
            return client
        }
        guard let client = clients.first(where: { $0.req.http.headers[.authorization].first == token }) else {
            throw WSError(reason: "Unable to find websocket client with Authorization token from Request")
        }
        clientsCache[token] = client
        return client
    }
}
