// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import Foundation
import web3swift
import Web3Core
import BigInt

struct GetBalanceRequest : WalletERCRequest{
    var rpc: String
    var chainId: Int
    var address : String
    var contractAddress : String
    func request() async throws -> BigUInt?{
        if contractAddress.count == 0 {
            return try await self.fetchAwait(.getBalance(address, .latest)) as? BigUInt
        }
        let web = try await createWeb3()
        guard let walletAddress = EthereumAddress(address) else {
            throw WalletError.addressError(desc: "address Error")
        }
        guard let eAddress = EthereumAddress(contractAddress) else {
            throw WalletError.addressError(desc: "token Error")
        }
        let erc20token = ERC20.init(web3: web, provider:web.provider, address: eAddress)
        return try await erc20token.getBalance(account: walletAddress)
    }
}

//Mark:查询区块高度
struct GetBlockNumberRequest : WalletERCRequest{
    var rpc: String
    var chainId: Int
    func request() async throws -> BigUInt{
        let web = try await createWeb3()
        guard let response: APIResponse<BigUInt> = try? await APIRequest.sendRequest(with: web.provider, for: .blockNumber)else{
            return 0
        }
        return response.result
    }
}

//Mark:查询Token信息
struct GetTokenInfoRequest : WalletERCRequest{
    var rpc: String
    var chainId: Int
    var contractAddress : String
    func request() async throws -> ERC20?{
        guard let eAddress = EthereumAddress(contractAddress) else {
            Toast.toast(hit: LocalTokenContractError.localized())
            return nil
        }
        let web = try await createWeb3()
        let erc20token = ERC20.init(web3: web, provider:web.provider, address: eAddress)
        try await erc20token.readProperties()
        return erc20token
    }
}


struct GetGasPriceRequest : WalletERCRequest{
    var rpc: String
    var chainId: Int
    
    func request() async throws -> BigUInt{
        let web = try await createWeb3()
        let request: APIRequest = .gasPrice
        return try await APIRequest.sendRequest(with: web.provider, for: request).result
    }
}


struct GetGasLimitRequest : WalletERCRequest{
    var rpc: String
    var chainId: Int
    var transaction : CodableTransaction
    func request() async -> BigUInt?{
        return try?(await self.fetchAwait(.estimateGas(transaction, .latest)) as? BigUInt)
    }
}

///预估主网gaslimit 目前只有arb需要
struct GetMainTokenGasLimitRequest : WalletERCRequest{
    var rpc: String
    var chainId: Int
    var transnum : String
    var token : EMTokenModel
    var fromAddress : String
    var toAddress : String
    var gasPrice : BigUInt

    func request() async throws -> BigUInt?{
        let web = try await createWeb3()
//        let gasPrice = try await GetGasPriceRequest.init(rpc: rpc, chainId: chainId).request()
        guard let finalTransaction = self.createTransaction(transnum: transnum, decimal: token.decimals, gasPrice: gasPrice, fromAddress: fromAddress, toAddress: toAddress == "" ? "0x0000000000000000000000000000000000000001" : toAddress, chainId: chainId) else{
            throw WalletError.inputError(desc: "tx error")
        }
        return await GetGasLimitRequest(rpc: rpc, chainId: chainId, transaction: finalTransaction).request()
    }
}

///预估代币转账GasLimit
struct GetTokenGasLimtRequest : WalletERCRequest{
    var rpc: String
    var chainId: Int
    var transnum : String
    var from : String
    var to : String
    var gasPrice : BigUInt
    var token : EMTokenModel
    func request() async throws -> BigUInt?{
        guard let fromAddress = EthereumAddress(from) else{
            return nil
        }
        guard let toAddress = EthereumAddress(to) else{
            return nil
        }
        guard let eAddress = EthereumAddress(token.contract) else {
            throw WalletError.addressError(desc: "token address Error")
        }
        let web = try await createWeb3()
        guard let finalTransaction = self.createTransaction(transnum: "0", decimal: token.decimals, gasPrice: gasPrice, fromAddress: from, toAddress: to, chainId: chainId) else{
            throw WalletError.inputError(desc: "tx error")
        }
        let erc20token = ERC20.init(web3: web, provider:web.provider, address: eAddress,transaction: finalTransaction)
        let transaction = try await erc20token.transfer(from: fromAddress, to: toAddress, amount: transnum)
        return await GetGasLimitRequest(rpc: rpc, chainId: chainId, transaction: transaction.transaction).request()
    }
}

struct nonceRequest : WalletERCRequest{
    var rpc: String
    var chainId: Int
    var address : String
    func request() async -> BigUInt?{
        return try?(await self.fetchAwait(.getTransactionCount(address, .latest)) as? BigUInt)
    }
}

struct TransferRequest : WalletERCRequest{
    var rpc: String
    var chainId: Int
    var fromAddress : String
    var to : String
    var token : EMTokenModel
    var num : String
    var gas : EMCostFeeModel
    func request() async throws -> TransactionSendingResult{
        guard var finalTransaction = self.createTransaction(transnum: num, decimal: token.decimals, gasPrice: gas.gasPrice, fromAddress: fromAddress, toAddress: to, chainId: chainId) else{
            throw WalletError.inputError(desc: "tx error")
        }
        finalTransaction.gasPrice = gas.gasPrice
        finalTransaction.gasLimit = gas.gasLimit
        guard let nonce = await nonceRequest(rpc: rpc, chainId: chainId, address: fromAddress).request() else{
            throw WalletError.addressError(desc: nil)
        }
        finalTransaction.nonce = nonce
        
        if token.contract.count != 0 {
            return try await contractTransferRequest(rpc: rpc, chainId: chainId, fromAddress: fromAddress, transaction: finalTransaction, tokenAddress: token.contract).request()
        }
        let web = try await createWeb3()
        let privateKey = Data(hex: WalletUtilities.account.privateKey.add0x)
        try finalTransaction.sign(privateKey: privateKey)
        return try await web.eth.send(raw: finalTransaction.encode()!)
    }
}


struct contractTransferRequest : WalletERCRequest{
    var rpc: String
    var chainId: Int
    var fromAddress : String
    var transaction : CodableTransaction
    var tokenAddress : String
    func request() async throws -> TransactionSendingResult{
        guard let eAddress = EthereumAddress(tokenAddress) else{
            throw WalletError.addressError(desc: nil)
        }
        let web = try await createWeb3()
        let erc20token = ERC20.init(web3: web, provider:web.provider, address: eAddress,transaction: transaction)
        guard let writeTX = try? await erc20token.transfer(from: transaction.from!, to: transaction.to, amount: "0" ) else {
            throw WalletError.inputError(desc: "tx error")
        }
        let gasLimit = try await web.eth.estimateGas(for: writeTX.transaction)
        writeTX.transaction.gasLimit = gasLimit
        let privateKey = Data(hex: WalletUtilities.account.privateKey.add0x)
        try writeTX.transaction.sign(privateKey: privateKey)
        return try await web.eth.send(raw: writeTX.transaction.encode()!)
    }
}


class WalletERC20Request{
    
    class func getContractGasLimtRequest(finalTransaction: CodableTransaction,
                                         web3Provider: Web3Provider) async throws -> BigUInt{
        
        let request: APIRequest = .estimateGas(finalTransaction, finalTransaction.callOnBlock ?? .latest)
        let response: APIResponse<BigUInt> = try await APIRequest.sendRequest(with: web3Provider, for: request)
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
