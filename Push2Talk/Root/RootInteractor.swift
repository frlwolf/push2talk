//
// Created by Felipe Lobo on 24/08/21.
//

import Foundation

protocol RootUseCase: AnyObject {

    func startConnection()

    func startAudioSession(sender: String)

}

final class RootInteractor {

    let peerConnection: PeerConnecting
    let signalReceiver: SignalReceivingGateway
    let signalSender: SignalSendingGateway

    init(peerConnection: PeerConnecting,
         signalReceiver: SignalReceivingGateway,
         signalSender: SignalSendingGateway) {
        self.peerConnection = peerConnection
        self.signalReceiver = signalReceiver
        self.signalSender = signalSender
    }

}

extension RootInteractor: RootUseCase {

    func startConnection() {
        signalReceiver.startReceiving { [weak peerConnection, signalSender] signal in
            switch signal {
            case .iceCandidate(let candidate):
                peerConnection?.add(remoteCandidate: candidate)
            case .sessionDescription(let sdp):
                peerConnection?.set(remoteSession: sdp, completion: nil)
                peerConnection?.answer(media: .audio) { result in
                    guard case .success(let sessionDescription) = result else {
                        return
                    }
                    try? signalSender.send(signal: .sessionDescription(sessionDescription))
                }
            }
        }

        peerConnection.didGenerateIceCandidates { [signalSender] candidate in
            try? signalSender.send(signal: .iceCandidate(candidate))
        }
    }

    func startAudioSession(sender: String) {
        peerConnection.offer(media: .audio) { [signalSender] result in
            guard case .success(let sessionDescription) = result else {
                return
            }
            try? signalSender.send(signal: .sessionDescription(sessionDescription))
        }
    }

}
