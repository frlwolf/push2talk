//
// Created by Felipe Lobo on 23/08/21.
//

import Foundation

protocol MessageSendingGateway {

    func send(message: Message) throws

}

struct MessageSender {

    let connection: ConnectionRelay

}

extension MessageSender: MessageSendingGateway {

    func send(message: Message) throws {
        let data = try JSONEncoder().encode(message)
        connection.send(data: data)
    }

}
