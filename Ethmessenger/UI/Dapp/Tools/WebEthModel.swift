//
//  WebEthModel.swift
//  ICE VPN
//
//  Created by tgg on 2023/6/9.
//

import UIKit
import HandyJSON

class WebEthModel: HandyJSON {
    var id : Int = 0
    var name = ""
    var object = WebEthObjcModel()
    required init () {}
}

class WebEthObjcModel: HandyJSON {
    var chainType = ""
    var from = ""
    var gas = ""
    var to = ""
    var value = "0"
    var data = ""
    var gasPrice = ""
    var chainId = ""
    required init () {}
}

