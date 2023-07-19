// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionUIKit
import SignalUtilitiesKit

class EMChatGroupInfoCell: BaseTableViewCell {
    
    override func layoutUI() {
        self.contentView.themeBackgroundColor = .navBack
        self.contentView.addSubview(profilePictureView)
        profilePictureView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30.w)
            make.size.equalTo(CGSize(width: Values.largeProfilePictureSize, height: Values.largeProfilePictureSize))
        }
        
        self.contentView.addSubview(labName)
        labName.snp.makeConstraints { make in
            make.centerX.equalTo(profilePictureView)
            make.top.equalTo(profilePictureView.snp.bottom).offset(10.w)
            make.bottom.equalToSuperview().offset(-20.w)
        }
    }
    
    lazy var profilePictureView: ProfilePictureView = {
        let view: ProfilePictureView = ProfilePictureView()
        view.accessibilityLabel = "Profile picture"
        view.isAccessibilityElement = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.size = Values.largeProfilePictureSize
        return view
    }()
    
    lazy var labName : UILabel = {
        let lab = UILabel(font: UIFont.Bold(size: 19),textColor: .textPrimary)
        return lab
    }()
    
    var threadViewModel : SessionThreadViewModel!{
        didSet{

            profilePictureView.update(
                publicKey: threadViewModel.threadId,
                profile: threadViewModel.profile,
                additionalProfile: threadViewModel.additionalProfile,
                threadVariant: threadViewModel.threadVariant,
                openGroupProfilePictureData: threadViewModel.openGroupProfilePictureData,
                useFallbackPicture: (
                    threadViewModel.threadVariant == .openGroup &&
                    threadViewModel.openGroupProfilePictureData == nil
                ),
                showMultiAvatarForClosedGroup: true
            )
            
            labName.text = threadViewModel.displayName
        }
    }
}
