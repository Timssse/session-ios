// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import CryptoSwift

class WalletCrypto{
    //MD5加密
    class func md5Encrypt(value:String) -> String?{
        guard let data = value.data(using: .utf8)  else{
            return nil
        }
        return data.md5().toHexString()
    }
}
