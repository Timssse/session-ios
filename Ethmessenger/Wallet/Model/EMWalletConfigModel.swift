// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import HandyJSON

struct EMWalletConfigModel: HandyJSON {
    
    static var shared = EMWalletConfigModel()
    
    var contact = EMContractUsModel()
    var network = [EMNetworkModel]()
    var website = ""
    var usd2cny = ""
    var usd2usdt = ""
    var version : String?
    var rates : [EMChargeUnitModel] = []
    
    
    private static let kSaveConfig = "kSaveConfig"
    static func saveConfig(config: EMWalletConfigModel) {
        if let json = config.toJSONString() {
            UserDefaults.standard.set(json, forKey: kSaveConfig)
            UserDefaults.standard.synchronize()
        }
    }
    
    static func getConfig() -> EMWalletConfigModel? {
        let json: String? = UserDefaults.standard.string(forKey: kSaveConfig)
        if let value = EMWalletConfigModel.deserialize(from: json) {
            return value
        }
        return nil
    }
}


class EMNetworkModel: HandyJSON {
//    var network_type = ""
    var chain_id = 1
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
    
    var chain : EMChain{
        return EMChain.init(chainId: chain_id)
    }
    
    private static let kSaveNetwork = "kSaveNetwork"
    static func save(network: EMNetworkModel) {
        WalletUtilities.account.chain = network.chain
        if let json = network.toJSONString() {
            UserDefaults.standard.set(json, forKey: kSaveNetwork)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: kNotifychangeChain, object: nil)
        }
    }
    
    static func getNetwork() -> EMNetworkModel? {
        let json: String? = UserDefaults.standard.string(forKey: kSaveNetwork)
        if let value = EMNetworkModel.deserialize(from: json) {
            return value
        }
        return nil
    }
    
    required init() {
        
    }
}

class EMRPCModel: HandyJSON {
    var name = ""
    var rpc = ""
    ////
    var blockHeight = ""
    var ms : Int = 0
    required init() {
        
    }
    
}

class EMChargeUnitModel: HandyJSON {
    var title = ""
    var symbol = ""
    var mark = ""
    var price = ""
    required init() {
        
    }
}

struct EMContractUsModel: HandyJSON {
    var email = ""
    var twitter = ""
    var telegram  = ""
    var wechat = ""
    var facebook = ""
}
