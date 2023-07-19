// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import Foundation
import web3swift
import Web3Core
import BigInt


class WalletERC20Request{
    
    //Mark:查询节点是否可用
    class func checkRPCIsVisableRequest(rpc : String,chainId:Int) async -> Bool {
        guard let newUrl = URL(string: rpc) else {
            return false
        }
        guard let we3P = try? await Web3HttpProvider(url:newUrl, network: Networks.Custom(networkID: BigUInt(chainId))) else {
            return false
        }
        
        let request: APIRequest = .blockNumber
        guard let response: APIResponse<BigUInt> = try? await APIRequest.sendRequest(with: we3P, for: request)else{
            return false
        }
        return response.result != 0
    }
    
    //获取Gas
    class func getGasRequest(rpc: String,
                             chainId: Int,
                             decimal:Int = 9)async throws -> BigUInt? {
        guard let newUrl = URL(string:rpc) else {
            throw WalletError.rpcError(desc: nil)
        }
        guard let we3P = try? await Web3HttpProvider(url: newUrl, network: Networks.Custom(networkID: BigUInt(chainId))) else {
            throw WalletError.rpcError(desc: nil)
        }
        let request: APIRequest = .gasPrice
        guard let response: APIResponse<BigUInt> = try? await APIRequest.sendRequest(with: we3P, for: request)else{
            throw WalletError.unknownError
        }
        return response.result
    }
    
    ///预估主网gaslimit 目前只有arb需要
    class func getMainGasLimit(account: EMAccount,
                           transnum : String,
                           decimal:Int = 18,
                               gasPrice:BigUInt,
                           fromAddress : String,
                           toAddress:String) async throws -> BigUInt?{
        guard let web = try? await createWeb3(account: account) else{
            throw WalletError.rpcError(desc: nil)
        }
        guard let finalTransaction = self.createTransaction(transnum: transnum, decimal: decimal, gasPrice: gasPrice, fromAddress: fromAddress, toAddress: toAddress == "" ? "0x0000000000000000000000000000000000000001" : toAddress, chainId: account.chain.chainId) else{
            throw WalletError.inputError(desc: "tx error")
        }
        let request: APIRequest = .estimateGas(finalTransaction, finalTransaction.callOnBlock ?? .latest)
        guard let response: APIResponse<BigUInt> = try? await APIRequest.sendRequest(with: web.provider, for: request)else{
            return nil
        }
        return response.result
    }
    
    class func getContractGasLimtRequest(finalTransaction: CodableTransaction,
                                         web3Provider: Web3Provider) async throws -> BigUInt{
        
        let request: APIRequest = .estimateGas(finalTransaction, finalTransaction.callOnBlock ?? .latest)
        let response: APIResponse<BigUInt> = try await APIRequest.sendRequest(with: web3Provider, for: request)
        return response.result
    }
    
    //查询token余额
    class func getBalanceRequest(account: EMAccount,
                                      contractAddress: String)async throws -> BigUInt? {
        if contractAddress.count == 0 {
            return try? await self.mainTokenBalanceRequest(address: account.address, url: account.chain.rpc,chainID: account.chain.chainId)
        }
        guard let web = try? await createWeb3(account: account) else{
            throw WalletError.rpcError(desc: nil)
        }
        guard let walletAddress = EthereumAddress(account.address) else {
            throw WalletError.addressError(desc: "address Error")
        }
        guard let eAddress = EthereumAddress(contractAddress) else {
            throw WalletError.addressError(desc: "token Error")
        }
        let erc20token = ERC20.init(web3: web, provider:web.provider, address: eAddress)
        return try? await erc20token.getBalance(account: walletAddress)
    }
    
    //查询主网币余额
    private class func mainTokenBalanceRequest(address: String,
                                               url: String,chainID:Int) async throws -> BigUInt? {
        guard let newUrl = URL(string: url) else {
            throw WalletError.rpcError(desc: nil)
        }
        guard let we3P = try? await Web3HttpProvider(url:newUrl,network: Networks.Custom(networkID: BigUInt(chainID))) else {
            throw WalletError.rpcError(desc: nil)
        }
        let request: APIRequest = .getBalance(address, .latest)
        guard let response: APIResponse<BigUInt> = try? await APIRequest.sendRequest(with: we3P, for: request)else{
            return nil
        }
        return response.result
    }
    
    
}

extension WalletERC20Request{
    class func createTransaction(transnum:String,decimal : Int,gasPrice : BigUInt ,fromAddress : String,toAddress : String,chainId : Int) -> CodableTransaction?{
        guard let amount = Utilities.parseToBigUInt(transnum, decimals: decimal) else {return nil}
        guard let from = EthereumAddress(fromAddress) else{return nil}
        guard let to = EthereumAddress(toAddress) else{return nil}
        var transaction: CodableTransaction = .emptyTransaction
        transaction.from = from
        transaction.to = to
        transaction.gasPrice = gasPrice
        transaction.value = amount
        transaction.chainID = BigUInt(chainId)
        return transaction
    }
}

extension WalletERC20Request : EMJSONProtocol{
    //合约调用
    class func contractDataTransferRequest(account: EMAccount,
                                           data: [String: Any]) async throws -> TransactionSendingResult?{
        guard let web = try? await createWeb3(account: account) else{
            throw WalletError.rpcError(desc: nil)
        }
        guard let gasPrice = try? await self.getGasRequest(rpc: account.chain.rpc, chainId: account.chain.chainId) else{
            throw WalletError.gasError(desc: nil)
        }
        var finalTransaction = try createCodableTransaction(data)
        finalTransaction.gasPrice = gasPrice
        finalTransaction.chainID = BigUInt(account.chain.chainId)
        guard let from = EthereumAddress(account.address) else{
            throw WalletError.addressError(desc: nil)
        }
        finalTransaction.from = from
        guard let nonce = try? await web.eth.getTransactionCount(for: from) else{
            throw WalletError.rpcError(desc: nil)
        }
        finalTransaction.nonce = nonce
        
        if finalTransaction.gasLimit == 0{
            finalTransaction.gasLimit = try await getContractGasLimtRequest(finalTransaction: finalTransaction, web3Provider: web.provider)
        }
        
        let privateKey = Data(hex: account.privateKey.add0x)
        try finalTransaction.sign(privateKey: privateKey)
        return try await web.eth.send(raw: finalTransaction.encode()!)
    }
    
    //获取合约调用的gasLimit
    class func getContractDataGasLimitRequest(account: EMAccount,
                                           data: [String: Any]) async throws -> BigUInt{
        guard let web = try? await createWeb3(account: account) else{
            throw WalletError.rpcError(desc: nil)
        }
        guard let gasPrice = try? await self.getGasRequest(rpc: account.chain.rpc, chainId: account.chain.chainId) else{
            throw WalletError.gasError(desc: nil)
        }
        var finalTransaction = try createCodableTransaction(data)
        finalTransaction.gasPrice = gasPrice
        finalTransaction.chainID = BigUInt(account.chain.chainId)
        guard let from = EthereumAddress(account.address) else{
            throw WalletError.addressError(desc: nil)
        }
        finalTransaction.from = from
        guard let nonce = try? await web.eth.getTransactionCount(for: from) else{
            throw WalletError.rpcError(desc: nil)
        }
        finalTransaction.nonce = nonce
        return try await getContractGasLimtRequest(finalTransaction: finalTransaction, web3Provider: web.provider)
    }
    
    
    class func createWeb3(account:EMAccount) async throws -> Web3{
        guard let we3P = try? await Web3HttpProvider(url:URL(string: account.chain.rpc)!,network: Networks.Custom(networkID: BigUInt(account.chain.chainId))) else {
            throw WalletError.rpcError(desc: nil)
        }
        let web = Web3(provider: we3P)
        return web
    }
    
    class func createCodableTransaction(_ data : [String : Any]) throws ->  CodableTransaction{
        guard let toAddress = data["to"] as? String, let to = EthereumAddress(toAddress)  else{
            throw WalletError.inputError(desc: "to address error")
        }
        
        guard let dataValue = data["data"] as? String else{
            throw WalletError.addressError(desc: nil)
        }
        
        var value = BigUInt(0)
        if let dataValue = data["value"] as? String, let amount = BigUInt(dataValue.removeString("0x"),radix: 16) {
            value = amount
        }
        var transaction: CodableTransaction = .emptyTransaction
        transaction.to = to
        if let gasLimit = data["gas"] as? String , let gas = BigUInt(gasLimit.removeString("0x"),radix: 16){
            transaction.gasLimit = gas
        }
        transaction.data = Data(hex:dataValue.add0x)
        transaction.value = value
        return transaction
    }
}
