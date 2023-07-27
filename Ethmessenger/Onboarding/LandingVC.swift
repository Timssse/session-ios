// Copyright © 2022 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionUIKit

final class LandingVC: BaseVC ,EMHideNavigationBarProtocol{
    
    
    private lazy var registerButton: UIButton = {
        let result = UIButton(title: "CREATE_GROUP_BUTTON_TITLE".localized(),font: UIFont.Medium(size: 13),color: .white,backgroundColor: .messageBubble_outgoingBackground)
        result.dealLayer(corner: 14.w)
        result.addTarget(self, action: #selector(register), for: .touchUpInside)
        return result
    }()
    
    private lazy var restoreButton: UIButton = {
        let result = UIButton(title: "LocalRecovery".localized(),font: UIFont.Medium(size: 13),color: .textPrimary)
        result.dealBorderLayer(corner: 14.w, bordercolor: .textPrimary, borderwidth: 1)
        result.addTarget(self, action: #selector(restore), for: .touchUpInside)
        return result
    }()
    
    
    
    
    lazy var circleView : EMBannerView = {
        let circleView = EMBannerView(frame: CGRect(x: 0, y: 0, width: Screen_width, height:630.w))
        circleView.itemSize = CGSize(width: Screen_width , height: 630.w)
        circleView.isAutomatic = false
        circleView.itemSpacing = 0
        circleView.didScrollToIndex = { index in
            self.labTitle.text = self.titles[index]
            self.labContent.text = self.contents[index]
        }
        circleView.isInfinite = false
        var images = [UIImage]()
        for i in 0..<3 {
            if let image = UIImage(named: "Guidance_\(i + 1)"){
                images.append(image)
            }
        }
        circleView.bgImages = images
        circleView.setImagesGroup(images)
        circleView.pageControlIsHidden = true
        return circleView
    }()
    
    lazy var titles : [String] = {
        return ["Ethmessenger","LocalChatPhoneMedia".localized(),"LocalTopNotchSecurity".localized()]
    }()
    
    lazy var contents : [String] = {
        return ["LocalGuidance1Tips".localized(),"LocalGuidance2Tips".localized(),"LocalGuidance3Tips".localized()]
    }()
    
    lazy var labTitle : UILabel = {
        let lab = UILabel(font: UIFont.Bold(size: 45),textColor: .textPrimary,text: self.titles.first)
        lab.numberOfLines = 2
        return lab
    }()
    
    lazy var labContent : UILabel = {
        let lab = UILabel(font: UIFont.Medium(size: 11),textColor: .textPrimary,text: self.contents.first)
        lab.numberOfLines = 0
        lab.textAlignment = .center
        return lab
    }()
    
    lazy var bottomView : UIView = {
        let bottomView = UIView(.newConversation_background)
        bottomView.dealCorner(type: .topLeftRight, corner: 20.w)
        bottomView.addSubview(restoreButton)
        restoreButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24.w)
            make.bottom.equalToSuperview().offset(-safeBottomH)
            make.size.equalTo(CGSize(width: 124.w, height: 56.w))
        }
        
        bottomView.addSubview(registerButton)
        registerButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24.w)
            make.bottom.equalToSuperview().offset(-safeBottomH)
            make.size.equalTo(CGSize(width: 124.w, height: 56.w))
        }
        
        let line = UIView(.line)
        bottomView.addSubview(line)
        line.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24.w)
            make.left.equalToSuperview().offset(24.w)
            make.bottom.equalTo(restoreButton.snp.top).offset(-11.w)
            make.height.equalTo(1)
        }
        
        bottomView.addSubview(labContent)
        labContent.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24.w)
            make.left.equalToSuperview().offset(24.w)
            make.bottom.equalTo(line.snp.top).offset(5.w)
            make.top.equalToSuperview()
            make.height.equalTo(107.w)
        }
    
        return bottomView
    }()
    
    // MARK: - Settings
    
    private static let fakeChatViewHeight =  CGFloat(260)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.themeBackgroundColor = .tab_select_bg
        
        self.view.addSubview(labTitle)
        labTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24.w)
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(statusBarH + 10.w)
            make.height.equalTo(130.w)
        }
        
        self.view.addSubview(circleView)
        circleView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(630.w)
        }
        
        self.view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Interaction
    
    @objc private func register() {
        let registerVC = RegisterVC()
        navigationController!.pushViewController(registerVC, animated: true)
    }
    
    @objc private func restore() {
        let restoreVC = RestoreVC()
        navigationController!.pushViewController(restoreVC, animated: true)
    }
    
//    @objc private func link() {
//        let linkVC = LinkDeviceVC()
//        navigationController!.pushViewController(linkVC, animated: true)
//    }
}
