extension WSChannel: Hashable {
    public static func == (lhs: WSChannel, rhs: WSChannel) -> Bool {
        return lhs.cid == rhs.cid
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(cid)
    }
}
