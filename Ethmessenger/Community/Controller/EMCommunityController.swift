// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import Foundation
import Photos
import AVFoundation

struct EMCommunityController{
    static func isLogin() -> Bool{
        return CacheUtilites.shared.localCommunityToken != nil
    }
    
    static func config()async {
        guard let data = try? await CommunityConfigRequest().request() as? HTTPJson else{
            return
        }
        guard let relust = EMCommunityConfigEntity.deserialize(from: data) else{
            return
        }
        EMCommunityConfigEntity.share = relust
    }
    
    
    ///Login
    @discardableResult
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
            guard let model = EMCommunityUserEntity.deserialize(from: userData) else{
                return nil
            }
            CacheUtilites.shared.localCommunityToken = model.Token
            let userInfo = Profile.fetchOrCreateCurrentUser()
            if userInfo.name != model.Nickname{
                await EMUserController.editUserInfo(name: userInfo.name, icon: [], userInfo: model)
            }
            return model
        }catch{
            return nil
        }
    }
    
    ///
    static func homeList(_ cursor : String = "") async -> [EMCommunityHomeListEntity]{
        do{
            guard let data = try await CommunityHomeRequest(cursor: cursor).request() as? HTTPList else{
                return []
            }
            let relust = [EMCommunityHomeListEntity].deserialize(from: data)
            return (relust as? [EMCommunityHomeListEntity]) ?? []
        }catch{
            return []
        }
    }
    
    static func followTwitterList(_ cursor : String = "") async -> [EMCommunityHomeListEntity]{
        do{
            guard let data = try await CommunityFollowTwitterRequest(cursor: cursor).request() as? HTTPList else{
                return []
            }
            let relust = [EMCommunityHomeListEntity].deserialize(from: data)
            return (relust as? [EMCommunityHomeListEntity]) ?? []
        }catch{
            return []
        }
    }
    
    ///
    static func like(_ twAddress : String = "") async{
        do{
            try await CommunityLikeRequest(twAddress: twAddress).request()
        }catch{
           
        }
    }
    
    ///
    static func detail(_ twAddress : String = "")async -> EMCommunityHomeListEntity?{
        do{
            guard let data = try await CommunityDetailRequest(twId: twAddress).request() as? HTTPJson else{
                return nil
            }
            return EMCommunityHomeListEntity.deserialize(from: data)
        }catch{
            return nil
        }
    }
    
    static func commentList(twAddress : String , page : Int) async -> [EMCommunityCommentEntity]{
        do{
            AnimationManager.shared.setAnimation()
            guard let data = try await CommunityCommentListRequest(twAddress: twAddress, page: page).request() as? HTTPList else{
                AnimationManager.shared.removeAnimaition()
                return []
            }
            AnimationManager.shared.removeAnimaition()
            let relust = [EMCommunityCommentEntity].deserialize(from: data)
            return (relust as? [EMCommunityCommentEntity]) ?? []
        }catch{
            AnimationManager.shared.removeAnimaition()
            return []
        }
    }
    
    static func commentRelease(twAddress : String , content : String) async -> Bool{
        do{
            try await CommunityCommentReleaseRequest(twAddress: twAddress, content: content).request()
            return true
        }catch{
            Toast.toast(hit: error.localizedDescription)
            return false
        }
    }
    
    static func create(forwardId : String? , content : String,attachment : String)async throws -> (id: String,signMsg:String){
        let value =  try await (CommunityCreateRequest(forwardId: forwardId, content: content,attachment : attachment).request() as? HTTPJson)
        return ("\(value?["Id"] ?? "")","\(value?["SignMsg"] ?? "")")
    }
    
    static func release(content : String , files : [PHAsset],forwardId : String?) async -> Bool{
        do{
            if EMCommunityConfigEntity.share.IpfsHost == ""{
                await config()
                return await release(content: content, files: files, forwardId: forwardId)
            }
            var fileUrls : [String] = []
            for file in files{
                let path = try await upload(file: file)
                fileUrls.append(path)
            }
            
            let relust = try await create(forwardId: forwardId, content: content, attachment: fileUrls.joined(separator: ","))
            
            guard let sign = WalletUtilities.signPersonalMessage(message: relust.signMsg) else{
                return false
            }
            try await CommunityReleaseRequest(id:relust.id,sign: sign).request()
            return true
        }catch{
            Toast.toast(hit: error.localizedDescription)
            return false
        }
    }
    
    static func upload(file : PHAsset) async throws -> String{
        var data : Data?
        var fileName : String = ".mp4"
        if file.mediaType == .image {
            (data,fileName) = try await withCheckedThrowingContinuation({ continuation in
                PHImageManager.default().requestImageDataAndOrientation(for: file, options: nil) { data, name, _, _ in
                    continuation.resume(returning: (data,name ?? ".jpg"))
                }
            })
            let value = try await (CommunityUploadRequest(datas: [HTTPMultipartData.init(data: data!, name: "image", fileName: "\(Int(Date().timeIntervalSince1970))\(data!.count)" + fileName, type: .JPEG)]).request() as? HTTPJson)
//            let fileName = value?["Name"] as? String ?? ""
            let hash = value?["Hash"] as? String ?? ""
            
            return "\(EMCommunityConfigEntity.share.IpfsHost)ipfs/\(hash)?filename=\(hash).\(fileName.split(separator: ".").last ?? "")"
        }
        if file.mediaType == .video {
            data = try await withCheckedThrowingContinuation({ continuation in
                PHImageManager.default().requestAVAsset(forVideo: file, options: nil) {asset, _, _ in
                    if let avAsset = asset as? AVURLAsset {
                        do{
                            let data = try Data(contentsOf: avAsset.url)
                            continuation.resume(returning: data)
                        }catch{
                            continuation.resume(throwing: HTTPError(code: -1, desc: ""))
                        }
                    }else{
                        continuation.resume(throwing: HTTPError(code: -1, desc: ""))
                    }
                }
            })
            let value = try await (CommunityUploadRequest(datas: [HTTPMultipartData.init(data: data!, name: "video", fileName: "\(Int(Date().timeIntervalSince1970))\(data!.count)" + fileName, type: .MP4)]).request() as? HTTPJson)
            let hash = value?["Hash"] as? String ?? ""
            return "\(EMCommunityConfigEntity.share.IpfsHost)ipfs/\(hash)?filename=\(hash).\(fileName.split(separator: ".").last ?? "")}"
        }
        return ""
    }
    
}
