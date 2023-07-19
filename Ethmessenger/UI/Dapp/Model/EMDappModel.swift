// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

struct EMDappModel {
    var name : String
    var url : String
    init(name: String, url: String) {
        self.name = name
        self.url = url
    }
    
    static var ethTwitter : EMDappModel{
        return EMDappModel.init(name: "Hot", url: "https://app.ethtweet.io/")
    }
}
