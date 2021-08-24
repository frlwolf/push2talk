//
// Created by Felipe Lobo on 23/08/21.
//

import Foundation
import WebRTC

struct IceCandidate {

    let sessionDescription: String
    let mediaLineIndex: Int32
    let mediaStreamId: String?

}

extension IceCandidate {

    init(from iceCandidate: RTCIceCandidate) {
        sessionDescription = iceCandidate.sdp
        mediaLineIndex = iceCandidate.sdpMLineIndex
        mediaStreamId = iceCandidate.sdpMid
    }

}

extension RTCIceCandidate {

    convenience init(codableModel ic: IceCandidate) {
        self.init(sdp: ic.sessionDescription, sdpMLineIndex: ic.mediaLineIndex, sdpMid: ic.mediaStreamId)
    }

}

extension IceCandidate: Codable {

    enum CodingKeys: String, CodingKey {
        case sdp, sdpMLineIndex, sdpMid
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        sessionDescription = try container.decode(String.self, forKey: .sdp)
        mediaLineIndex = try container.decode(Int32.self, forKey: .sdpMLineIndex)
        mediaStreamId = try container.decodeIfPresent(String.self, forKey: .sdpMid)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(sessionDescription, forKey: .sdp)
        try container.encode(mediaLineIndex, forKey: .sdpMLineIndex)
        try container.encode(mediaStreamId, forKey: .sdpMid)
    }

}
