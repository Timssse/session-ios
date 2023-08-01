// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import HandyJSON
import web3swift
class EMTokenModel: HandyJSON {
    required init () {}
    var id = ""
    var icon = ""
    var symbol = ""
    var assets_name = ""
    var chain_id = 1
    var decimals = 0
    var balance = ""
    var sort = 0
    var contract = ""
    var walletAddress = "" //记录钱包地址
    var price = ""
   
    ///查询费率 默认用合约地址contract 如果没有合约地址 使用币名
    var showContractAddress : String{
        if self.contract.count != 0 {
            return self.contract
        }
        return assets_name
    }
    
    var show_decimals: String{
        var  decimalStr = "1"
        for _ in 0..<decimals  {
            decimalStr += "0"
        }
       return decimalStr
    }
    
    var fw_money_attributeStr : NSMutableAttributedString{
        let str = NSMutableAttributedString(string: FS(balance).toNumberFormatter(), attributes: [NSAttributedString.Key.kern:1])
           return str
       }
    
    var fw_num_rmb :String{
        let relust = self.price.take(numberString: EMWalletConfigModel.shared.usd2cny).take(numberString: balance)
        return relust
    }
    
    var fw_price_rmb :String{
        return self.price.take(numberString: EMWalletConfigModel.shared.usd2cny)
    }
    
    var rmbStr : String{
        get{
            let rate = EMWalletConfigModel.shared.usd2cny
            let RMBStr = rate.take(numberString: self.price).take(numberString: self.balance).toNumberFormatter(true)
            return RMBStr
        }
    }
    
    var RMB : String = ""
    
    ///是否是主网币
    var isMainNetwork : Bool {
        if self.contract == "" {
            return true
        }
        return false
    }
}

extension EMTokenModel{
    
    static let ETH: EMTokenModel = {
        let rs = EMTokenModel()
//        rs.id = "1"
        rs.symbol = "ETH"
        rs.assets_name = "Ethereum"
        rs.icon = "https://fair-w.oss-cn-hangzhou.aliyuncs.com/image/eth.png"
        rs.chain_id = 1
        rs.decimals = 18
        rs.sort = -1
        return rs
    }()
    
    static let BSC: EMTokenModel = {
        let rs = EMTokenModel()
//        rs.id = "35"
        rs.symbol = "BNB"
        rs.assets_name = "BNB"
        rs.icon = "https://fair-w.oss-cn-hangzhou.aliyuncs.com/image/bnb.png"
        rs.chain_id = 56
        rs.decimals = 18
        rs.sort = -1
        return rs
    }()
    
    static let OP: EMTokenModel = {
        let rs = EMTokenModel()
//        rs.id = "10"
        rs.symbol = "ETH"
        rs.assets_name = "Ethereum"
        rs.icon = "https://fair-w.oss-cn-hangzhou.aliyuncs.com/image/eth.png"
        rs.chain_id = 10
        rs.decimals = 18
        rs.sort = -1
        return rs
    }()
    
    static let ARB: EMTokenModel = {
        let rs = EMTokenModel()
//        rs.id = "42161"
        rs.symbol = "ETH"
        rs.assets_name = "Ethereum"
        rs.icon = "https://fair-w.oss-cn-hangzhou.aliyuncs.com/image/eth.png"
        rs.chain_id = 42161
        rs.decimals = 18
        rs.sort = -1
        return rs
    }()
    
    static let MATIC: EMTokenModel = {
        let rs = EMTokenModel()
//        rs.id = "60"
        rs.symbol = "MATIC"
        rs.assets_name = "Polygon(Matic)"
        rs.icon = "https://fair-w.oss-cn-hangzhou.aliyuncs.com/image/matic.png"
        rs.chain_id = 137
        rs.decimals = 18
        rs.sort = -1
        return rs
    }()
    
    static func create(_ token : ERC20,chainID : Int) -> EMTokenModel{
        let rs = EMTokenModel()
        rs.symbol = FS(token.symbol)
        rs.assets_name = FS(token.name)
        rs.chain_id = chainID
        rs.decimals = FS(token.decimals).toInt()
        return rs
    }
    
}

class webEthModel: HandyJSON {
    var id : Int = 0
    var name = ""
    var object = webEthObjcModel()
    required init () {}
}

class webEthObjcModel: HandyJSON {
    var chainType = ""
    var from = ""
    var gas = ""
    var to = ""
    var value = "0"
    var data = ""
    var gasPrice = ""
    var chainId = ""
    required init () {}
}
