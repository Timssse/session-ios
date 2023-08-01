// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import FMDB

class EMDataBaseTool: NSObject {
    
    static let shared: EMDataBaseTool = {
        let instance = EMDataBaseTool()
        instance.createTableCoin()
//        instance.createTableTransfer()
//        instance.createTableTransferRecord()
        return instance
    }()
    
    private override init(){}
    
    let queue = FMDatabaseQueue(path: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,FileManager.SearchPathDomainMask.userDomainMask,true).last! + "/ethmessengerWalet.db")
        
    private func createTableCoin() {
        let file = Bundle.main.path(forResource: "token.sql", ofType: nil)!
        let sql = try! String(contentsOfFile: file)
        queue?.inDatabase { (db) in
            let rs = db.executeStatements(sql)
            if rs {
//                print("建表coin成功")
            }else{
//                print("建表coin失败")
            }
        }
    }
    
//    private func createTableTransfer() {
//        let file = Bundle.main.path(forResource: "transfer.sql", ofType: nil)!
//        let sql = try! String(contentsOfFile: file)
//        queue?.inDatabase { (db) in
//            let rs = db.executeStatements(sql)
//            if rs {
////                print("建表transfer成功")
//            }else{
////                print("建表transfer失败")
//            }
//        }
//    }
//
//    private func createTableTransferRecord() {
//        let file = Bundle.main.path(forResource: "transfer_record.sql", ofType: nil)!
//        let sql = try! String(contentsOfFile: file)
//        queue?.inDatabase { (db) in
//            let rs = db.executeStatements(sql)
//            if rs {
////                print("建表transfer成功")
//            }else{
////                print("建表transfer失败")
//            }
//        }
//    }
}
