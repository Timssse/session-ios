// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMTableToken: NSObject {
    
//    static func addRMB() -> Bool {
//        var rs = false
//        DataBaseTool.shared.queue?.inDatabase({ (db) in
//            rs = db.executeUpdate("alter table token add RMB varchar(40)", withArgumentsIn: [])
//        })
//        return rs
//    }
    
    
    @discardableResult
    static func insert(_ token: EMTokenModel) -> Bool {
        if let _ = self.selectToken(token){
            return true
        }
        var rs = false
        EMDataBaseTool.shared.queue?.inDatabase({ (db) in
            let values: [Any] = [token.id,
                                 token.icon,
                                 token.symbol,
                                 token.assets_name,
                                 token.chain_id,
                                 token.decimals,
                                 token.balance,
                                 token.walletAddress,
                                 token.contract,
                                 token.sort,
                                 token.price,
                                 token.RMB
            ]
            rs = db.executeUpdate("INSERT INTO token (id,icon,symbol,assets_name,chain_id,decimals,balance,walletAddress,contract,sort,price,RMB) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)", withArgumentsIn: values)
        })
        return rs
    }
    
    static func selectMainToken(_ token : EMTokenModel) -> EMTokenModel? {
        var rs: EMTokenModel?
        EMDataBaseTool.shared.queue?.inDatabase({ (db) in
            if let fmrs = db.executeQuery("SELECT * FROM token where chain_id = ? and symbol = ? and contract = ?", withArgumentsIn: [token.chain_id,token.symbol,""]) {
                if fmrs.next() {
                    if let oneDic = fmrs.resultDictionary as NSDictionary? {
                        rs = EMTokenModel.deserialize(from: oneDic)
                    }
                }
                fmrs.close()
            }
        })
        return rs
    }
    
    static func selectToken(_ token : EMTokenModel) -> EMTokenModel? {
        var rs: EMTokenModel?
        let contractArress = token.contract.lowercased()
        if contractArress == ""{
            return self.selectMainToken(token)
        }
        EMDataBaseTool.shared.queue?.inDatabase({ (db) in
            if let fmrs = db.executeQuery("SELECT * FROM token where lower(contract) = ? and symbol = ? ", withArgumentsIn: [contractArress,token.symbol]) {
                if fmrs.next() {
                    if let oneDic = fmrs.resultDictionary as NSDictionary? {
                        rs = EMTokenModel.deserialize(from: oneDic)
                    }
                }
                fmrs.close()
            }
        })
        return rs
    }
    
    static func selectAll() -> [EMTokenModel] {
        var rs: [EMTokenModel] = []
        EMDataBaseTool.shared.queue?.inDatabase({ (db) in
            guard let fmrs = db.executeQuery("SELECT * FROM token", withArgumentsIn: []) else {return}
            while fmrs.next() {
                if let oneDic = fmrs.resultDictionary as NSDictionary? {
                    if let one = EMTokenModel.deserialize(from: oneDic) {
                        rs.append(one)
                    }
                }
            }
            fmrs.close()
        })
        return rs
    }
    
    static func selectAllMainToken() -> [EMTokenModel] {
        var rs: [EMTokenModel] = []
        EMDataBaseTool.shared.queue?.inDatabase({ (db) in
            guard let fmrs = db.executeQuery("SELECT * FROM token where contract = ?", withArgumentsIn: [""]) else {return}
            while fmrs.next() {
                if let oneDic = fmrs.resultDictionary as NSDictionary? {
                    if let one = EMTokenModel.deserialize(from: oneDic) {
                        rs.append(one)
                    }
                }
            }
            fmrs.close()
        })
        return rs
    }
    
    static func selectMainTokenWithChainId(_ chainId : Int) -> EMTokenModel? {
        var rs: EMTokenModel?
        EMDataBaseTool.shared.queue?.inDatabase({ (db) in
            guard let fmrs = db.executeQuery("SELECT * FROM token where contract = ? and chain_id = ?", withArgumentsIn: ["",chainId]) else {return}
            while fmrs.next() {
                if let oneDic = fmrs.resultDictionary as NSDictionary? {
                    if let one = EMTokenModel.deserialize(from: oneDic) {
                        rs = one
                    }
                }
            }
            fmrs.close()
        })
        return rs
    }
    
    static func selectTokenWithChainId(_ chainId : Int) -> [EMTokenModel] {
        var rs: [EMTokenModel] = []
        EMDataBaseTool.shared.queue?.inDatabase({ (db) in
            guard let fmrs = db.executeQuery("SELECT * FROM token where chain_id = ? ORDER BY sort ASC, CAST(RMB as DECIMAL) DESC , CAST(balance as DECIMAL) DESC", withArgumentsIn: [chainId]) else {return}
            while fmrs.next() {
                if let oneDic = fmrs.resultDictionary as NSDictionary? {
                    if let one = EMTokenModel.deserialize(from: oneDic) {
                        rs.append(one)
                    }
                }
            }
            fmrs.close()
        })
        return rs
    }
    
    static func updateToken(_ token : EMTokenModel){
        
        EMDataBaseTool.shared.queue?.inDatabase({ (db) in
            let values: [Any] = [
                token.balance,
                token.sort,
                token.rmbStr,
                token.price,
                token.contract,
                token.contract.lowercased(),
                token.chain_id
                                ]
            db.executeUpdate("UPDATE token SET balance = ?,sort = ?,RMB = ?,price = ?,contract = ?  WHERE lower(contract) = ? and chain_id = ?",
                                  withArgumentsIn: values)
        })
    }
    
    static func addMainToken(){
        insert(EMTokenModel.ETH)
        insert(EMTokenModel.BSC)
        insert(EMTokenModel.ARB)
        insert(EMTokenModel.OP)
        insert(EMTokenModel.MATIC)
    }
    
}
