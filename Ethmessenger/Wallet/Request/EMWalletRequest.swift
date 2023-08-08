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
    
    var urlType : RequestUrlType = .customer

    var tokens : [EMTokenModel]
    
    var address : String
    
    func request() async throws -> [Any]{
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
        guard let ethAddress = EthereumAddress.init(address) else {throw HTTPError(code: -1, desc: "Address error")}
        let addre : [AnyObject] = ([ethAddress] as! [AnyObject])
        guard let encodedData = abiMethod?.encodeParameters(addre) else {throw HTTPError(code: -1, desc: "ABI error")}
        var jsonArr : [[String : Any]] = []
        for (index,token) in tokens.enumerated() {
            let params = ["to":token.contract,"from":address,"data":encodedData.toHexString().add0x] as [String : Any]
            let json = ["jsonrpc": "2.0",
                        "id": index + 1,
                        "method": "eth_call",
                        "params": [params,"latest"] as [Any]] as [String : Any]
            jsonArr.append(json)
        }
        let data = jsonArr.toData() ?? Data()
        let relust = try await self.fetchBodyAwait(data) as? String
        let arr = relust?.toArray() ?? []
        return arr
    }
}

struct WalletSearchTokenRequest: HTTPRequest {
    var url: String = "assets_type/search"
    
    var method: HTTPMethod = .post
    
    var headers: [String : String]? = nil
    
    var urlType : RequestUrlType = .wallet

    var chainId : Int
    
    var name : String
    
    func request() async throws -> Any{
        return try await self.fetchAwait(["chain_id":chainId,"keyword":name])
    }
}

struct TransferRecordRequest: HTTPRequest {
    var url: String = ""
    
    var urlType : RequestUrlType = .customer
    
    var method: HTTPMethod = .get
    
    var headers: [String : String]? = nil
}
