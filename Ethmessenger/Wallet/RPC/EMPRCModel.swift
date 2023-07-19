// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

struct EMPRCModel {
    var chainId : Int
    var rpc : String
    init(chainId: Int, rpc: String) {
        self.chainId = chainId
        self.rpc = rpc
    }
}
