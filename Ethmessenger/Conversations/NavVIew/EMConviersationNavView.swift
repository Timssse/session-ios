// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionMessagingKit
import SignalUtilitiesKit
import SessionUIKit

class EMConviersationNavView: UIView {
    convenience init(_ data : SessionThreadViewModel) {
        self.init()
        self.model = data
        layoutUI()
    }
    
    func layoutUI(){
        self.themeBackgroundColor = .navBack
        let contentView = UIView()
        self.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(statusBarH + 10.w)
            make.bottom.equalToSuperview().offset(-10.w)
            make.height.equalTo(54.w)
        }
        
        let backBtn = UIButton(type: .system,image: UIImage(named: "icon_back"),tintColor: .textPrimary)
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        contentView.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(80.w)
        }
        
        contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalTo(backBtn.snp.right).offset(-10.w)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(Values.mediumProfilePictureSize)
        }
        
        contentView.addSubview(labName)
        labName.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(10.w)
            make.top.equalToSuperview().offset(3.w)
        }
        contentView.addSubview(labID)
        labID.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(10.w)
            make.top.equalTo(labName.snp.bottom)
        }
        
        contentView.addSubview(btnMore)
        btnMore.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-23.w)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(23.w)
        }
        
        contentView.addSubview(btnCall)
        btnCall.snp.makeConstraints { make in
            make.right.equalTo(btnMore.snp.left).offset(-10.w)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(23.w)
        }
    }
    
    lazy var icon : ProfilePictureView = {
        let icon = ProfilePictureView()
        icon.size = Values.mediumProfilePictureSize
        return icon
    }()
    
    lazy var labName : UILabel = {
        let lab = UILabel(font: UIFont.Bold(size: 19),textColor: .textPrimary)
        return lab
    }()
    
    lazy var labID : UILabel = {
        let lab = UILabel(font: UIFont.Regular(size: 13),textColor: .textPrimary)
        return lab
    }()
    
    lazy var btnCall : UIButton = {
        let btnCall = UIButton(type: .system)
        btnCall.setImage(UIImage(named: "icon_chats_call"), for: .normal)
        btnCall.addTarget(self, action: #selector(onclickCall), for: .touchUpInside)
        btnCall.themeTintColor = .textPrimary
        return btnCall
    }()
    
    lazy var btnMore : UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "icon_chats_more"), for: .normal)
        btn.addTarget(self, action: #selector(onclickMore), for: .touchUpInside)
        btn.themeTintColor = .textPrimary
        return btn
    }()
    
    
    var model : SessionThreadViewModel! {
        didSet{
            labName.text = model.displayName
            icon.update(
                publicKey: model.threadId,
                profile: model.profile,
                additionalProfile: model.additionalProfile,
                threadVariant: model.threadVariant,
                openGroupProfilePictureData: model.openGroupProfilePictureData,
                useFallbackPicture: (
                    model.threadVariant == .openGroup &&
                    model.openGroupProfilePictureData == nil
                ),
                showMultiAvatarForClosedGroup: true
            )
            labID.text = model.threadVariant == .contact ? model?.threadId.showAddress(6) : "\(model.userCount ?? 0) members"
        }
    }

    private var searchAction: (() -> Void)? = nil
    private var callAction: (() -> Void)? = nil
}

extension EMConviersationNavView{
    @discardableResult
    func searchAction(_ action: @escaping () -> Void) -> EMConviersationNavView {
        searchAction = action
        return self
    }
    
    @discardableResult
    func callAction(_ action: @escaping () -> Void) -> EMConviersationNavView {
        callAction = action
        return self
    }
}


extension EMConviersationNavView{
    @objc func back(){
        UIUtil.visibleNav()?.popViewController(animated: true)
    }
    
    @objc func onclickCall(){
        callAction?()
    }
    
    @objc func onclickMore(){
        UIUtil.visibleNav()?.pushViewController(EMChatSettingPage(viewModel: self.model), animated: true)
    }
    
}
