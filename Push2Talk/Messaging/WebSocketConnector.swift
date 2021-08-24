//
// Created by Felipe Lobo on 23/08/21.
//

import Foundation
import Network

final class WebSocketConnector: NSObject, ConnectionRelay {

    private var urlSession: URLSession!
    private var socketTask: URLSessionWebSocketTask?

    deinit {
        socketTask?.cancel()
    }

    init(url: URL = URL(string: "ws://169.254.97.113:8080")!) {
        super.init()

        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

        let socketTask = urlSession.webSocketTask(with: url)
        socketTask.resume()

        self.socketTask = socketTask
    }

    func receive(handler: @escaping (Data) -> ()) {
        socketTask?.receive { result in
            switch result {
            case .success(let message):
                if case .data(let data) = message {
                    debugPrint("Did receive a websocket data message (\(data))")
                    handler(data)
                } else if case .string(let string) = message {
                    debugPrint("WebSocket message was not of the data type, discarding result: \(string)")
                    break
                } else {
                    break
                }
            case .failure(let error):
                debugPrint("Error while receiving websocket message: \(error)")
            }
        }
    }

    func send(data: Data) {
        socketTask?.send(.data(data)) { error in
            if let error = error {
                debugPrint("Error while sending websocket data: \(error)")
            } else {
                debugPrint("Did send a websocket data message \(data)")
            }
        }
    }

}

extension WebSocketConnector: URLSessionWebSocketDelegate, URLSessionDelegate {

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?) {
        debugPrint("Start websocket connection (\(`protocol`))...")
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        debugPrint("Connection closed, with close code (\(closeCode))")
        socketTask?.cancel()
    }

}
