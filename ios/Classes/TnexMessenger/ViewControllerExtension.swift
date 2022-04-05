//
//  ViewControllerExtension.swift
//  tnex_chat
//
//  Created by MacOS on 25/02/2022.
//

import Foundation

extension UIViewController {

    @discardableResult
    class func visibleViewController() -> UIViewController? {
        let rootViewController = UIApplication.key?.rootViewController
        return self.getVisibleViewController(from: rootViewController)
    }

    class func getVisibleViewController(from vc: UIViewController?) -> UIViewController? {
        if vc is UINavigationController {
            return self.getVisibleViewController(from: (vc as? UINavigationController)?.visibleViewController)
        }
        else if let tab = vc as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return getVisibleViewController(from: top)
            } else if let selected = tab.selectedViewController {
                return getVisibleViewController(from: selected)
            }
            return nil
        }
        else {
            if vc?.presentedViewController != nil {
                return self.getVisibleViewController(from: vc?.presentedViewController)
            } else {
                return vc
            }
        }
    }
}

extension UIApplication {

    public static var key: UIWindow? {
      if #available(iOS 13, *) {
         return UIApplication.shared.windows.first { $0.isKeyWindow }
      } else {
         return UIApplication.shared.keyWindow
      }
    }
    
    public var isKeyboardPresented: Bool {
        if let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow"),
            self.windows.contains(where: { $0.isKind(of: keyboardWindowClass) }) {
            return true
        } else {
            return false
        }
    }
}
