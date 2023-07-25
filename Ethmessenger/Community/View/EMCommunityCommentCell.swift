// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMCommunityCommentCell: BaseTableViewCell {
    
    override func layoutUI() {
        self.contentView.themeBackgroundColor = .conversationButton_background
        self.contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalToSuperview().offset(5.w)
            make.size.equalTo(CGSize(width: 40.w, height: 40.w))
        }
        
        self.contentView.addSubview(labName)
        labName.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(15.w)
            make.top.equalTo(icon).offset(3.w)
        }
        
        let more = UIButton(type: .system,image: UIImage(named: "icon_community_more"),tintColor: .setting_icon_icon)
        more.addTarget(self, action: #selector(onclickMore(_:)), for: .touchUpInside)
        self.contentView.addSubview(more)
        more.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-25.w)
            make.centerY.equalTo(labName)
        }
        
        self.contentView.addSubview(labContent)
        labContent.snp.makeConstraints { make in
            make.left.equalTo(labName)
            make.right.equalToSuperview().offset(-25.w)
            make.top.equalTo(labName.snp.bottom).offset(10.w)
        }
        
        self.contentView.addSubview(labTime)
        labTime.snp.makeConstraints { make in
            make.left.equalTo(labName)
            make.top.equalTo(labContent.snp.bottom).offset(10.w)
            make.bottom.equalToSuperview().offset(-5.w)
        }
    }

    
    lazy var icon : UIImageView = {
        let icon = UIImageView()
        icon.dealLayer(corner: 20.w)
        return icon
    }()
    
    lazy var labName : UILabel = {
        let lab = UILabel(font: UIFont.Bold(size: 15),textColor: .textPrimary)
        return lab
    }()
    
    lazy var labTime : UILabel = {
        let lab = UILabel(font: UIFont.Medium(size: 12),textColor: .textGary1)
        return lab
    }()
    
    lazy var labContent : UILabel = {
        let lab = UILabel(font: UIFont.Regular(size: 13),textColor: .textPrimary)
        lab.numberOfLines = 0
        return lab
    }()
    
    var model : EMCommunityCommentEntity!{
        didSet{
            self.labName.text = model.UserInfo?.Nickname
            labContent.text = model.Content
            icon.sd_setImage(with: URL(string: model.UserInfo?.Avatar ?? ""), placeholderImage: icon_default)
            labTime.text = model.CreatedAt.showTime
        }
    }
    
    @objc func onclickMore(_ sender : UIButton){
        var frame = sender.convert(sender.bounds, to: UIUtil.getWindow()!)
        frame.origin.x -= 55.w
        frame.origin.y += 31.w
        frame.size = CGSize(width: 77.w, height: 35.w)
        EMCommunityMoreView.share.show(UIUtil.getWindow()!,contentFrame: frame)
        EMCommunityMoreView.share.reportBlock = {
            
        }
    }
}

