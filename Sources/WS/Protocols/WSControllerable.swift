import Foundation

public protocol WSControllerable: WSDelegate {
    var logger: WSLoggable? { get set }
}
