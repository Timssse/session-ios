// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMUserInfoCell: BaseTableViewCell {
    let arrowIcon = UIImageView(image: UIImage(named: "icon_user_arrow"))
    override func layoutUI() {
        
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickEdit)))
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.contentView.dealLayer(corner: 0)
        userIcon.dealBorderLayer(corner: 36.w, bordercolor: .value(.white, alpha: 0.5), borderwidth: 2)
        userIcon.contentMode = .scaleAspectFill
        self.contentView.addSubview(userIcon)
        userIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.top.equalToSuperview()
            make.size.equalTo(CGSize(width: 72.w, height: 72.w))
        }
        
        self.contentView.addSubview(userName)
        userName.snp.makeConstraints { make in
            make.left.equalTo(userIcon.snp.right).offset(15.w)
            make.top.equalTo(userIcon).offset(5.w)
        }
        
        
        let labSessionIdTitle = UILabel(font: UIFont.Regular(size: 12),textColor: .color_91979D,text: "Session ID")
        self.contentView.addSubview(labSessionIdTitle)
        labSessionIdTitle.snp.makeConstraints { make in
            make.left.equalTo(userIcon.snp.right).offset(15.w)
            make.top.equalTo(userName.snp.bottom).offset(10.w)
            make.height.equalTo(22.w)
        }
        
        
        self.contentView.addSubview(sessionView)
        sessionView.snp.makeConstraints { make in
            make.left.equalTo(labSessionIdTitle.snp.right)
            make.top.equalTo(userName.snp.bottom).offset(10.w)
            make.height.equalTo(22.w)
        }
        
        self.contentView.addSubview(arrowIcon)
        arrowIcon.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-30.w)
            make.centerY.equalTo(userIcon)
        }
        
        let line = UIView(.line)
        self.contentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.right.equalToSuperview().offset(-25.w)
            make.top.equalTo(userIcon.snp.bottom).offset(22.w)
            make.height.equalTo(1)
        }
        
        self.contentView.addSubview(momentsView)
        momentsView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(line.snp.bottom).offset(12.w)
            make.width.equalToSuperview().multipliedBy(1/3.0)
        }
        
        self.contentView.addSubview(followingView)
        followingView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(momentsView)
            make.width.equalToSuperview().multipliedBy(1/3.0)
        }
        
        self.contentView.addSubview(followerView)
        followerView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalTo(momentsView)
            make.width.equalToSuperview().multipliedBy(1/3.0)
        }
        
        self.contentView.addSubview(walletView)
        walletView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.right.equalToSuperview().offset(-25.w)
            make.top.equalTo(momentsView.snp.bottom).offset(21.w)
            make.bottom.equalToSuperview().offset(-20.w)
            make.height.equalTo(75.w)
        }
    }

    lazy var userIcon : UIImageView = UIImageView(UIColor.clear,corner: 36.w)
    
    lazy var userName : UILabel = UILabel(font: UIFont.Bold(size: 20),textColor: .textPrimary)
    
    lazy var sessionView : UIView = {
        let view = UIView(.user_session_bg)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(copySessionID)))
        view.dealBorderLayer(corner: 11.w, bordercolor: .line, borderwidth: 1)
        view.addSubview(labSessionId)
        labSessionId.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(3.w)
            make.centerY.equalToSuperview()
        }
        let iconCopy = UIImageView(image: UIImage(named: "icon_user_copy"))
        view.addSubview(iconCopy)
        iconCopy.snp.makeConstraints { make in
            make.left.equalTo(labSessionId.snp.right).offset(8.w)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10.w)
        }
        return view
    }()
    
    lazy var labSessionId : UILabel = UILabel(font: UIFont.Regular(size: 12),textColor: .color_91979D)
    
    lazy var momentsView : UIView = {
        let view = UIView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickMoments)))
        view.addSubview(labMoments)
        labMoments.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        let labMomentsTitle : UILabel = UILabel(font: UIFont.Medium(size: 14),textColor: .color_616569,text: LocalMoments.localized())
        view.addSubview(labMomentsTitle)
        labMomentsTitle.snp.makeConstraints { make in
            make.top.equalTo(labMoments.snp.bottom).offset(4.w)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        return view
    }()
    
    lazy var labMoments : UILabel = UILabel(font: UIFont.Medium(size: 14),textColor: .textPrimary)
    
    lazy var followingView : UIView = {
        let view = UIView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickFans)))
        view.addSubview(labFollowing)
        labFollowing.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        let labFollowTitle : UILabel = UILabel(font: UIFont.Medium(size: 14),textColor: .color_616569,text: LocalFollowing.localized())
        view.addSubview(labFollowTitle)
        labFollowTitle.snp.makeConstraints { make in
            make.top.equalTo(labFollowing.snp.bottom).offset(4.w)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        return view
    }()
    
    lazy var labFollowing : UILabel = UILabel(font: UIFont.Medium(size: 14),textColor: .textPrimary)
    
    lazy var followerView : UIView = {
        let view = UIView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickFans)))
        view.addSubview(labFollower)
        labFollower.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        let labFollowTitle : UILabel = UILabel(font: UIFont.Medium(size: 14),textColor: .color_616569,text: LocalFollower.localized())
        view.addSubview(labFollowTitle)
        labFollowTitle.snp.makeConstraints { make in
            make.top.equalTo(labFollower.snp.bottom).offset(4.w)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        return view
    }()
    
    lazy var labFollower : UILabel = UILabel(font: UIFont.Medium(size: 14),textColor: .textPrimary)
    
    lazy var walletView : EMWalletCardView = {
        let view = EMWalletCardView()
        return view
    }()
    
    var emUserInfo : EMCommunityUserEntity?{
        didSet{
            userName.text = emUserInfo?.Nickname
            userIcon.sd_setImage(with: URL(string: emUserInfo?.Avatar ?? ""), placeholderImage: UIImage(named: "icon_community_logo"))
            labFollowing.text = FS(emUserInfo?.FollowCount)
            labFollower.text = FS(emUserInfo?.FansCount)
            labMoments.text = FS(emUserInfo?.TwCount)
        }
    }
    
    var userInfo : Profile?{
        didSet{
            self.labSessionId.text = "：" + FS(userInfo?.id.showAddress(6))
        }
    }
    
    @objc func onclickMoments(){
        UIUtil.visibleNav()?.pushViewController(EMMomentsUserPage(), animated: true)
    }
    
    @objc func onclickEdit(){
        guard let user = emUserInfo else{
            return
        }
        let vc = EMUserEditPage()
        vc.emUserInfo = user
        UIUtil.visibleNav()?.pushViewController(vc, animated: true)
    }
    
    @objc func onclickFans(){
        UIUtil.visibleNav()?.pushViewController(EMUserFollowMainPage(), animated: true)
    }
    
    @objc func copySessionID(){
        UIPasteboard.general.string = FS(userInfo?.id)
        Toast.toast(hit: "copied".localized())
    }
}

