// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.


import UIKit
import SessionUIKit
//MARK: 尺寸
let Screen_width = UIScreen.main.bounds.size.width
let Screen_height = UIScreen.main.bounds.size.height

let icon_default = UIImage(named: "icon_community_default")

/// 安全区底部高度
var safeBottomH : CGFloat{
    let height:CGFloat = ThemeManager.mainWindow?.safeAreaInsets.bottom ?? 10
    return height
}

var statusBarH : CGFloat{
    let height:CGFloat = ThemeManager.mainWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    return height
}

var fullNavigationBarH: CGFloat {
    let height = statusBarH + 44.0
    return height
}



