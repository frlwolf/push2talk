//
// Created by Felipe Lobo on 24/08/21.
//

import Foundation
import WebRTC
import AVFAudio

protocol AudioStream {

    func startStreaming()

    func stopStreaming()

}

final class AudioSession {

    private let sharedAudioSession = RTCAudioSession.sharedInstance()
    private let audioQueue = DispatchQueue(label: "liveAudio")

}

extension AudioSession: AudioStream {

    func startStreaming() {
        audioQueue.async { [sharedAudioSession] in
            sharedAudioSession.lockForConfiguration()
            do {
                try sharedAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
                try sharedAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
                try sharedAudioSession.overrideOutputAudioPort(.speaker)
                try sharedAudioSession.setActive(true)
                sharedAudioSession.isAudioEnabled = true
            } catch {
                debugPrint("Error while setting up Audio Session: \(error)")
            }
            sharedAudioSession.unlockForConfiguration()
        }
    }

    func stopStreaming() {
        audioQueue.async { [sharedAudioSession] in
            sharedAudioSession.lockForConfiguration()
            do {
                try self.sharedAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
                try self.sharedAudioSession.overrideOutputAudioPort(.none)
            } catch {
                debugPrint("Error setting AVAudioSession category: \(error)")
            }
        }
    }

}


