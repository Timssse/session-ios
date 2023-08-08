// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import Photos

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
    
    @discardableResult
    static func editUserInfo(name : String , icon : [PHAsset],userInfo : EMCommunityUserEntity) async -> Bool{
        do{
            if EMCommunityConfigEntity.share.IpfsHost == ""{
                await EMCommunityController.config()
                return await editUserInfo(name: name, icon: icon, userInfo: userInfo)
            }
            var avatar = userInfo.Avatar
            for file in icon{
                let path = try await EMCommunityController.upload(file: file)
                avatar = path
            }
            let address = userInfo.UserAddress;
            let nickName = name
            let desc = userInfo.Desc;
            let updateSignUnix = FS(Int(Date().timeIntervalSince1970))
            let msg = [address,nickName,desc,avatar,updateSignUnix].joined(separator: "|")
            let sign = WalletUtilities.signPersonalMessage(message: msg) ?? ""
            try await UserUpdateInfoRequest(param: ["avatar":avatar,"nickname":nickName,"desc":desc,"sex":userInfo.Sex,"sign":sign,"updateSignUnix":updateSignUnix]).request()
            //更新本地数据
            ProfileManager.updateLocal(
                queue: DispatchQueue.global(qos: .default),
                profileName: name,
                image: nil,
                imageFilePath: avatar,
                success: { db, updatedProfile in
                    UserDefaults.standard[.lastDisplayNameUpdate] = Date()
                    UserDefaults.standard[.lastProfilePictureUpdate] = Date()
                    try MessageSender.syncConfiguration(db, forceSyncNow: true).retainUntilComplete()
                    db.afterNextTransaction { _ in
                        
                    }
                })
            return true
        }catch{
            Toast.toast(hit: error.localizedDescription)
            return false
        }
    }
    
    static func userFans(_ page : Int)async -> [EMCommunityUserEntity]{
        guard let data = try? await getUserFansRequest(page: page).request() as? HTTPList else{
            return []
        }
        let relust = [EMCommunityUserEntity].deserialize(from: data)
        return (relust as? [EMCommunityUserEntity]) ?? []
    }
    
    static func userFollow(_ page : Int)async -> [EMCommunityUserEntity]{
        guard let data = try? await getUserFollowRequest(page: page).request() as? HTTPList else{
            return []
        }
        let relust = [EMCommunityUserEntity].deserialize(from: data)
        return (relust as? [EMCommunityUserEntity]) ?? []
    }
    
    static func follow(_ isFollow : Bool,address : String)async -> Bool{
        
        if isFollow{
            do{
                try await CancelUserFollowRequest(address: address).request()
                return true
            }catch{
                return false
            }
            return false
        }
        do{
            try await UserFollowRequest(address: address).request()
            return true
        }catch{
            return false
        }
    }
}
