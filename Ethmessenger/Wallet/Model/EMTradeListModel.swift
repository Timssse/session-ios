// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import HandyJSON
import Web3Core
class EMTradeListModel: HandyJSON {
    var blockNumber = ""
    var timeStamp = ""
    var hash = ""
    var nonce = ""
    var blockHash = ""
    var transactionIndex = ""
    var from = ""
    var fromAddress = ""
    var to = ""
    var toAddress = ""
    var value = ""
    var gas = ""
    var gasPrice = ""
    var isError = ""
    var txreceipt_status = ""
    var input = ""
    var contractAddress = ""
    var cumulativeGasUsed = ""
    var gasUsed = ""
    var confirmations = ""
    var methodId = ""
    var functionName = ""
    var tokenName = ""
    var tokenSymbol = ""
    var tokenDecimal = ""
    ///网络
    var network = ""
    ///状态
    var status = 0
    
    
    var statusIcon : UIImage?{
        if (status == -1){
            //等待
            return UIImage(named: "icon_trade_wait")
        }
        if (isError != "0"){
            return UIImage(named: "icon_trade_fail")
        }
        if (from.lowercased() == WalletUtilities.address.lowercased()){
            //成功
            return UIImage(named: "icon_trade_send")
        }
        return UIImage(named: "icon_trade_recive")
    }
    
    
    var isSend : Bool{
        if (from.lowercased() == WalletUtilities.address.lowercased()){
            return true
        }
        return false
    }
    
    var showValue : String{
        var decimal = self.tokenDecimal.toInt()
        if (decimal == 0){
            decimal = 18
        }
//        let network = EMNetworkModel.getNetwork()
//        let chain = EMChain(chainId: network?.chain_id ?? 1)
//        var symbol = self.tokenSymbol == "" ? chain.getMainToken().symbol : self.tokenSymbol
        return (isSend ? "-" : "+") + self.value.division(numberString: decimal.getUnitWithDecimails()).toNumberFormatter()// + symbol
    }
    
    required init() {
    }
}
