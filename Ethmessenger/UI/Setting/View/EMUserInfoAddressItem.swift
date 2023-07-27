// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionMessagingKit
import SessionUIKit
class EMUserInfoAddressItem: UIView {
    
    convenience init(title : String,dotColor : ThemeValue){
        self.init(.conversationButton_background,corner: 15.w)
        let titleView = UIView()
        titleView.dealBorderLayer(corner: 15.w, bordercolor: .borderLine, borderwidth: 1)
        self.addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(30.w)
        }
        
        let dot = UIView(dotColor,corner: 5.w)
        titleView.addSubview(dot)
        dot.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15.w)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 10.w, height: 10.w))
        }
        
        let labTitle = UILabel(font: UIFont.Bold(size: 13),textColor: .textPrimary,text: title)
        titleView.addSubview(labTitle)
        labTitle.snp.makeConstraints { make in
            make.left.equalTo(dot.snp.right).offset(10.w)
            make.centerY.equalToSuperview()
        }
        
        let btnCopy = UIButton(type: .system,title:"  " + LocalCopy.localized(),font: UIFont.Bold(size: 13),image: UIImage(named: "icon_setting_copy"),tintColor: .textPrimary)
        btnCopy.addTarget(self, action: #selector(copyString(_:)), for: .touchUpInside)
        titleView.addSubview(btnCopy)
        btnCopy.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15.w)
            make.centerY.equalToSuperview()
        }
        
        self.addSubview(labContent)
        labContent.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15.w)
            make.right.equalToSuperview().offset(-15.w)
            make.top.equalTo(titleView.snp.bottom).offset(15.w)
            make.bottom.equalToSuperview().offset(-15.w)
        }
    }
    
    
    lazy var labContent : UILabel = {
        let lab = UILabel(font: UIFont.Regular(size: 12),textColor: .textGary)
        lab.numberOfLines = 0
        return lab
    }()
    
    @objc func copyString(_ sender : UIButton){
        UIPasteboard.general.string = self.labContent.text
        Toast.toast(hit: "copied".localized())
    }
}
