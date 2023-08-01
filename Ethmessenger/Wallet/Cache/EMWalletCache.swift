// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMWalletCache: NSObject {
    
    static let shared = EMWalletCache()
    private let defalults = UserDefaults.standard
        
    func saveAllCoinModels(model: [EMTokenModel]?) async{
        guard let model = model else {
            return
        }
        //更新价格
        let allToken = EMTableToken.selectAll()
        for token in allToken {
            for item in model {
                //查询合约地址是否一致
                if (item.contract.lowercased() == token.contract.lowercased() && item.symbol == token.symbol){
                    token.price = item.price
                    token.contract = item.contract
                    EMTableToken.updateToken(token)
                    break
                }
            }
        }
        Thread.safe_main {
            NotificationCenter.default.post(name: kNotifyRefreshWallet, object: nil)
        }
    }
    
    private let kETHRPC = "kETHRPC"
    var ethRPC : String{
        get{
            let value = defalults.string(forKey: kETHRPC)
            return value ?? "https://rpc.ankr.com/eth"
        }
        set{
            defalults.set(newValue, forKey: kETHRPC)
            defalults.synchronize()
        }
    }
    
    private let kBSCRPC = "kBSCRPC"
    var bscRPC : String{
        get{
            let value = defalults.string(forKey: kBSCRPC)
            return value ?? "https://bsc-dataseed1.binance.org"
        }
        set{
            defalults.set(newValue, forKey: kBSCRPC)
            defalults.synchronize()
        }
    }
    
    private let kMaticRPC = "kMaticRPC"
    var maticRPC : String{
        get{
            let value = defalults.string(forKey: kMaticRPC)
            return value ?? "https://rpc-mainnet.matic.network"
        }
        set{
            defalults.set(newValue, forKey: kMaticRPC)
            defalults.synchronize()
        }
    }
    
    private let kOPRPC = "kOPRPC"
    var opRPC : String{
        get{
            let value = defalults.string(forKey: kOPRPC)
            return value ?? "https://mainnet.optimism.io"
        }
        set{
            defalults.set(newValue, forKey: kOPRPC)
            defalults.synchronize()
        }
    }
    
    private let kARBRPC = "kARBRPC"
    var arbRPC : String{
        get{
            let value = defalults.string(forKey: kARBRPC)
            return value ?? "https://rpc.ankr.com/arbitrum"
        }
        set{
            defalults.set(newValue, forKey: kARBRPC)
            defalults.synchronize()
        }
    }
    
    private let kMoneyVisiable = "kMoneyVisiable"
    var isMoneyVisiable : Bool{
        get{
            return defalults.bool(forKey: kMoneyVisiable)
        }
        set{
            defalults.set(newValue, forKey: kMoneyVisiable)
            defalults.synchronize()
        }
    }
    
    //计价单位
    private var _priceUnit : EMChargeUnitModel?
    var priceUnit : EMChargeUnitModel{
        get{
            if (_priceUnit != nil){
                return _priceUnit!
            }
            let json: String? = UserDefaults.standard.string(forKey: "kPriceUnit")
            if let model = EMChargeUnitModel.deserialize(from: json) {
                EMWalletConfigModel.shared.usd2cny = model.price
                _priceUnit = model
                return model
            }
            let model = getUnitModel(EMLocalizationTool.getLanguageSymbol(EMLocalizationTool.shared.currentLanguage))
            _priceUnit = model
            return model
        }
        set{
            _priceUnit = newValue
            var usd2usdt = EMWalletConfigModel.shared.usd2usdt
            if usd2usdt.toDouble() > 0 {
                usd2usdt = "1".division(numberString: usd2usdt)
                _priceUnit?.price = _priceUnit?.price.take(numberString: usd2usdt) ?? ""
            }
            if let json = _priceUnit?.toJSONString() {
                EMWalletConfigModel.shared.usd2cny = _priceUnit?.price ?? ""
                UserDefaults.standard.set(json, forKey: "kPriceUnit")
                EMWalletConfigModel.saveConfig(config: EMWalletConfigModel.shared)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    func getUnitModel(_ symbol : String) -> EMChargeUnitModel {
        let arr = EMWalletConfigModel.shared.rates
        for item in arr {
            if item.symbol == symbol {
                return item
            }
        }
        let model = EMChargeUnitModel()
        model.symbol = "CNY"
        model.mark = "¥"
        model.price = EMWalletConfigModel.shared.usd2cny
        return model
    }
}
