import Authentication

extension Set where Element == WSClient {
    public func authenticated<A>(_ type: A.Type = A.self) throws -> [(WSClient, A)] where A: Authenticatable {
        return compactMap {
            if let user = try? $0.req.requireAuthenticated(type) {
                return ($0, user)
            }
            return nil
        }
    }
}
