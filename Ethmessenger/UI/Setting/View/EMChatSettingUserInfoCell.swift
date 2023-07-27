// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionMessagingKit
import SessionUIKit

class EMChatSettingUserInfoCell: BaseTableViewCell {
    
    override func layoutUI() {
        self.contentView.themeBackgroundColor = .navBack
        self.contentView.addSubview(profilePictureView)
        profilePictureView.dealLayer(corner: 62.w)
        profilePictureView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30.w)
            make.size.equalTo(CGSize(width: 124.w, height: 124.w))
        }
        
        self.contentView.addSubview(idView)
        idView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.right.equalToSuperview().offset(-25.w)
            make.top.equalTo(profilePictureView.snp.bottom).offset(20.w)
            make.bottom.equalToSuperview().offset(-10.w)
        }
        
    }
    
    lazy var profilePictureView: ProfilePictureView = {
        let view: ProfilePictureView = ProfilePictureView()
        view.accessibilityLabel = "Profile picture"
        view.isAccessibilityElement = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.size = 124.w
        return view
    }()
    
    lazy var idView : EMUserInfoAddressItem = {
        let idView = EMUserInfoAddressItem(title: "ID", dotColor: .path_connected)
        return idView
    }()
    
    
    var model : Profile?{
        didSet{
            let threadViewModel = SessionThreadViewModel(
                threadId: model?.id ?? "",
                threadIsNoteToSelf: true,
                contactProfile: model
            )
            profilePictureView.update(
                publicKey: model?.id ?? "",
                profile: model,
                additionalProfile: threadViewModel.additionalProfile,
                threadVariant: threadViewModel.threadVariant,
                openGroupProfilePictureData: threadViewModel.openGroupProfilePictureData,
                useFallbackPicture: (
                    threadViewModel.threadVariant == .openGroup &&
                    threadViewModel.openGroupProfilePictureData == nil
                ),
                showMultiAvatarForClosedGroup: true
            )
            idView.labContent.text = model?.id
        }
    }
}

