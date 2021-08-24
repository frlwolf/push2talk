//
// Created by Felipe Lobo on 23/08/21.
//

import Foundation

protocol ConnectionRelay {

    func receive(handler: @escaping (Data) -> Void)

    func send(data: Data)

}
