// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import Foundation

struct EMCommunityController{
    static func isLogin() -> Bool{
        return CacheUtilites.shared.localCommunityToken != nil
    }
    
    static func login() async -> EMCommunityUserEntity?{
        do{
            guard let sign1 = WalletUtilities.signPersonalMessage(message: WalletUtilities.address) else{
                return nil
            }
            guard let data = try await CommunityNonceRequest(address: WalletUtilities.address, sign: sign1).request() as? HTTPJson,let signMsg = (data["SignMsg"] as? String) ,let nonce = data["Nonce"] else{
                return nil
            }
            guard let sign2 = WalletUtilities.signPersonalMessage(message: signMsg) else{
                return nil
            }
            guard let userData = try await CommunityLoginRequest(address: WalletUtilities.address, sign: sign2,nonce: "\(nonce)").request() as? HTTPJson else{
                return nil
            }
            let model = EMCommunityUserEntity.deserialize(from: userData)
            CacheUtilites.shared.localCommunityToken = model?.Token
            return model
        }catch{
            return nil
        }
    }
    
    static func homeList(_ cursor : String = "") async -> [EMHomeListEntity]{
        do{
            guard let data = try await CommunityHomeRequest(cursor: cursor).request() as? HTTPList else{
                return []
            }
            let relust = [EMHomeListEntity].deserialize(from: data)
            return (relust as? [EMHomeListEntity]) ?? []
        }catch{
            return []
        }
    }
    
    static func like(_ twAddress : String = "") async{
        do{
            try await CommunityLikeRequest(twAddress: twAddress).request()
        }catch{
           
        }
    }
}
