// Copyright © 2022 Rangeproof Pty Ltd. All rights reserved.

import UIKit

///隐藏导航栏
public protocol EMHideNavigationBarProtocol where Self: UIViewController {}

public class StyledNavigationController: UINavigationController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return (
            self.topViewController?.preferredStatusBarStyle ??
            ThemeManager.currentTheme.statusBarStyle
        )
    }
}

extension StyledNavigationController : UINavigationControllerDelegate{
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if (viewController is EMHideNavigationBarProtocol){
            navigationController.setNavigationBarHidden(true, animated: true)
        } else {
            navigationController.setNavigationBarHidden(false, animated: true)
        }
    }
}
