// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMMyNav: UIView {
    let btnCard = UIButton(image: UIImage(named: "icon_user_card"))
//    let backBtn = UIButton(type: .system,image: UIImage(named: "icon_back"),tintColor: .white)
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutUI() {
        let nav = UIView()
        self.addSubview(nav)
        nav.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(statusBarH)
        }
        
        nav.addSubview(userInfoView)
        userInfoView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.centerY.equalToSuperview().offset(-5.w)
            make.height.equalTo(36.w)
        }
        
        btnCard.addTarget(self, action: #selector(onclickCard), for: .touchUpInside)
        nav.addSubview(btnCard)
        btnCard.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20.w)
            make.centerY.equalToSuperview()
        }
        
//        backBtn.addTarget(self, action: #selector(popPage), for: .touchUpInside)
//        nav.addSubview(backBtn)
//        backBtn.snp.makeConstraints { make in
//            make.left.top.bottom.equalToSuperview()
//            make.width.equalTo(60.w)
//        }
    }
    
    lazy var userInfoView : UIView = {
        let view = UIView()
        view.isHidden = true
        userIcon.dealBorderLayer(corner: 17.w, bordercolor: .value(.white, alpha: 0.5), borderwidth: 2)
        view.addSubview(userIcon)
        userIcon.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 34.w, height: 34.w))
        }
        view.addSubview(userName)
        userName.snp.makeConstraints { make in
            make.left.equalTo(userIcon.snp.right).offset(9.w)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }
        return view
    }()
    
    lazy var userIcon : UIImageView = UIImageView(UIColor.clear,corner: 17.w)
    
    lazy var userName : UILabel = UILabel(font: UIFont.Bold(size: 20),textColor: .white)
    
    var userInfo : EMCommunityUserEntity?{
        didSet{
            userName.text = userInfo?.Nickname
            userIcon.sd_setImage(with: URL(string: FS(userInfo?.Avatar)), placeholderImage: UIImage(named: "icon_community_logo"))
        }
    }

    
    var profile : Profile?
}

extension EMMyNav{
    @objc func popPage(){
        UIUtil.visibleNav()?.popViewController(animated: true)
    }
    
    @objc func onclickSetting(){
        UIUtil.visibleNav()?.pushViewController(EMSettingPage(), animated: true)
    }
    
    @objc func onclickCard(){
        if userInfo == nil || profile == nil {
            return
        }
        UIUtil.visibleNav()?.pushViewController(EMUserCardPage(userInfo: profile!, emUserInfo: userInfo!), animated: true)
    }
}
