import Foundation

public protocol Encoder {
    func encode<T>(_ value: T) throws -> Data where T : Encodable
}

extension JSONEncoder: Encoder {}
