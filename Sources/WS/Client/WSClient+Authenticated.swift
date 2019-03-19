import Authentication

extension Set where Element == WSClient {
    public func authenticated<A>(_ type: A.Type = A.self) throws -> [(client: WSClient, user: A)] where A: Authenticatable {
        return compactMap {
            if let user = try? $0.req.requireAuthenticated(type) {
                return ($0, user)
            }
            return nil
        }
    }
}
