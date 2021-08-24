//
// Created by Felipe Lobo on 23/08/21.
//

import Foundation

protocol MessageReceivingGateway {

    func startReceiving(messageHandler: @escaping (Message) -> Void)

}

struct MessageReceiver {

    let connection: ConnectionRelay

}

extension MessageReceiver: MessageReceivingGateway {

    func startReceiving(messageHandler: @escaping (Message) -> Void) {
        listenToNextMessage(handler: messageHandler)
    }

    private func listenToNextMessage(handler: @escaping (Message) -> Void) {
        connection.receive { data in
            do {
                let message = try JSONDecoder().decode(Message.self, from: data)
                handler(message)
            } catch {
                debugPrint("Received message is not sdp or ice: \(error)")
            }
            listenToNextMessage(handler: handler)
        }
    }

}
