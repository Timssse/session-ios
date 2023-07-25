// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import Foundation

//MARK:-将对象安全的转换为String
func FS(_ id : Any?)->String
{
    if(id is String){
        return id as! String
    }
    if(id == nil){
        return ""
    }
    return "\(id!)"
}
