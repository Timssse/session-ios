// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import Foundation
import SDWebImage
import AVFoundation
struct FileUtilities{
    private static let imageTypes : [String] =  ["jpeg","jpg","gif","png","bmp","webp","svg"];
    static func fileIsImage(_ type : String) -> Bool{
        return imageTypes.contains(type)
    }
    
    private static let videoTypes : [String] =  ["swf","avi","flv","mpg","rm","mov","wav","asf","3gp","mkv","rmvb","mp4"];
    static func fileIsVideo(_ type : String) -> Bool{
        return videoTypes.contains(type)
    }
    
    //
    static func getVideoThumbImage(videoPath : String) async -> UIImage?{
        guard let videoURL = URL(string: videoPath) else{
            return nil
        }
        //先从缓存中找是否有图片
        let cache =  SDImageCache.shared
        if let memoryImage =  cache.imageFromMemoryCache(forKey: videoURL.absoluteString){
            return memoryImage
        }
        if let diskImage =  cache.imageFromDiskCache(forKey: videoURL.absoluteString){
            return diskImage
        }
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset);
        let time = CMTime(value: 1, timescale: 1)
        do {
            let image = try generator.copyCGImage(at: time, actualTime: nil)
            let thumbImage = UIImage(cgImage: image)
            await cache.store(thumbImage, forKey: videoURL.absoluteString,toDisk: true)
            return thumbImage
        }catch{
            return nil
        }
    }
    
}
