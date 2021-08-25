//
// Created by Felipe Lobo on 23/08/21.
//

import Foundation

protocol SignalSendingGateway {

    func send(signal: Signal) throws

}

struct SignalSender {

    let connection: SignalingRelay

}

extension SignalSender: SignalSendingGateway {

    func send(signal: Signal) throws {
        let data = try JSONEncoder().encode(signal)
        connection.send(data: data)
    }

}
