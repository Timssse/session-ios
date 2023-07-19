// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import GQImageVideoViewer
class EMPhotoLookUtilities {
    static func showImages(images : [EMCommunityFileEntity],selectIndex : Int){
        var imageArray : [Any] = []
        images.forEach { model in
            if let url = URL(string: model.path){
                imageArray.append([GQIsImageURL:model.type == .image,GQURLString:url] as [String : Any])
            }
        }
        
        GQImageVideoViewer.sharedInstance().dataArray = imageArray
        GQImageVideoViewer.sharedInstance().usePageControl = true
        GQImageVideoViewer.sharedInstance().selectIndex = selectIndex
        GQImageVideoViewer.sharedInstance().achieveSelectIndex = {index in
            
        }
        GQImageVideoViewer.sharedInstance().show(in: UIUtil.visibleVC()?.view)
    }
}
