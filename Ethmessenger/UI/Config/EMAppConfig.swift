// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMAppConfig: NSObject {
    let chainConfigPath = "https://imfile-backend.s3.ap-northeast-1.amazonaws.com/update/ethmessage_network.json"
    static let shared = EMAppConfig()
    
    var chains : [EMChainModel] = []
    @discardableResult
    func getChains() async -> [EMChainModel]{
        if (chains.count > 0){
            return chains
        }
        let data = await getChainsConfig()
        if let model = [EMChainModel].deserialize(from: data) as? [EMChainModel]{
            self.chains = model
            return model
        }
        return []
    }
    
    func getChainsConfig() async -> [Any]?{
        return try? await withCheckedThrowingContinuation({ continuation in
            let request:URLRequest = URLRequest(url: URL(string:  chainConfigPath)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20)
            let dataTask = URLSession.shared.dataTask(with: request,
                                                      completionHandler: {(data, response, error) -> Void in
                if error != nil{
                    continuation.resume(returning: nil)
                }else{
                    let str = String(data: data!, encoding: String.Encoding.utf8)
                    let dict = str?.toArray()
                    continuation.resume(returning: dict)
                }
            }) as URLSessionTask
            dataTask.resume()
        })
    }
}
