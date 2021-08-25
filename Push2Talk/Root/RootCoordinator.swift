//
// Created by Felipe Lobo on 23/08/21.
//

import Foundation

final class RootCoordinator {

    func start(window: Window) {
        let peerConnection = PeerConnection()

        let socket = WebSocketConnector()
        let messageReceiver = SignalReceiver(connection: socket)
        let messageSender = SignalSender(connection: socket)

        let interactor = RootInteractor(
                peerConnection: peerConnection,
                signalReceiver: messageReceiver,
                signalSender: messageSender
        )

        let viewController = RootViewController(useCase: interactor)

        try? window.makeRoot(view: viewController)

        window.makeKeyAndVisible()
    }

}
