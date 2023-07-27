// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import Photos
extension UIViewController{
    //截屏
    func getScreenViewImage(view : UIView) -> UIImage?{
        //截屏
        let screenRect = view.bounds
        UIGraphicsBeginImageContextWithOptions(screenRect.size, true, 0.0)
        let ctx:CGContext = UIGraphicsGetCurrentContext()!
        view.layer.render(in: ctx)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return image
    }
    
    
    func getGaussianBlurViewImage(view : UIView ,inputRadius : Int = 9) -> UIImage?{
        if let image = getScreenViewImage(view: view){
            guard let ciImage = CIImage(image: image) else { return nil }
            // 创建高斯模糊滤镜类
            guard let blurFilter = CIFilter(name: "CIGaussianBlur") else { return nil }
           
            // key 可以在控制台打印 po blurFilter.inputKeys
            // 设置图片
            blurFilter.setValue(ciImage, forKey: "inputImage")
            // 设置模糊值
            blurFilter.setValue(inputRadius, forKey: "inputRadius")
            // 从滤镜中 取出图片
            guard let outputImage = blurFilter.outputImage else { return nil }

            // 创建上下文
            let context = CIContext(options: nil)
            // 根据滤镜中的图片 创建CGImage
            guard let cgImage = context.createCGImage(outputImage, from: ciImage.extent) else { return nil }
           
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
    func canPhotoLibary() ->Bool{
        let authStatus : PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        if authStatus == .authorized || authStatus == .notDetermined {
            return true
        }else{
            return false
        }
    }
    
    func saveImage(image: UIImage) {
        DispatchQueue.global(qos: .default).async {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { (success, error) in
                //操作完成，调用主线程来刷新界面
                DispatchQueue.main.async {
                    if let _ = error{
                
                    }else{
                        Toast.toast(hit: LocalSaveSuccess.localized())
//                        TWLHUD.showTip(tip: "保存成功")
                    }
                }
            }
        }
        
    }
}
