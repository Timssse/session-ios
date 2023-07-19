// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import HandyJSON
class EMCommunityUserEntity: HandyJSON {
    var ID : Int = 0
    var UserAddress : String = ""
    var Avatar : String = ""
    var IsFollow : Bool = false
    var Nickname : String = ""
    var PubKey : String = ""
    var AuthLevel : Int = 0
    var Sex : Int = 0
    var Desc : String = ""
    var FansCount : Int = 0
    var FollowCount : Int = 0
    var Sign : String = ""
    var Token : String = ""
    var TokenStatus : Int = 0
    var TwNonce : Int = 0
    var IpfsHash : String = ""
    var IsSys : Int = 0
    var UpdatedSignUnix : Int = 0
    var password : String = ""
    var privateKey : String = ""
    var mnemonic : String = ""
    
    required init() {
        
    }
}
