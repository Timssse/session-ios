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
    
    //展示导航按钮图片
    func showNavItemImageRight(itemImages: [String]) {
        var items = [UIBarButtonItem]()
        for (index,str) in itemImages.enumerated() {
            let btn = getNavImageBtn(imageStr: str)
            if index == 1 {
                btn.addTarget(self, action: #selector(onRightAction1), for: .touchUpInside)
            }else{
                btn.addTarget(self, action: #selector(onRightAction), for: .touchUpInside)
            }
            let btnItem = UIBarButtonItem(customView: btn)
            items.append(btnItem)
        }
        self.navigationItem.rightBarButtonItems = items
    }
    
    //MARK: 设置右侧title
    func showNavRight(_ string:String) {
        let btn = getNavTitleBtn(title: string)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(onRightAction), for: .touchUpInside)
        
        let btnItem = UIBarButtonItem(customView: btn)
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.rightBarButtonItem = btnItem;
    }
    
    func getNavImageBtn(imageStr: String) -> UIButton {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        if imageStr.count != 0 {
            btn.setImage(UIImage(named: imageStr), for: .normal)
        }
        btn.contentHorizontalAlignment = .right
        return btn
    }
    
    private func getNavTitleBtn(title: String) -> UIButton {
        var title = title
        let btn = UIButton()
        if title.count > 12 {
            title = FS(title.prefix(12))
        }
        btn.sizeToFit()
        btn.setTitle(title, for: .normal)
        btn.setThemeTitleColor(.messageBubble_outgoingBackground, for: .normal)
        btn.titleLabel?.font = UIFont.Medium(size: 13)
        return btn
    }
}

extension UIViewController{
    @objc func onRightAction(){
        
    }
    
    @objc func onRightAction1(){
        
    }
}
