protocol WSErrorProtocol: Error {}
public struct WSError: WSErrorProtocol {
    public var reason: String
    init(reason: String) {
        self.reason = reason
    }
}
