// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import HandyJSON

class EMCommunityConfigEntity: HandyJSON {
    
    static var share = EMCommunityConfigEntity()
    
    var IpfsHost : String = ""
    
    required init() {
        
    }
}
