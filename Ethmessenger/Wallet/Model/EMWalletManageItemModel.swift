// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

enum EMWalletManageItemType{
    case address
    case changePassword
    case monetary
    case privateKey
    case mnemonics
    case rpcNode
    
    static func createManageData()->[EMWalletManageItemModel]{
        return [
            EMWalletManageItemModel(title: LocalWalletAddress.localized(),content: WalletUtilities.address, type: .address,clickType: .copy),
            EMWalletManageItemModel(title: LocalChangePassword.localized(), type: .changePassword,clickType: .arrow),
//            EMWalletManageItemModel(title: LocalMonetary.localized(), type: .monetary,clickType: .arrow),
            EMWalletManageItemModel(title: LocalViewPrivateKey.localized(), type: .privateKey,clickType: .arrow),
            EMWalletManageItemModel(title: LocalViewMnemonics.localized(), type: .mnemonics,clickType: .arrow),
            EMWalletManageItemModel(title: LocalRPCNode.localized(), type: .rpcNode,clickType: .arrow)
        ]
    }
    
}

enum EMWalletManageClickType{
    case copy
    case arrow
}

struct EMWalletManageItemModel{
    var title : String
    var content : String
    var type : EMWalletManageItemType
    var clickType : EMWalletManageClickType
    init(title: String, content: String = "", type: EMWalletManageItemType, clickType: EMWalletManageClickType) {
        self.title = title
        self.content = content
        self.type = type
        self.clickType = clickType
    }
}
