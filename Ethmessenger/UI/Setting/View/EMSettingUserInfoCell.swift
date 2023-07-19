// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionMessagingKit
import SignalUtilitiesKit
import WalletCore
import SessionUIKit
class EMSettingUserInfoCell: BaseTableViewCell {

    override func layoutUI() {
        self.contentView.themeBackgroundColor = .navBack
        self.contentView.addSubview(profilePictureView)
        profilePictureView.dealLayer(corner: 62.w)
        profilePictureView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30.w)
            make.size.equalTo(CGSize(width: 124.w, height: 124.w))
        }
        
        let shaowPhoto = UIView();
        shaowPhoto.layer.shadowColor = UIColor.init(white: 0, alpha: 0.15).cgColor
        shaowPhoto.layer.shadowOffset = CGSize(width: 0, height: 0)
        shaowPhoto.layer.shadowOpacity = 30
        shaowPhoto.layer.shadowRadius = 15.w
        shaowPhoto.layer.shadowOffset = CGSize(width: 0, height: 7)
        self.contentView.addSubview(shaowPhoto)
        shaowPhoto.snp.makeConstraints { make in
            make.right.bottom.equalTo(profilePictureView)
            make.size.equalTo(CGSize(width: 48.w, height: 48.w))
        };
        
        let photo = UIImageView(image: UIImage(named: "icon_setting_photo"))
        shaowPhoto.addSubview(photo)
        photo.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.contentView.addSubview(labName)
        labName.snp.makeConstraints { make in
            make.centerX.equalTo(profilePictureView).offset(-15.w)
            make.top.equalTo(profilePictureView.snp.bottom).offset(10.w)
        }
        
        let editIcon = UIImageView(image: UIImage(named: "icon_setting_edit")?.withRenderingMode(.alwaysTemplate))
        editIcon.themeTintColor = .textPrimary
        editIcon.isUserInteractionEnabled = true
        editIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editName)))
        self.contentView.addSubview(editIcon)
        editIcon.snp.makeConstraints { make in
            make.left.equalTo(labName.snp.right).offset(7.w)
            make.centerY.equalTo(labName)
        }
        
        self.contentView.addSubview(idView)
        idView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.right.equalToSuperview().offset(-25.w)
            make.top.equalTo(labName.snp.bottom).offset(10.w)
        }
        
        
        self.contentView.addSubview(addressView)
        addressView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.right.equalToSuperview().offset(-25.w)
            make.top.equalTo(idView.snp.bottom).offset(10.w)
            make.bottom.equalToSuperview().offset(-10.w)
        }
    }
    
//    func createItem(title : String,dotColor : ThemeValue,content : UILabel) -> UIView {
//        let view = UIView(.white)
//        view.dealLayer(corner: 15.w)
//        let titleView = UIView()
//        titleView.dealBorderLayer(corner: 15.w, bordercolor: .borderLine, borderwidth: 1)
//        view.addSubview(titleView)
//        titleView.snp.makeConstraints { make in
//            make.left.right.top.equalToSuperview()
//            make.height.equalTo(30.w)
//        }
//
//        let dot = UIView(dotColor,corner: 5.w)
//        titleView.addSubview(dot)
//        dot.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(15.w)
//            make.centerY.equalToSuperview()
//            make.size.equalTo(CGSize(width: 10.w, height: 10.w))
//        }
//
//        let labTitle = UILabel(font: UIFont.Bold(size: 13),textColor: .textPrimary,text: title)
//        titleView.addSubview(labTitle)
//        labTitle.snp.makeConstraints { make in
//            make.left.equalTo(dot.snp.right).offset(10.w)
//            make.centerY.equalToSuperview()
//        }
//
//        let btnCopy = UIButton(title:"  " + "LocalCopy".localized(),font: UIFont.Bold(size: 13),color: .textPrimary,image: UIImage(named: "icon_setting_copy"))
//        btnCopy.addTarget(self, action: #selector(copyString(_:)), for: .touchUpInside)
//        btnCopy.tag = content == self.labId ? 0 : 1
//        titleView.addSubview(btnCopy)
//        btnCopy.snp.makeConstraints { make in
//            make.right.equalToSuperview().offset(-15.w)
//            make.centerY.equalToSuperview()
//        }
//
//        view.addSubview(content)
//        content.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(15.w)
//            make.right.equalToSuperview().offset(-15.w)
//            make.top.equalTo(titleView.snp.bottom).offset(15.w)
//            make.bottom.equalToSuperview().offset(-15.w)
//        }
//
//        return view
//    }

    lazy var profilePictureView: ProfilePictureView = {
        let view: ProfilePictureView = ProfilePictureView()
        view.accessibilityLabel = "Profile picture"
        view.isAccessibilityElement = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.size = 124.w
        return view
    }()
    
    lazy var labName : UILabel = {
        let lab = UILabel(font: UIFont.Bold(size: 19),textColor: .textPrimary)
        lab.isUserInteractionEnabled = true
        lab.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editName)))
        return lab
    }()
    
    lazy var idView : EMUserInfoAddressItem = {
        let idView = EMUserInfoAddressItem(title: "your_id".localized(), dotColor: .path_connected)
        return idView
    }()
    
    lazy var addressView : EMUserInfoAddressItem = {
        let addressView = EMUserInfoAddressItem(title: "ADDRESS", dotColor: .path_connecting)
        return addressView
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
            labName.text = model?.name
            idView.labContent.text = model?.id
            addressView.labContent.text = WalletUtilities.address
        }
    }
}

extension EMSettingUserInfoCell{
    @objc func editName(){
        let inputView = InputModal(targetView: nil,info: InputModelInfo.init(title: "LocalEnterName".localized(), content: "")).confirmAction { value in
            self.updateName(value)
        }
        UIUtil.visibleVC()?.present(inputView, animated: true, completion: nil)
    }
    
    func updateName(_ name : String)  {
        let updatedNickname: String = name
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !updatedNickname.isEmpty else {
            UIUtil.visibleVC()?.present(ConfirmationModal(
                info: ConfirmationModal.Info(
                    title: "vc_settings_display_name_missing_error".localized(),
                    cancelTitle: "BUTTON_OK".localized(),
                    cancelStyle: .alert_text
                )
            ), animated: true)
            return
        }
        guard !ProfileManager.isToLong(profileName: updatedNickname) else {
            UIUtil.visibleVC()?.present(ConfirmationModal(
                info: ConfirmationModal.Info(
                    title: "vc_settings_display_name_too_long_error".localized(),
                    cancelTitle: "BUTTON_OK".localized(),
                    cancelStyle: .alert_text
                )
            ), animated: true)
            return
        }
        self.labName.text = updatedNickname
        self.updateProfile(
            name: updatedNickname,
            profilePicture: nil,
            profilePictureFilePath: ProfileManager.profileAvatarFilepath(id: self.model?.id ?? ""),
            isUpdatingDisplayName: true,
            isUpdatingProfilePicture: false
        )
    }
    
    private func updateProfile(
        name: String,
        profilePicture: UIImage?,
        profilePictureFilePath: String?,
        isUpdatingDisplayName: Bool,
        isUpdatingProfilePicture: Bool,
        onComplete: (() -> ())? = nil
    ) {
        ProfileManager.updateLocal(
            queue: DispatchQueue.global(qos: .default),
            profileName: name,
            image: profilePicture,
            imageFilePath: profilePictureFilePath,
            success: { db, updatedProfile in
                if isUpdatingDisplayName {
                    UserDefaults.standard[.lastDisplayNameUpdate] = Date()
                }

                if isUpdatingProfilePicture {
                    UserDefaults.standard[.lastProfilePictureUpdate] = Date()
                }

                try MessageSender.syncConfiguration(db, forceSyncNow: true).retainUntilComplete()

                // Wait for the database transaction to complete before updating the UI
                db.afterNextTransaction { _ in
                    
                }
            },
            failure: { error in
                DispatchQueue.main.async {
                    let isMaxFileSizeExceeded: Bool = (error == .avatarUploadMaxFileSizeExceeded)
                    
                    UIUtil.visibleVC()?.present(ConfirmationModal(
                        info: ConfirmationModal.Info(
                            title: (isMaxFileSizeExceeded ?
                                "Maximum File Size Exceeded" :
                                "Couldn't Update Profile"
                            ),
                            body: .text(isMaxFileSizeExceeded ?
                                "Please select a smaller photo and try again" :
                                "Please check your internet connection and try again"
                            ),
                            cancelTitle: "BUTTON_OK".localized(),
                            cancelStyle: .alert_text,
                            dismissType: .single
                        )
                    ), animated: true, completion: nil)
                }
            }
        )
    }
}

