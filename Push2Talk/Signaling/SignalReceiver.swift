//
// Created by Felipe Lobo on 23/08/21.
//

import Foundation

protocol SignalReceivingGateway {

    func startReceiving(signalHandler: @escaping (Signal) -> Void)

}

struct SignalReceiver {

    let connection: SignalingRelay

}

extension SignalReceiver: SignalReceivingGateway {

    func startReceiving(signalHandler: @escaping (Signal) -> Void) {
        listenToNextSignal(handler: signalHandler)
    }

    private func listenToNextSignal(handler: @escaping (Signal) -> Void) {
        connection.receive { data in
            do {
                let signal = try JSONDecoder().decode(Signal.self, from: data)
                handler(signal)
            } catch {
                debugPrint("Received message is not sdp or ice: \(error)")
            }
            listenToNextSignal(handler: handler)
        }
    }

}
