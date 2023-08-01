// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import web3swift
import Web3Core

struct WalletConfigRequest: HTTPRequest {
    var url: String = "app_config"
    
    var method: HTTPMethod = .get
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .wallet

    func request() async throws -> Any{
        return try await self.fetchAwait()
    }
}

struct WalletTokenPriceRequest: HTTPRequest {
    var url: String = "assets_type/coins_price"
    
    var method: HTTPMethod = .post
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .wallet

    var symbol : [String]
    
    func request() async throws -> Any{
        return try await self.fetchAwait(["symbol":symbol.joined(separator: ",")])
    }
}

struct WalletTokenBlanceRequest: HTTPRequest {
    var url: String = ""
    
    var method: HTTPMethod = .post
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .wallet

    var tokens : [EMTokenModel]
    
    var address : String
    
    func request() async throws -> Any{
        var abiMethod : ABI.Element?
        let abiStr = Web3.Utils.erc20ABI
        let jsonData = abiStr.data(using: .utf8)
        let abi = try JSONDecoder().decode([ABI.Record].self, from: jsonData!)
        let abiNative = try abi.map({ (record) -> ABI.Element in
            return try record.parse()
        })
        for m in abiNative {
            switch m {
            case .function(let function):
                guard let name = function.name else {continue}
                if name == "balanceOf"{
                    abiMethod = m
                    break
                }
                
            default:
                continue
            }
        }
        guard let address = EthereumAddress.init(address) else {throw HTTPError(code: -1, desc: "Address error")}
        let addre : [AnyObject] = ([address] as! [AnyObject])
        guard let encodedData = abiMethod?.encodeParameters(addre) else {throw HTTPError(code: -1, desc: "ABI error")}
        var jsonArr : [[String : Any]] = []
        for (index,token) in tokens.enumerated() {
            let params : [String : Any] = ["to":token.contract,"from":address,"data":encodedData.toHexString().add0x]
            let json = ["jsonrpc": "2.0",
                        "id": index + 1,
                        "method": "eth_call",
                        "params": [params,"latest"] as [Any]] as [String : Any]
            jsonArr.append(json)
        }
        let data = (try?JSONSerialization.data(withJSONObject: jsonArr, options: [])) ?? Data()
        return try await self.fetchBodyAwait(data)
    }
}

struct WalletSearchTokenRequest: HTTPRequest {
    var url: String = "assets_type/search"
    
    var method: HTTPMethod = .post
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .wallet

    var network : String
    
    var name : String
    
    func request() async throws -> Any{
        return try await self.fetchAwait(["network":network,"name":name])
    }
}
