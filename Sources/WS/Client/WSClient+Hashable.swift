extension WSClient: Hashable {
    public static func == (lhs: WSClient, rhs: WSClient) -> Bool {
        return lhs.cid == rhs.cid
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(cid)
    }
}
