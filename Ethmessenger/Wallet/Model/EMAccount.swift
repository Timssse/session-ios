// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

public struct EMAccount {
    var chain : EMChain
    var address : String
    var privateKey : String
    var mnemonic : String
    init(chain: EMChain = EMChain( chainId: 1), address: String, privateKey: String, mnemonic: String) {
        self.chain = chain
        self.address = address
        self.privateKey = privateKey
        self.mnemonic = mnemonic
    }
    
    //钱包密码 md5加密 不需要知道具体值 拿来直接比较就行
    let kWalletPassword = "kWalletPassword"
    var password : String?{
        get{
            let value = UserDefaults.standard.value(forKey: kWalletPassword)
            return value as? String
        }
        set{
            guard let password = newValue else{
                return
            }
            guard let result = WalletCrypto.md5Encrypt(value: password) else{
                return
            }
            UserDefaults.standard.setValue(result, forKey: kWalletPassword)
            UserDefaults.standard.synchronize()
        }
    }
    
}
