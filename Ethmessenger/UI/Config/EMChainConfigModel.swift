// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import HandyJSON
class EMChainModel: HandyJSON {
    var chain_id = ""
    var chain_name = ""
    var chain_symbol = ""
    var browser = ""
    var currency = ""
    var icon = ""
    var currency_icon = ""
    var rpc : [EMRPCModel] = []
    var has_dapp = true
    var is_active = true
    var checked = false
    var isDefineNetWork = false
    var isSelected = false
    required init() {
        
    }
}


class EMRPCModel: HandyJSON {
    var name = ""
    var rpc = ""
    var blockHeight = ""
    var ms : Int = 0
    required init() {
        
    }
    
}
