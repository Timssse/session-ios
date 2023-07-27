// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMUserSettingCell: BaseTableViewCell {
    let labTitle = UILabel(font: UIFont.Bold(size: 15),textColor: .textGary)
    let labContent = UILabel(font: UIFont.Medium(size: 15),textColor: .textPrimary)
    let btnTriangle = UIButton(type: .system,font:UIFont.Bold(size: 15),image: UIImage(named: "icon_user_triangle"),tintColor: .textPrimary)
    let btnSwitch = UIButton(image: UIImage(named: "icon_chats_switch_close")?.withRenderingMode(.alwaysTemplate),selectImage: UIImage(named: "icon_chats_switch_open"))
    
    override func layoutUI() {
        self.contentView.themeBackgroundColor = .conversationButton_background
        self.contentView.addSubview(labTitle)
        labTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalToSuperview().offset(28.w)
            make.bottom.equalToSuperview().offset(-28.w)
            make.centerY.equalToSuperview()
        }
        
        labContent.numberOfLines = 0
        self.contentView.addSubview(labContent)
        labContent.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-42.w)
            make.centerY.equalToSuperview()
        }
        
        btnTriangle.isUserInteractionEnabled = false
        self.contentView.addSubview(btnTriangle)
        btnTriangle.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-25.w)
            make.centerY.equalToSuperview()
        }
        
        btnSwitch.isUserInteractionEnabled = false
        self.contentView.addSubview(btnSwitch)
        btnSwitch.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-25.w)
            make.centerY.equalToSuperview()
        }
    }

    var model : EMSettingCellModel?{
        didSet{
            btnTriangle.isHidden = model?.showArrow == false
            labTitle.text = model?.title
            labContent.text = model?.content
            btnSwitch.isHidden = (model?.type != .receiptRead && model?.type != .inputTips && model?.type != .linkPreview && model?.type != .voiceAndVideoCall && model?.type != .autoDeleteMessage)
            btnSwitch.themeTintColor = .textPrimary
            
            if model?.type == .receiptRead{
                btnSwitch.isSelected = Storage.shared[Setting.BoolKey.areReadReceiptsEnabled]
            }
            
            if model?.type == .inputTips{
                btnSwitch.isSelected = Storage.shared[Setting.BoolKey.typingIndicatorsEnabled]
            }
            
            if model?.type == .linkPreview{
                btnSwitch.isSelected = Storage.shared[Setting.BoolKey.areLinkPreviewsEnabled]
            }
            
            if model?.type == .voiceAndVideoCall{
                btnSwitch.isSelected = Storage.shared[Setting.BoolKey.areCallsEnabled]
            }
            
            if model?.type == .autoDeleteMessage{
                btnSwitch.isSelected = Storage.shared[Setting.BoolKey.trimOpenGroupMessagesOlderThanSixMonths]
            }
            
            
        }
    }
    
    
    
    private let reachability: Reachability = Reachability.forInternetConnection()
    func getStateIcon() -> UIImage?{
        switch (reachability.isReachable(), OnionRequestAPI.paths.isEmpty) {
            case (false, _): return UIImage(named: "icon_setting_path_fail")
            case (true, true): return UIImage(named: "icon_setting_path_connect")
            case (true, false): return UIImage(named: "icon_setting_path_success")
        }
    }
    
    func getLangugeIcon() -> UIImage?{
        switch (EMLocalizationTool.shared.currentLanguage) {
        case .Chinese: return UIImage(named: "icon_setting_china")
        case .English: return UIImage(named: "icon_setting_languange_us")
        }
    }
}

