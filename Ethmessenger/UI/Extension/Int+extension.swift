//
//  Int+extension.swift
//  ICE VPN
//
//  Created by tgg on 2023/6/1.
//

import UIKit

extension Int {
    var w : CGFloat{
        get{
            return (Screen_width/375.0)*CGFloat(self)
        }
    }
    
    var h : CGFloat{
        get{
            return (Screen_height/812.0)*CGFloat(self)
        }
    }
}

