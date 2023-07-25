// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

struct EMUserController {
    
    static func userInfo(_ address : String) async -> EMCommunityUserEntity?{
        do{
            guard let data = try await UserInfoRequest(address: address).request() as? HTTPJson else{
                return nil
            }
            guard let user =  data["user"] as? HTTPJson else{
                return nil
            }
            return EMCommunityUserEntity.deserialize(from: user)
        }catch{
            return nil
        }
    }
    
    static func tweetsList(_ address : String, cursor : String = "") async -> [EMCommunityHomeListEntity]{
        do{
            guard let data = try await UserTweetsRequest(address: address, cursor: cursor).request() as? HTTPList else{
                return []
            }
            let relust = [EMCommunityHomeListEntity].deserialize(from: data)
            return (relust as? [EMCommunityHomeListEntity]) ?? []
        }catch{
            return []
        }
    }
}
