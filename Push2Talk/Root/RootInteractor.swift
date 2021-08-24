//
// Created by Felipe Lobo on 24/08/21.
//

import Foundation

protocol RootUseCase: AnyObject {

    func startConnection()

    func startAudioSession(sender: String)

}

final class RootInteractor {

    let audioSession: AudioStream
    let peerConnection: PeerConnecting
    let messageReceiver: MessageReceivingGateway
    let messageSender: MessageSendingGateway

    init(audioSession: AudioStream,
         peerConnection: PeerConnecting,
         messageReceiver: MessageReceivingGateway,
         messageSender: MessageSendingGateway) {
        self.audioSession = audioSession
        self.peerConnection = peerConnection
        self.messageReceiver = messageReceiver
        self.messageSender = messageSender
    }

}

extension RootInteractor: RootUseCase {

    func startConnection() {
        messageReceiver.startReceiving { [weak peerConnection, messageSender] message in
            switch message {
            case .iceCandidate(let candidate):
                peerConnection?.add(remoteCandidate: candidate)
            case .sessionDescription(let sdp):
                peerConnection?.set(remoteSession: sdp, completion: nil)
                peerConnection?.answer(media: .audio) { result in
                    guard case .success(let sessionDescription) = result else {
                        return
                    }
                    do {
                        try messageSender.send(message: .sessionDescription(sessionDescription))
                    } catch {
                        debugPrint("Error while trying to send a message: \(error)")
                    }
                }
            }
        }

        peerConnection.didGenerateIceCandidates { [messageSender] candidate in
            do {
                try messageSender.send(message: .iceCandidate(candidate))
            } catch {
                debugPrint("Error while trying to send iceCandidate: \(error)")
            }
        }
    }

    func startAudioSession(sender: String) {
        peerConnection.offer(media: .audio) { [messageSender] result in
            guard case .success(let sessionDescription) = result else {
                return
            }

            do {
                try messageSender.send(message: .sessionDescription(sessionDescription))
            } catch {
                debugPrint("Error while trying to send offer sdp: \(error)")
            }
        }

        audioSession.startStreaming()
    }

}
