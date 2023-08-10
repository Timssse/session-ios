// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import HandyJSON
class EMCommunityLikeMeEntity: HandyJSON {
    var CreatedAt : Int = 0
    var UserAddress : String = ""
    var UserInfo : EMCommunityUserEntity?
    var Tweet : EMCommunityHomeListEntity?
    var OriginTweet : EMCommunityHomeListEntity?
    var Content : String = LocalLikeYouMoment.localized()
    required init() {
        
    }
}
