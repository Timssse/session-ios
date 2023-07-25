// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import HandyJSON
class EMCommunityCommentEntity: HandyJSON {
    var Content : String = ""
    var CreatedAt : Int = 0
    var ReplyNum : Int = 0
    var ReplyUserInfo : EMCommunityUserEntity?
    var UserAddress : String = ""
    var Uuid : String = ""
    var UserInfo : EMCommunityUserEntity?
    required init() {
        
    }
    
}
