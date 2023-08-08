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
    
    var showTime : String{
        let difference = Date().timeIntervalSince1970 - Double(self)
        if difference < 60 * 60{
            return "\(Int(ceil(difference/60))) \(LocalMinAgo.localized())"
        }
        if difference < 60 * 60 * 24{
            return "\(Int(ceil(difference/60/60))) \(LocalHourAgo.localized())"
        }
        return "\(self)".toyyyyMMdd("yyyy.MM.dd")
    }
}

extension Int {
    func getUnitWithDecimails() -> String {
        var  decimalStr = "1"
        for _ in 0..<self  {
            decimalStr += "0"
        }
        return decimalStr
    }
}
