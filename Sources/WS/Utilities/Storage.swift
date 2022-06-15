import Foundation
import Vapor

class _Storage {
    var items: [String: AnyObserver] = [:]
    
    struct Key: StorageKey {
        typealias Value = _Storage
    }
    
    subscript(_ member: String) -> AnyObserver? {
        get {
            return items[member]
        }
        set {
            if let nv = newValue {
                guard items[member] == nil else { return }
                items[member] = nv
            } else {
                items.removeValue(forKey: member)
            }
        }
    }
}

extension Application {
    var webSocketStorage: _Storage {
        get {
            if let ws = storage[_Storage.Key.self] {
                return ws
            } else {
                logger.debug("[⚡️] 📦 Storage initialized")
                let storage = _Storage()
                self.webSocketStorage = storage
                return storage
            }
        }
        set {
            storage[_Storage.Key.self] = newValue
        }
    }
}
