import Foundation

public class WSChannel {
    public let cid: String
    public var clients = Set<WSClient>()
    init(_ uid: String) {
        self.cid = uid
    }
}

extension WSChannel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(cid)
    }
    
    public static func == (lhs: WSChannel, rhs: WSChannel) -> Bool {
        return lhs.cid == rhs.cid
    }
}
