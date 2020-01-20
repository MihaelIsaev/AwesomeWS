import Foundation
import NIO

public protocol Broadcastable {
    var broadcast: Broadcaster { get }
}
