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
        
//        let labNum = UILabel(font: UIFont.Regular(size: 18),textColor: .white,text: "\(selectIndex + 1)/\(images.count)")
        
        let view = GQImageVideoViewer.sharedInstance()!;
        view.backgroundColor = UIColor.black
        view.dataArray = imageArray
        view.usePageControl = false
        view.selectIndex = selectIndex
        view.achieveSelectIndex = {index in
//            labNum.text = "\(index + 1)/\(images.count)"
        }
        view.show(in: UIUtil.getWindow())
        
//        view.addSubview(labNum)
//        labNum.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.bottom.equalToSuperview().offset(-safeBottomH)
//        }
    }
}
