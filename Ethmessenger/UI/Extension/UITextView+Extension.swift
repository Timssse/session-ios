// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionUIKit

extension UITextView{
    convenience init(_ text : String? = nil , font : UIFont? = nil , textColor : ThemeValue? = nil) {
        self.init()
        if let font = font {
            self.font = font
        }
        if let textColor = textColor {
            self.themeTextColor = textColor
        }
        self.text = text
        
    }
}
