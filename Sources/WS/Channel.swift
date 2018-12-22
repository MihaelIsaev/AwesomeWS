//
//  Channel.swift
//  WS
//
//  Created by Mihael Isaev on 22/12/2018.
//

import Foundation

public class Channel {
    public let uid: String
    public var clients: [WSClient] = []
    init(_ uid: String) {
        self.uid = uid
    }
}

extension Channel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
    
    public static func == (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.uid == rhs.uid
    }
}
