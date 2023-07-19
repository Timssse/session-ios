// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class UIUtil{
    
    private class func topVC () -> UIViewController? {
        let app = UIApplication.shared.delegate as? AppDelegate
        return presentedVC(topVC: app?.window?.rootViewController)
    }
    
    private class func presentedVC (topVC: UIViewController?) -> UIViewController? {
        if topVC == nil {
            return nil
        } else {
            if topVC!.presentedViewController != nil {
                return presentedVC(topVC: topVC!.presentedViewController)
            } else {
                if topVC?.isKind(of: UITabBarController.self) ?? false {
                    let tabVC = topVC as? UITabBarController
                    let selectedVC = tabVC?.selectedViewController
                    return selectedVC
                } else {
                   return topVC
                }
            }
        }
    }
    
    class func visibleVC() -> UIViewController? {
        return self.visibleNav()?.visibleViewController
    }

    class func visibleNav() -> UINavigationController? {
        let topVC = self.topVC()
        if topVC?.isKind(of: UINavigationController.self) ?? false {
            let navVC = topVC as? UINavigationController
            return navVC
        } else {
            return topVC?.navigationController
        }
    }
}
