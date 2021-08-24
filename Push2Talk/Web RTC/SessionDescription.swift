//
// Created by Felipe Lobo on 23/08/21.
//

import Foundation
import WebRTC

struct SessionDescription {

    enum SdpType: String, Codable {
        case offer, prAnswer, answer
    }

    let stringValue: String
    let type: SdpType

}

extension SessionDescription {

    init(from rtcSdp: RTCSessionDescription) {
        stringValue = rtcSdp.sdp

        let typeString = RTCSessionDescription.string(for: rtcSdp.type)
        type = SessionDescription.SdpType(rawValue: typeString)!
    }

}

extension RTCSessionDescription {

    convenience init(codableModel sdp: SessionDescription) {
        self.init(type: Self.type(for: sdp.type.rawValue), sdp: sdp.stringValue)
    }

}

extension SessionDescription: Codable {

    enum CodingKeys: String, CodingKey {
        case sdp, type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        stringValue = try container.decode(String.self, forKey: .sdp)
        type = try container.decode(SdpType.self, forKey: .type)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(stringValue, forKey: .sdp)
        try container.encode(type, forKey: .type)
    }

}
