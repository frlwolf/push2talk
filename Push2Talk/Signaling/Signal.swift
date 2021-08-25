//
// Created by Felipe Lobo on 23/08/21.
//

import Foundation

enum Signal {
    case sessionDescription(SessionDescription)
    case iceCandidate(IceCandidate)
}

extension Signal: Codable {

    enum CodingKeys: String, CodingKey {
        case type, payload
    }

    enum DecodeError: Error {
        case unknownMessageType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case String(describing: SessionDescription.self):
            self = .sessionDescription(try container.decode(SessionDescription.self, forKey: .payload))
        case String(describing: IceCandidate.self):
            self = .iceCandidate(try container.decode(IceCandidate.self, forKey: .payload))
        default:
            throw DecodeError.unknownMessageType
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .sessionDescription(let sessionDescription):
            try container.encode(sessionDescription, forKey: .payload)
            try container.encode(String(describing: SessionDescription.self), forKey: .type)
        case .iceCandidate(let iceCandidate):
            try container.encode(iceCandidate, forKey: .payload)
            try container.encode(String(describing: IceCandidate.self), forKey: .type)
        }
    }

}
