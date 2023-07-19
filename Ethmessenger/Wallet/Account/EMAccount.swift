// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

public struct EMAccount {
    var chain : EMPRCModel
    var address : String
    var privateKey : String
    init(chain: EMPRCModel = EMPRCModel.init(chainId: 1, rpc: ""), address: String, privateKey: String) {
        self.chain = chain
        self.address = address
        self.privateKey = privateKey
    }
}


