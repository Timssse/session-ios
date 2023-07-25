// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import HandyJSON
class EMCommunityHomeListEntity: HandyJSON {
    var Attachment : String = ""
    var Cursor : String = ""
    var CommentCount : Int = 0
    var Content : String = ""
    var CreatedAt : Int = 0
    var ForwardCount : Int = 0
    var ID : String = ""
    var LikeCount : Int = 0
    var DonateCount : Int = 0
    var OriginTweet : EMCommunityHomeListEntity?
    var TwAddress : String = ""
    var isTwLike : Bool = true
    var UserInfo : EMCommunityUserEntity?
    required init() {
        
    }
    
    private var _images : [EMCommunityFileEntity]?
    var images : [EMCommunityFileEntity]{
        if _images != nil{
            return _images!
        }
        fileFiltering()
        return _images ?? []
    }
    
    
    func fileFiltering(){
        _images = []
        let arr = Attachment.split(separator: ",")
        arr.forEach { subString in
            let paths = subString.split(separator: ".")
            if paths.count == 1{
                _images?.append(EMCommunityFileEntity(path: String(subString), type: .image))
            }
            if FileUtilities.fileIsImage(String(paths.last ?? "")){
                _images?.append(EMCommunityFileEntity(path: String(subString), type: .image))
            }
            if FileUtilities.fileIsVideo(String(paths.last ?? "")){
                _images?.append(EMCommunityFileEntity(path: String(subString), type: .video))
            }
            if (paths.last ?? "").count > 6{
                _images?.append(EMCommunityFileEntity(path: String(subString), type: .image))
            }
        }
    }
}

struct EMCommunityFileEntity{
    enum FileType{
        case video
        case image
    }
    var path : String
    var type : FileType
}
