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
        let view = GQImageVideoViewer.sharedInstance()!;
        view.backgroundColor = UIColor.black
        view.placeholderImage = icon_default
        view.dataArray = imageArray
        view.usePageControl = false
        view.selectIndex = selectIndex
        view.achieveSelectIndex = {index in
//            labNum.text = "\(index + 1)/\(images.count)"
        }
        view.show(in: UIUtil.getWindow())
    }
}
