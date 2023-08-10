// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMLikeCell: BaseTableViewCell {
    
    let btnStatus = UIButton(font:UIFont.Regular(size: 13.w))
    let labLikeContent = UILabel(font: UIFont.Medium(size: 14),textColor: .textPrimary,text: LocalLikeYouMoment.localized())
    
    override func layoutUI() {
        
        self.contentView.themeBackgroundColor = .conversationButton_background
        self.contentView.addSubview(icon)
        icon.dealBorderLayer(corner: 20.w, bordercolor: .value(.white, alpha: 0.5), borderwidth: 2)
        icon.isUserInteractionEnabled = true
        icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pushUserVC)))
        icon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15.w)
            make.left.equalToSuperview().offset(25.w)
            make.size.equalTo(CGSize(width: 40.w, height: 40.w))
        }
        
        self.contentView.addSubview(labName)
        labName.isUserInteractionEnabled = true
        labName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pushUserVC)))
        labName.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(12.w)
            make.top.equalTo(icon)
        }
        
        self.contentView.addSubview(labTime)
        labTime.snp.makeConstraints { make in
            make.left.equalTo(labName)
            make.top.equalTo(labName.snp.bottom)
        }
        
        btnStatus.addTarget(self, action: #selector(onclickFans), for: .touchUpInside)
        btnStatus.dealBorderLayer(corner: 6.w, bordercolor: .line, borderwidth: 1)
        self.contentView.addSubview(btnStatus)
        btnStatus.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-25.w)
            make.centerY.equalTo(icon)
            make.size.equalTo(CGSize(width: 94.w, height: 34.w))
        }
        
        self.contentView.addSubview(labLikeContent)
        labLikeContent.snp.makeConstraints { make in
            make.left.equalTo(icon)
            make.right.equalToSuperview().offset(-25.w)
            make.top.equalTo(icon.snp.bottom).offset(10.w)
        }
        
        self.contentView.addSubview(forwordView)
        forwordView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.right.equalToSuperview().offset(-25.w)
            make.top.equalTo(labLikeContent.snp.bottom).offset(10.w)
        }
        
        let line = UIView(.line)
        self.contentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.equalTo(forwordView)
            make.bottom.equalToSuperview()
            make.top.equalTo(forwordView.snp.bottom).offset(16.w)
            make.height.equalTo(1)
        }
        
    }

    lazy var icon : UIImageView = {
        let icon = UIImageView()
        icon.dealLayer(corner: 26.w)
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
        let lab = UILabel(font: UIFont.Medium(size: 15),textColor: .textPrimary,text: LocalLikeYouMoment.localized())
        lab.numberOfLines = 0
        return lab
    }()
    
    lazy var forwordView : UIView = {
        let view = UIView(.forget_textView_bg)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickDetail)))
        view.dealLayer(corner: 6.w)
        view.addSubview(labContent)
        labContent.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 13.w, left: 15.w, bottom: 13.w, right: 15.w))
        }
        return view
    }()
    
    var model : EMCommunityLikeMeEntity!{
        didSet{
            icon.sd_setImage(with: URL(string: model.UserInfo?.Avatar ?? ""),placeholderImage: UIImage(named: "icon_community_logo"))
            labName.text = model.UserInfo?.Nickname
            labTime.text = model.CreatedAt.showTime
            labContent.text = (model.Tweet ?? model.OriginTweet)?.Content
            labLikeContent.text = model.Content
            btnStatus.setTitle(model.UserInfo?.IsFollow == true ? LocalUnFollowing.localized() : LocalFollowing.localized(), for: .normal)
            btnStatus.setThemeTitleColor(model.UserInfo?.IsFollow == true ? .alertTextColor : .messageBubble_outgoingBackground, for: .normal)
        }
    }
}


extension EMLikeCell{
    @objc func pushUserVC(){
        let vc = EMOtherUserPage()
//        vc.address = FS(model.UserInfo?.UserAddress)
        UIUtil.visibleNav()?.pushViewController(vc, animated: true)
    }
    
    @objc func onclickFans(){
        Task{
            
            let follow = !(model.UserInfo?.IsFollow ?? false)
            let relust = await EMUserController.follow(follow, address: model.UserAddress)
            if relust{
                model.UserInfo?.IsFollow = !(model.UserInfo?.IsFollow ?? false)
                btnStatus.setTitle(model.UserInfo?.IsFollow == true ? LocalUnFollowing.localized() : LocalFollowing.localized(), for: .normal)
                btnStatus.setThemeTitleColor(model.UserInfo?.IsFollow == true ? .alertTextColor : .messageBubble_outgoingBackground, for: .normal)
            }
        }
    }
    
    @objc func onclickDetail(){
        let vc = EMCommunityDetailPage(model: (self.model.Tweet ?? self.model.OriginTweet)!)
        UIUtil.visibleNav()?.pushViewController(vc, animated: true)
    }
}
