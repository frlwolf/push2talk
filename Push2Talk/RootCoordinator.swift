//
// Created by Felipe Lobo on 23/08/21.
//

import Foundation

final class RootCoordinator {

    func start(window: Window) {
        let viewController = RootViewController()

        try? window.makeRoot(view: viewController)
        window.makeKeyAndVisible()
    }

}
