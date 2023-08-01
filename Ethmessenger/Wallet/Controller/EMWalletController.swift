// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionUtilitiesKit
import Web3Core
import BigInt
import web3swift
struct EMWalletController{
    static func getConfig() async {
        guard let data = try? await WalletConfigRequest().request() as? HTTPJson else{
            if let config = EMWalletConfigModel.getConfig(){
                EMWalletConfigModel.shared = config
            }
            return
        }
        guard let relust = EMWalletConfigModel.deserialize(from: data) else{
            if let config = EMWalletConfigModel.getConfig(){
                EMWalletConfigModel.shared = config
            }
            return
        }
        EMWalletConfigModel.shared = relust
        EMWalletConfigModel.saveConfig(config: relust)
    }
    
    static func getTokenPrice() async{
        var symbol :[String] = []
        let tokens = EMTableToken.selectAll()
        for token in tokens {
            symbol.append(token.symbol)
        }
        let symbols = symbol.filterDuplicates({$0});
        guard let data = try? await WalletTokenPriceRequest(symbol: symbols).request() as? HTTPList else{
            return
        }
        guard let relust = [EMTokenModel].deserialize(from: data) as? [EMTokenModel] else{
            return
        }
        await EMWalletCache.shared.saveAllCoinModels(model: relust)
    }
    
    ///chainId == -1 All
    static func getTokensBalance(_ chainId : Int) async {
        var tokens : [EMTokenModel] = []
        if chainId == -1 {
            tokens = EMTableToken.selectAllMainToken()
        }else{
            tokens = EMTableToken.selectAllMainTokenWithChainId(chainId)
        }
        
        
        for token in tokens{
            let chain = EMChain(chainId: token.chain_id)
            let balance = try? await GetBalanceRequest(rpc: chain.rpc, chainId: token.chain_id, address: WalletUtilities.account.address, contractAddress: "").request()
            token.balance = Utilities.formatToPrecision(balance ?? BigUInt(0),units: .custom(token.decimals))
            EMTableToken.updateToken(token)
            await getSubTokensBalance(chain)
        }
        
        Thread.safe_main {
            NotificationCenter.default.post(name: kNotifyRefreshWallet, object: nil)
        }
    }
    
    static func getSubTokensBalance(_ chain : EMChain) async{
        var tokens = EMTableToken.selectTokenWithChainId(chain.chainId)
        for (index,value) in tokens.enumerated(){
            if value.contract == ""{
                tokens.remove(at: index)
                break
            }
        }
        guard let arr = try? await WalletTokenBlanceRequest(url: chain.rpc, tokens: tokens, address: WalletUtilities.account.address).request() as? HTTPList else{
            return
        }
        for data in arr {
            guard let id = data["id"] as? Int else{
                continue
            }
            guard let result = data["result"] as? String else{
                continue
            }
            let token = tokens[id-1]
            let balance = result.HexToDecimal()
            token.balance = balance.division(numberString: token.show_decimals)
            EMTableToken.updateToken(token)
        }
    }
    
    static func getBlockNumberRequest(_ rpc : String,chainId : Int) async -> BigUInt{
        return (try? await GetBlockNumberRequest(rpc: rpc, chainId: chainId).request()) ?? 0
    }
    
    static func getTokenInfo(_ chain : EMChain,token:String)async -> ERC20?{
        return try? await GetTokenInfoRequest(rpc: chain.rpc, chainId: chain.chainId, contractAddress: token).request()
    }
    
    
    static func searchToken(_ network : String,name : String) async -> [EMTokenModel]{
        guard let data = try? await WalletSearchTokenRequest(network: network, name: name).request() as? HTTPList else{
            return []
        }
        guard let relust = [EMTokenModel].deserialize(from: data) as? [EMTokenModel] else{
            return []
        }
        return relust
    }
    
    
    
}


