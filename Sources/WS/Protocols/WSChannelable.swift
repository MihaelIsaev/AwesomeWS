//
//  WSChannelable.swift
//  WS
//
//  Created by Mihael Isaev on 23/12/2018.
//

import Foundation

public protocol WSChannelable: class {
    func subscribe(_ client: WSClient, to channels: [String])
    func unsubscribe(_ client: WSClient, from channels: [String])
}
