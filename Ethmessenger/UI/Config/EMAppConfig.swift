// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

var baseURLString = "https://fairapi.dappconnect.io/api/v1/"

let ETHSCAN = "https://api-cn.etherscan.com/api" //交易记录
let OPSCAN = "https://api-optimistic.etherscan.io/api";
let BSCSCAN = "https://api.bscscan.com/api";
let MATICSCAN = "https://api.polygonscan.com/api";
let ARBSCAN = "https://api.arbiscan.io/api";


let ETHApiKey = "RW3GNJWQI8GJXIK189G2GB11DGEE8S6UKK" //apikey
let OPApiKey = "1IXK6WEFAX6MKJ5UDSX4VBCFHZKZCQXTG2";
let BSCApiKey = "Y75KSE8J1BRMVXCQ9K11B24YX9NKRW9GTN";
let MATICApiKey = "RS31MYK3FR1JK5NCVD9FMQ2Q3XHU92GUIV";
let ARBApiKey = "CKGT65KM4GSMQRZZPMZUD5IS1YK3SZ8HZN";


/// app版本信息
struct AppInfo {
    static let shared = AppInfo()
    var version: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var numverVersion: String? {
        return version?.replacingOccurrences(of: ".", with: "")
    }
    var appName = "Fair Wallet"
    
}
