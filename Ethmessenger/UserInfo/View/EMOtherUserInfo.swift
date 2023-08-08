// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMOtherUserInfo: BaseTableViewCell {
    override func layoutUI() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.contentView.dealLayer(corner: 0)
        self.contentView.addSubview(userIcon)
        userIcon.dealBorderLayer(corner: 36.w, bordercolor: .value(.white, alpha: 0.5), borderwidth: 2)
        userIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.top.equalToSuperview().offset(35.w)
            make.size.equalTo(CGSize(width: 72.w, height: 72.w))
        }
        
        self.contentView.addSubview(userName)
        userName.snp.makeConstraints { make in
            make.left.equalTo(userIcon.snp.right).offset(15.w)
            make.top.equalTo(userIcon)
        }
        
        followBtn.isHidden = true
        followBtn.dealLayer(corner: 15.w)
        self.contentView.addSubview(followBtn)
        followBtn.snp.makeConstraints { make in
            make.left.equalTo(userName)
            make.bottom.equalTo(userIcon)
            make.size.equalTo(CGSize(width: 85.w, height: 30.w))
        }
        
        self.contentView.addSubview(followingView)
        followingView.snp.makeConstraints { make in
            make.left.equalTo(userIcon)
            make.top.equalTo(userIcon.snp.bottom).offset(15.w)
            make.height.equalTo(25.w)
        }
        
        self.contentView.addSubview(followerView)
        followerView.snp.makeConstraints { make in
            make.left.equalTo(followingView.snp.right).offset(22.w)
            make.centerY.equalTo(followingView)
            make.bottom.equalToSuperview().offset(-20.w)
            make.height.equalTo(25.w)
        }
        
        let line = UIView(.line)
        self.contentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview().offset(-20.w)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }

    lazy var userIcon : UIImageView = UIImageView(UIColor.clear,corner: 36.w)
    
    lazy var userName : UILabel = UILabel(font: UIFont.Bold(size: 20),textColor: .textPrimary)
    
    lazy var followBtn : UIButton = {
        let btn = UIButton(font:UIFont.Regular(size: 12),color: .white,backgroundColor: .messageBubble_outgoingBackground)
        btn.addTarget(self, action: #selector(onclickFollow), for: .touchUpInside)
        return btn
    }()
    
    lazy var followingView : UIView = {
        let view = UIView()
        view.addSubview(labFollowing)
        labFollowing.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        let labFollowTitle : UILabel = UILabel(font: UIFont.Medium(size: 14),textColor: .color_616569,text: LocalFollowing.localized())
        view.addSubview(labFollowTitle)
        labFollowTitle.snp.makeConstraints { make in
            make.left.equalTo(labFollowing.snp.right).offset(10.w)
            make.centerY.right.equalToSuperview()
        }
        return view
    }()
    
    lazy var labFollowing : UILabel = UILabel(font: UIFont.Medium(size: 14),textColor: .textPrimary)
    
    lazy var followerView : UIView = {
        let view = UIView()
        view.addSubview(labFollower)
        labFollower.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        let labFollowTitle : UILabel = UILabel(font: UIFont.Medium(size: 14),textColor: .color_616569,text: LocalFollower.localized())
        view.addSubview(labFollowTitle)
        labFollowTitle.snp.makeConstraints { make in
            make.left.equalTo(labFollower.snp.right).offset(10.w)
            make.centerY.right.equalToSuperview()
        }
        return view
    }()
    
    lazy var labFollower : UILabel = UILabel(font: UIFont.Medium(size: 14),textColor: .textPrimary)
    
    var emUserInfo : EMCommunityUserEntity?{
        didSet{
            
            if (emUserInfo == nil){
                return
            }
            
            userName.text = emUserInfo?.Nickname
            userIcon.sd_setImage(with: URL(string: emUserInfo?.Avatar ?? ""), placeholderImage: UIImage(named: "icon_community_logo"))
            labFollowing.text = FS(emUserInfo?.FollowCount)
            labFollower.text = FS(emUserInfo?.FansCount)
            followBtn.setTitle(emUserInfo?.IsFollow == true ? LocalCancel.localized() : LocalFollowing.localized(), for: .normal)
            followBtn.isHidden = emUserInfo?.UserAddress == WalletUtilities.address
        }
    }
    
    @objc func onclickFollow(){
        guard let model = emUserInfo else{
            return
        }
        Task{
            followBtn.isUserInteractionEnabled = false
            let relust = await EMUserController.follow(model.IsFollow, address: model.UserAddress)
            if relust{
                model.IsFollow = !model.IsFollow
                self.emUserInfo = model
            }
            followBtn.isUserInteractionEnabled = true
        }
    }
    
}
