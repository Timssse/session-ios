// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMShareManager{
    
    class func shareToPaltm(title: String,imagestr: String?,urlStr: String) {
        var items = [Any]()
        if title.count != 0 {
            items.append(title)
        }

        if let image = UIImage(named: "icon_share_logo"){
            items.append(image)
        }
        if let url = URL(string: urlStr){
            items.append(url)
        }


        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let nav = UIUtil.visibleVC() {
            nav.present(vc, animated: true, completion: nil)
        }
    }
    
    
    class func shareToPaltm(title: String,image: UIImage?,urlStr: String,presentVC : UIViewController? = nil) {
           
           var items = [Any]()
           if title.count != 0 {
               items.append(title)
           }
           
           if let image = image{
               items.append(image)
           }
           if let url = URL(string: urlStr){
               items.append(url)
           }
           
           
           let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
         
        
           if let nav = presentVC ?? UIUtil.visibleVC() {
               nav.present(vc, animated: true, completion: nil)
           }

       }
    
}

