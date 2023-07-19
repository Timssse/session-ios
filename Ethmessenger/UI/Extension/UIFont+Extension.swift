// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

extension UIFont{
    static func Bold(size:CGFloat) ->UIFont {
        return UIFont.init(name: "PingFangSC-Semibold", size: size.w) ?? UIFont.boldSystemFont(ofSize: size.w)
    }
    static func Medium(size:CGFloat) ->UIFont {
        return UIFont.init(name: "PingFangSC-Medium", size: size.w) ?? UIFont.boldSystemFont(ofSize: size.w)
    }
    static func Heavy(size:CGFloat) ->UIFont {
        return UIFont.init(name: "PingFangSC-Heavy", size: size.w) ?? UIFont.boldSystemFont(ofSize: size.w)
    }
    static func Regular(size:CGFloat) ->UIFont {
        return UIFont.init(name: "PingFangSC-Regular", size: size.w) ?? UIFont.boldSystemFont(ofSize: size.w)
    }
}
