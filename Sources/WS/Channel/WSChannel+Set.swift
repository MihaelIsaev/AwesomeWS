//
//  WSChannel+Set.swift
//  App
//
//  Created by Mihael Isaev on 23/12/2018.
//

import Foundation
import Vapor

extension Set where Element == WSChannel {
    func clients(in channels: [String]) -> Set<WSClient> {
        return Set<WSClient>(filter { channels.contains($0.cid) }.flatMap { $0.clients })
    }
}
