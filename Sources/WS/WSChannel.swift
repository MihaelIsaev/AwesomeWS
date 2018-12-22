//
//  Channel.swift
//  WS
//
//  Created by Mihael Isaev on 22/12/2018.
//

import Foundation

public class WSChannel {
    public let uid: String
    public var clients: [WSClient] = []
    init(_ uid: String) {
        self.uid = uid
    }
}

extension WSChannel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
    
    public static func == (lhs: WSChannel, rhs: WSChannel) -> Bool {
        return lhs.uid == rhs.uid
    }
}
