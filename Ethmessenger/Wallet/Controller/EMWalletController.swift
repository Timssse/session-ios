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
            if let mainToken = EMTableToken.selectMainTokenWithChainId(chainId) {
                tokens = [mainToken]
            }
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
        if tokens.count == 0{
            return
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
    
    
    static func searchToken(_ chainID : Int,name : String) async -> [EMTokenModel]{
        guard let data = try? await WalletSearchTokenRequest(chainId: chainID, name: name).request() as? HTTPList else{
            return []
        }
        guard let relust = [EMTokenModel].deserialize(from: data) as? [EMTokenModel] else{
            return []
        }
        return relust
    }
    
    static func getTokensBalance(_ token : EMTokenModel) async -> String {
        let chain = EMChain(chainId: token.chain_id)
        let balance = try? await GetBalanceRequest(rpc: chain.rpc, chainId: token.chain_id, address: WalletUtilities.account.address, contractAddress: token.contract).request()
        token.balance = Utilities.formatToPrecision(balance ?? BigUInt(0),units: .custom(token.decimals))
        EMTableToken.updateToken(token)
        return token.balance
    }
    
    static func getGasPrice(_ chainId : Int) async -> BigUInt {
        let chain = EMChain(chainId: chainId)
        let gasPrice = try? await GetGasPriceRequest(rpc: chain.rpc, chainId: chainId).request()
        return gasPrice ?? 0
    }
    
    static func getGasLimit(transNum : String = "0",token : EMTokenModel,toAddress : String = "",gasPrice : BigUInt = 0) async -> BigUInt {
        let chain = EMChain(chainId: token.chain_id)
        if token.contract == ""{
            let gasLimit = try? await GetMainTokenGasLimitRequest(rpc: chain.rpc, chainId: token.chain_id, transnum: transNum, token: token, fromAddress: WalletUtilities.address, toAddress: toAddress, gasPrice: gasPrice).request()
            return gasLimit ?? 0
        }
        let gasLimit = try? await GetTokenGasLimtRequest(rpc: chain.rpc, chainId: token.chain_id, transnum: transNum, from: WalletUtilities.account.address, to: toAddress, gasPrice: gasPrice, token: token).request()
        return gasLimit ?? 0
    }
    
    ///转账 返回交易hash 为空就说明失败了
    static func send(toAddress:String,num:String,token:EMTokenModel,gas:EMCostFeeModel) async throws -> String?{
        let chain = EMChain(chainId: token.chain_id)
        let transferResult = try await TransferRequest(rpc: chain.rpc, chainId: chain.chainId, fromAddress: WalletUtilities.address, to: toAddress, token: token, num: num, gas: gas).request()
        return transferResult.hash
    }
    
    
    //处理历史记录
    static func tradeHistoryRequest(address: String,
                                   url: String,
                                   apiKey: String,
                                   page: Int,
                                   contractaddress : String = "") async -> [EMTradeListModel] {
        if (url == ""){
            return []
        }
        var parame = ["module" : "account",
                     "action":contractaddress == "" ? "txlist" : "tokentx",
                     "address":address,
                      "offset":"10","page":"\(page)",
                      "startblock":"0",
                      "endblock":"9999999999999",
                      "sort":"desc",
                      "apikey":apiKey]
        if (contractaddress.count > 0){
            parame["contractaddress"] = contractaddress
        }
        guard let result = try? await TransferRecordRequest(url: url).fetchAwait(parame) as? HTTPList else {
            return []
        }
        return ([EMTradeListModel].deserialize(from: result) as? [EMTradeListModel]) ?? []
    }
}


