// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import Foundation

extension Thread {
    
    static func safe_main(_ block: @escaping ()->Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
}
