// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionMessagingKit
import SessionUIKit

class EMChatSettingUserInfoCell: BaseTableViewCell {
    
    let labName : UILabel = UILabel(font: UIFont.Bold(size: 20.w),textColor: .textPrimary)
    let labSessionId : UILabel = UILabel(font: UIFont.Medium(size: 12.w),textColor: .color_91979D)
    
    override func layoutUI() {
        self.contentView.themeBackgroundColor = .navBack
        self.contentView.addSubview(profilePictureView)
        profilePictureView.dealLayer(corner: 62.w)
        profilePictureView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30.w)
            make.size.equalTo(CGSize(width: 124.w, height: 124.w))
        }
        
        self.contentView.addSubview(labName)
        labName.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profilePictureView.snp.bottom).offset(20.w)
        }
        
        labSessionId.textAlignment = .center
        labSessionId.numberOfLines = 0
        self.contentView.addSubview(labSessionId)
        labSessionId.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(293.w)
            make.top.equalTo(labName.snp.bottom).offset(11.w)
            make.bottom.equalToSuperview().offset(-10.w)
        }
        
        
//        self.contentView.addSubview(idView)
//        idView.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(25.w)
//            make.right.equalToSuperview().offset(-25.w)
//            make.top.equalTo(profilePictureView.snp.bottom).offset(20.w)
//            make.bottom.equalToSuperview().offset(-10.w)
//        }
        
    }
    
    lazy var profilePictureView: ProfilePictureView = {
        let view: ProfilePictureView = ProfilePictureView()
        view.accessibilityLabel = "Profile picture"
        view.isAccessibilityElement = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.size = 124.w
        return view
    }()
    
    
    
    
//    lazy var idView : EMUserInfoAddressItem = {
//        let idView = EMUserInfoAddressItem(title: "ID", dotColor: .path_connected)
//        return idView
//    }()
    
    
    var model : SessionThreadViewModel?{
        didSet{
            guard let model = model else{return}
            
            profilePictureView.update(
                publicKey: model.id,
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
            labName.text = {
                guard !model.threadIsNoteToSelf else {
                    guard let profile: Profile = model.profile else {
                        return Profile.truncated(id: model.threadId, truncating: .middle)
                    }
                    return profile.displayName()
                }
                return model.displayName
            }()
            labSessionId.text = model.profile?.id
        }
    }
}

