extension WS: WSChannelable {
    public func subscribe(_ client: WSClient, to channels: [String]) {
        channels.forEach { ch in
            client.channels.insert(ch)
            if let channel = self.channels.first(where: { $0.cid == ch }) {
                channel.clients.insert(client)
            } else {
                let channel = WSChannel(ch)
                channel.clients.insert(client)
                self.channels.insert(channel)
            }
        }
    }
    
    public func unsubscribe(_ client: WSClient, from channels: [String]) {
        channels.forEach { ch in
            client.channels.remove(ch)
            if let channel = self.channels.first(where: { $0.cid == ch }) {
                channel.clients.remove(client)
            }
        }
    }
}
