import Foundation

public class WSChannel {
    public let cid: String
    public var clients = Set<WSClient>()
    init(_ uid: String) {
        self.cid = uid
    }
}
