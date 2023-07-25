// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

enum EMPlaceholder {
    case empty
    case emptyTwitter(isPost : Bool,target : Any? = nil,postAction : Selector? = nil)
    
    static func show(_ type: EMPlaceholder = empty,frame: CGRect = CGRectMake(0, 0, Screen_width, Screen_height - 100.h),centerY : CGFloat = 0) -> UIView {
        return EMEmptyView.createView(type,frame: frame,centerY: centerY)
    }
}

class EMEmptyView {
    class func createView(_ type : EMPlaceholder,frame: CGRect,centerY : CGFloat) -> UIView{
        switch type{
        case .empty:
            return createEmptyView(frame,centerY: centerY)
        case .emptyTwitter(let isPost,let target,let action):
            return createTwitterEmptyView(frame, centerY: centerY,isPost: isPost,target: target,postAction: action)
        }
    }
    
    class func createTwitterEmptyView(_ frame : CGRect,centerY : CGFloat,isPost : Bool = true,target : Any?,postAction : Selector?) -> UIView{
        let view = UIView.init(frame: frame)
        let icon = UIImageView.init(image: UIImage(named: "placeholder_twitter"))
        view.addSubview(icon)
        icon.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(centerY)
            make.size.equalTo(CGSize.init(width: 182.w, height: 140.w))
        }
        
        let labContent = UILabel(font: UIFont.Medium(size: 14),textColor: .emptyContent,text: LocalNotContent.localized())
        view.addSubview(labContent)
        labContent.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(icon.snp.bottom)
        }
        
        if isPost{
            let btnPost = UIButton(title: LocalPublish.localized(),font: UIFont.Bold(size: 14),color: .white,backgroundColor: .messageBubble_outgoingBackground)
            btnPost.dealLayer(corner: 19.w)
            btnPost.addTarget(target, action: postAction!, for: .touchUpInside)
            view.addSubview(btnPost)
            btnPost.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(labContent.snp.bottom).offset(11.w)
                make.size.equalTo(CGSize(width: 112.w, height: 38.w))
            }
        }
        
        return view
    }
    
    class func createEmptyView(_ frame : CGRect,centerY : CGFloat) -> UIView{
        let view = UIView.init(frame: frame)
        let icon = UIImageView.init(image: UIImage(named: "placeholder_twitter"))
        view.addSubview(icon)
        icon.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(centerY)
            make.size.equalTo(CGSize.init(width: 182.w, height: 140.w))
        }
        
        
        return view
    }
    
}
