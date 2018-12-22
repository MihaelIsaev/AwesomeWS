//
//  WSDelegate.swift
//  WS
//
//  Created by Mihael Isaev on 22/12/2018.
//

import Foundation

public protocol WSDelegate {
    @discardableResult
    func wsOnOpen(_ ws: WS, _ client: WSClient) -> Bool
    func wsOnClose(_ ws: WS, _ client: WSClient)
    func wsOnText(_ ws: WS, _ client: WSClient, _ text: String)
    func wsOnBinary(_ ws: WS, _ client: WSClient, _ data: Data)
    func wsOnError(_ ws: WS, _ client: WSClient, _ error: Error)
}
