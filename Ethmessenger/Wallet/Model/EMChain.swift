// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

enum EMChainType : String {
    case eth = "Ethereum"
    case bsc = "BNB Chain"
    case op = "Optimism"
    case arb = "Arbitrum"
    case matic = "Polygon"
    
    
    static func create(chainId : Int) -> EMChainType{
        if chainId == 1{
            return .eth
        }
        
        if chainId == 56 {
            return .bsc
        }
        
        if chainId == 42161 {
            return .arb
        }
        
        if chainId == 10 {
            return .op
        }
        
        if chainId == 137 {
            return .matic
        }
        return .eth
    }
    
    static func initChain(_ type : EMChainType) -> EMChain{
        if type == .eth{
            return EMChain.init(type: type, chainId: 1)
        }
        
        if type == .bsc {
            return EMChain.init(type: type, chainId: 56)
        }
        
        if type == .arb {
            return EMChain.init(type: type, chainId: 42161)
        }
        
        if type == .op {
            return EMChain.init(type: type, chainId: 10)
        }
        
        if type == .matic {
            return EMChain.init(type: type, chainId: 137)
        }
        return EMChain.init(type: type, chainId: 1)
    }
    
    
}

struct EMChain {
    var type : EMChainType = .eth
    var chainId : Int
    
    func getMainToken() -> EMTokenModel{
        switch self.type{
            case .eth: return EMTokenModel.ETH
            case .bsc: return EMTokenModel.BSC
            case .op: return EMTokenModel.OP
            case .arb: return EMTokenModel.ARB
            case .matic: return EMTokenModel.MATIC
        }
        
    }
    
    var rpc : String{
        switch self.type{
            case .eth: return EMWalletCache.shared.ethRPC
            case .bsc: return EMWalletCache.shared.bscRPC
            case .op: return EMWalletCache.shared.opRPC
            case .arb: return EMWalletCache.shared.arbRPC
            case .matic: return EMWalletCache.shared.maticRPC
        }
    }
    
    func saveRpc(_ rpc : String){
        switch self.type{
        case .eth:
            EMWalletCache.shared.ethRPC = rpc
            break;
        case .bsc:
            EMWalletCache.shared.bscRPC = rpc
            break;
        case .op:
            EMWalletCache.shared.opRPC = rpc
            break;
        case .arb:
            EMWalletCache.shared.arbRPC = rpc
            break;
        case .matic:
            EMWalletCache.shared.maticRPC = rpc
            break;
        }
    }
    
    init(type: EMChainType? = nil, chainId: Int) {
        self.type = type ?? EMChainType.create(chainId: chainId)
        self.chainId = chainId
    }
}
