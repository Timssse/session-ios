// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import Reachability

class EMSettingCell: BaseTableViewCell {
    
    let icon = UIImageView()
    let labTitle = UILabel(font: UIFont.Bold(size: 15),textColor: .textPrimary)
    let labContent = UILabel(font: UIFont.Regular(size: 12),textColor: .textPrimary)
    let btnSound = UIButton(type: .system,font:UIFont.Bold(size: 15),image: UIImage(named: "icon_chats_triangle"),tintColor: .textPrimary)
    let btnSwitch = UIButton(image: UIImage(named: "icon_chats_switch_close"),selectImage: UIImage(named: "icon_chats_switch_open"))
    
    override func layoutUI() {
        self.contentView.themeBackgroundColor = .conversationButton_background
        icon.themeTintColor = .setting_icon_icon
        self.contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(45.w)
            make.top.equalToSuperview().offset(32.w)
            make.bottom.equalToSuperview().offset(-32.w)
            make.size.equalTo(CGSize(width: 24.w, height: 24.w))
        }
        
        self.contentView.addSubview(labTitle)
        labTitle.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(25.w)
            make.centerY.equalToSuperview()
        }
        
        labContent.numberOfLines = 0
        self.contentView.addSubview(labContent)
        labContent.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(25.w)
            make.right.equalToSuperview().offset(90.w)
            make.top.equalTo(labTitle.snp.bottom)
        }
        
//        btnSound.addTarget(self, action: #selector(onclickSuond), for: .touchUpInside)
        btnSound.isUserInteractionEnabled = false
        self.contentView.addSubview(btnSound)
        btnSound.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-40.w)
            make.centerY.equalToSuperview()
        }
        
//        btnSwitch.addTarget(self, action: #selector(onclickSwitch(_:)), for: .touchUpInside)
        btnSwitch.isUserInteractionEnabled = false
        self.contentView.addSubview(btnSwitch)
        btnSwitch.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-40.w)
            make.centerY.equalToSuperview()
        }
    }

    var model : EMSettingCellModel?{
        didSet{
            icon.image = model?.type == .path ? getStateIcon() : model?.type == .language ? getLangugeIcon() : model?.icon?.withRenderingMode(.alwaysTemplate)
            labTitle.text = model?.title
            let titleCenterY = model?.type == .burnAfterReading ? -5.w : model?.type == .notifyMentionsOnly ? -10.w : 0
            labTitle.snp.updateConstraints { make in
                make.centerY.equalToSuperview().offset(titleCenterY)
            }
            labContent.text = model?.type == .burnAfterReading ? model?.disappearingMessagesConfig?.durationString : model?.type == .notifyMentionsOnly ? "vc_conversation_settings_notify_for_mentions_only_explanation".localized() : nil
            
            btnSound.isHidden = model?.type != .notication
            btnSound.setTitle("  \(model?.notificationSound?.displayName ?? "")", for: .normal)
            
            btnSwitch.isHidden = (model?.type != .mute && model?.type != .shield && model?.type != .notifyMentionsOnly)
            if model?.type == .mute{
                btnSwitch.isSelected = (model?.maybeThreadViewModel?.threadMutedUntilTimestamp != nil)
            }
            if model?.type == .shield{
                btnSwitch.isSelected = (model?.maybeThreadViewModel?.threadIsBlocked == true)
            }
            if model?.type == .notifyMentionsOnly{
                btnSwitch.isSelected = (model?.maybeThreadViewModel?.threadOnlyNotifyForMentions == true)
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

