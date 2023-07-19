// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import HandyJSON
class EMHomeListEntity: HandyJSON {
    var Attachment : String = ""
    var Cursor : String = ""
    var CommentCount : Int = 0
    var Content : String = ""
    var CreatedAt : Int = 0
    var ForwardCount : Int = 0
    var ID : String = ""
    var LikeCount : Int = 0
    var DonateCount : Int = 0
    var OriginTweet : EMHomeListEntity?
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
        }
    }
    
    var showTime : String{
        let difference = Date().timeIntervalSince1970 - Double(CreatedAt)
        if difference < 60 * 60{
            return "\(Int(ceil(difference/60))) \(LocalMinAgo.localized())"
        }
        if difference < 60 * 60 * 24{
            return "\(Int(ceil(difference/60/60))) \(LocalHourAgo.localized())"
        }
        return "\(CreatedAt)".toyyyyMMdd("yyyy.MM.dd")
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
