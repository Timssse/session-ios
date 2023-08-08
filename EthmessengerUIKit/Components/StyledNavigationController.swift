// Copyright © 2022 Rangeproof Pty Ltd. All rights reserved.

import UIKit

///隐藏导航栏
public protocol EMHideNavigationBarProtocol where Self: UIViewController {}

public class StyledNavigationController: UINavigationController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.openLeftBack()
        self.delegate = self
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return (
            self.topViewController?.preferredStatusBarStyle ??
            ThemeManager.currentTheme.statusBarStyle
        )
    }
    
    //MARK: 开启左滑返回
    func openLeftBack(){
        self.interactivePopGestureRecognizer?.delegate = self
    }
    
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
}

extension StyledNavigationController : UINavigationControllerDelegate,UIGestureRecognizerDelegate{
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if (viewController is EMHideNavigationBarProtocol){
            navigationController.setNavigationBarHidden(true, animated: true)
        } else {
            navigationController.setNavigationBarHidden(false, animated: true)
        }
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.interactivePopGestureRecognizer {
            if self.viewControllers.count <= 1 {
                return false
            }else{
                return true
            }
        }
        return false
    }
    
}
