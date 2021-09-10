//
// Created by Felipe Lobo on 23/08/21.
//

import Foundation
import UIKit

protocol Window {

    func makeRoot(view: View) throws

    func makeKeyAndVisible()

}

extension UIWindow: Window {

    enum UIWindowRootViewError: Error {
        case notAnUIKitView
    }

    func makeRoot(view: View) throws {
        guard let viewController = view as? UIViewController else {
            throw UIWindowRootViewError.notAnUIKitView
        }

        rootViewController = viewController
    }

}
