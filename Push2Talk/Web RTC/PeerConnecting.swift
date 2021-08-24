//
// Created by Felipe Lobo on 24/08/21.
//

import Foundation

struct Media: OptionSet {
    static let audio = Media(rawValue: 1 << 0)
    static let video = Media(rawValue: 1 << 1)
    static let data = Media(rawValue: 1 << 2)

    let rawValue: Int
}

protocol PeerConnecting: AnyObject {

    func offer(media: Media, completion: @escaping (Result<SessionDescription, Error>) -> Void)

    func answer(media: Media, completion: @escaping (Result<SessionDescription, Error>) -> Void)

    func didGenerateIceCandidates(handler: @escaping (IceCandidate) -> Void)

    func set(remoteSession: SessionDescription, completion: ((Result<Void, Error>) -> Void)?)

    func add(remoteCandidate: IceCandidate)

}
