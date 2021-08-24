//
// Created by Felipe Lobo on 23/08/21.
//

import Foundation

final class RootCoordinator {

    func start(window: Window) {
        let audioSession = AudioSession()
        let peerConnection = PeerConnection()

        let socket = WebSocketConnector()
        let messageReceiver = MessageReceiver(connection: socket)
        let messageSender = MessageSender(connection: socket)

        let interactor = RootInteractor(
                audioSession: audioSession,
                peerConnection: peerConnection,
                messageReceiver: messageReceiver,
                messageSender: messageSender
        )

        let viewController = RootViewController(useCase: interactor)

        try? window.makeRoot(view: viewController)

        window.makeKeyAndVisible()
    }

}
