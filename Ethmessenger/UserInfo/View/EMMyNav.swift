// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMMyNav: UIView {
    let btnSetting = UIButton(image: UIImage(named: "icon_user_setting"))
    let btnCard = UIButton(image: UIImage(named: "icon_user_card"))
    let backBtn = UIButton(type: .system,image: UIImage(named: "icon_back"),tintColor: .white)
    
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
        
//        nav.addSubview(chainView)
//        chainView.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(20.w)
//            make.centerY.equalToSuperview().offset(-5.w)
//            make.height.equalTo(36.w)
//        }
        
        nav.addSubview(userInfoView)
        userInfoView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.centerY.equalToSuperview().offset(-5.w)
            make.height.equalTo(36.w)
        }
        
        
        btnSetting.addTarget(self, action: #selector(onclickSetting), for: .touchUpInside)
        nav.addSubview(btnSetting)
        btnSetting.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20.w)
            make.centerY.equalToSuperview()
        }
        
        
        btnCard.addTarget(self, action: #selector(onclickCard), for: .touchUpInside)
        nav.addSubview(btnCard)
        btnCard.snp.makeConstraints { make in
            make.right.equalTo(btnSetting.snp.left).offset(-16.w)
            make.centerY.equalToSuperview()
        }
        
        
        backBtn.isHidden = true
        backBtn.addTarget(self, action: #selector(popPage), for: .touchUpInside)
        nav.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(60.w)
        }
    }
    
    lazy var chainView : UIView = {
        let view = UIView(UIColor(white: 1, alpha: 0.2),corner: 18.w)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickChain)))
        view.addSubview(chainIcon)
        chainIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(9.w)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 24.w, height: 24.w))
        }
        view.addSubview(chainName)
        chainName.snp.makeConstraints { make in
            make.left.equalTo(chainIcon.snp.right).offset(7.w)
            make.centerY.equalToSuperview()
        }
        let iconTriangle = UIImageView(image: UIImage(named: "icon_chats_triangle"))
        view.addSubview(iconTriangle)
        iconTriangle.snp.makeConstraints { make in
            make.left.equalTo(chainName.snp.right).offset(7.w)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-9.w)
        }
        return view
    }()
    
    lazy var chainIcon : UIImageView = UIImageView(UIColor.clear,corner: 12.w)
    
    lazy var chainName : UILabel = UILabel(font: UIFont.Medium(size: 14),textColor: .black)
    
    lazy var userInfoView : UIView = {
        let view = UIView()
        view.isHidden = true
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
    
    var chain : EMNetworkModel? {
        didSet{
            chainIcon.sd_setImage(with: URL(string: FS(chain?.icon)), placeholderImage: UIImage(named: "icon_community_default"))
            chainName.text = chain?.chain_symbol
        }
    }
    
    var userInfo : EMCommunityUserEntity?{
        didSet{
            userName.text = userInfo?.Nickname
            userIcon.sd_setImage(with: URL(string: FS(userInfo?.Avatar)), placeholderImage: UIImage(named: "icon_community_default"))
        }
    }
    
    var isOther = false {
        didSet{
            userInfoView.isHidden = isOther
            btnSetting.isHidden = isOther
            btnCard.isHidden = isOther
            backBtn.isHidden = !isOther
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
    
    @objc func onclickChain(){
        EMTabBarController.shared?.hiddenTabbar()
        EMAlert.alert(.selectNetwork).cancelAction {
            EMTabBarController.shared?.showTabbar()
        }.popup()
    }
}
