//
// Created by Felipe Lobo on 23/08/21.
//

import Foundation

final class Coordinator {

    func start(window: Window) {
        let peerConnection = PeerConnection()

        let socket = WebSocketConnector()
        let signalReceiver = SignalReceiver(connection: socket)
        let signalSender = SignalSender(connection: socket)

        let interactor = Interactor(
                peerConnection: peerConnection,
                signalReceiver: signalReceiver,
                signalSender: signalSender
        )

        let viewController = ViewController(useCase: interactor)

        try? window.makeRoot(view: viewController)

        window.makeKeyAndVisible()
    }

}
