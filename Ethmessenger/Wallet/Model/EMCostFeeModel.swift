// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import BigInt
import Web3Core
struct EMCostFeeModel {
    var gasPrice : BigUInt
    var gasLimit : BigUInt
    init(gasPrice: BigUInt, gasLimit: BigUInt) {
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
    }
    
    func getGasFee() -> String{
        return Utilities.formatToPrecision(self.gasPrice * self.gasLimit,units: .ether)
    }
}
