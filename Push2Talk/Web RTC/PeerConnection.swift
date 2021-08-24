//
// Created by Felipe Lobo on 23/08/21.
//

import Foundation
import Combine
import WebRTC


final class PeerConnection: NSObject {

    private static let defaultStunServers = ["stun:stun.l.google.com:19302",
                                             "stun:stun1.l.google.com:19302",
                                             "stun:stun2.l.google.com:19302",
                                             "stun:stun3.l.google.com:19302",
                                             "stun:stun4.l.google.com:19302"]

    private static let factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
    }()

    private var iceCandidateGeneratedHandler: ((IceCandidate) -> Void)?
    private let peerConnection: RTCPeerConnection

    init(servers serverStrings: [String] = defaultStunServers) {
        let config = RTCConfiguration()
        config.iceServers = [RTCIceServer(urlStrings: serverStrings)]
        config.sdpSemantics = .unifiedPlan
        config.continualGatheringPolicy = .gatherContinually

        let mediaConstraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue])

        peerConnection = Self.factory.peerConnection(with: config, constraints: mediaConstraints, delegate: nil)

        super.init()

        peerConnection.delegate = self

        configureAudio()
    }

    private func configureAudio() {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = Self.factory.audioSource(with: audioConstrains)
        let audioTrack = Self.factory.audioTrack(with: audioSource, trackId: "audio0")

        peerConnection.add(audioTrack, streamIds: ["Stream"])
    }

}

extension PeerConnection: PeerConnecting {

    func offer(media: Media, completion: @escaping (Result<SessionDescription, Error>) -> Void) {
        let constraints = media.constraints()

        peerConnection.offer(for: constraints) { [unowned peerConnection] sdp, error in
            if let sdp = sdp {
                peerConnection.setLocalDescription(sdp) { error in
                    if let error = error {
                        debugPrint("Error while creating a connection offer: (\(error))")
                        completion(.failure(error))
                    }
                    debugPrint("Did create a connection offer")
                    completion(.success(SessionDescription(from: sdp)))
                }
            } else if let error = error {
                debugPrint("Error while creating a connection offer: (\(error))")
                completion(.failure(error))
            } else {
                fatalError("Inconsistent state reached while creating a connection offer to a peer")
            }
        }
    }

    func answer(media: Media, completion: @escaping (Result<SessionDescription, Error>) -> Void) {
        let constraints = media.constraints()

        peerConnection.answer(for: constraints) { [unowned peerConnection] sdp, error in
            if let sdp = sdp {
                peerConnection.setLocalDescription(sdp) { error in
                    if let error = error {
                        debugPrint("Error while creating a connection answer: (\(error))")
                        completion(.failure(error))
                    }
                    debugPrint("Did create a connection answer")
                    completion(.success(SessionDescription(from: sdp)))
                }
            } else if let error = error {
                debugPrint("Error while creating a connection answer: (\(error))")
                completion(.failure(error))
            } else {
                fatalError("Inconsistent state reached while creating a connection offer to a peer")
            }
        }
    }

    func didGenerateIceCandidates(handler: @escaping (IceCandidate) -> ()) {
        iceCandidateGeneratedHandler = handler
    }

    func set(remoteSession: SessionDescription, completion: ((Result<Void, Error>) -> Void)?) {
        peerConnection.setRemoteDescription(RTCSessionDescription(codableModel: remoteSession)) { error in
            if let error = error {
                debugPrint("Error while trying to set a remote session: (\(error))")
                completion?(.failure(error))
            }
            completion?(.success(()))
        }
    }

    func add(remoteCandidate: IceCandidate) {
        peerConnection.add(RTCIceCandidate(codableModel: remoteCandidate))
    }

}

extension PeerConnection: RTCPeerConnectionDelegate {

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        debugPrint("peerConnection new signaling state: \(stateChanged)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        debugPrint("peerConnection did add stream")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        debugPrint("peerConnection did remove stream")
    }

    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        debugPrint("peerConnection should negotiate")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        debugPrint("peerConnection new connection state: \(newState.rawValue)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        debugPrint("peerConnection new gathering state: \(newState.rawValue)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        debugPrint("Did find an ICE candidate")
        iceCandidateGeneratedHandler?(IceCandidate(from: candidate))
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        debugPrint("peerConnection did remove candidate(s)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        debugPrint("peerConnection did open data channel")
    }

}

extension Media {

    func constraints() -> RTCMediaConstraints {
        var constraints: Dictionary<String, String> = [:]

        if contains(.audio) {
            constraints[kRTCMediaConstraintsOfferToReceiveAudio] = kRTCMediaConstraintsValueTrue
        }

        if contains(.video) {
            constraints[kRTCMediaConstraintsOfferToReceiveVideo] = kRTCMediaConstraintsValueTrue
        }

        return RTCMediaConstraints(mandatoryConstraints: constraints, optionalConstraints: nil)
    }

}
