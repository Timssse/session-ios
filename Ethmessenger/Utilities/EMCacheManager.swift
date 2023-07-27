// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import WebKit
import SDWebImage
class EMCacheManager: NSObject {
    static let share = EMCacheManager()
    
    func getCacheSize() -> String{
        let size = SDImageCache.shared.totalDiskSize()
        if size > 1024 * 1024 * 1024{
            return String(format: "%.1f GB", CGFloat(size) / 1024.0 / 1024.0 / 1024.0)
        }
        
        if size > 1024 * 1024 {
            return String(format: "%.1f MB", CGFloat(size) / 1024.0 / 1024.0)
        }
        
//        if size > 1024 {
//            return String(format: "%.1f KB", CGFloat(size) / 1024.0 )
//        }
        
        return String(format: "%.1f KB", CGFloat(size) / 1024.0 )
    }
    
    func cleanCache() async{
//        let dateFrom: NSDate = NSDate.init(timeIntervalSince1970: 0)
//        let websiteDataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
//        await WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: dateFrom as Date)
        SDImageCache.shared.clearMemory()
        await SDImageCache.shared.clearDiskOnCompletion()
    }
    
}
