// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import TZImagePickerController

class EMUserEditPage: BaseVC {
    var emUserInfo : EMCommunityUserEntity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showNavRight("context_menu_save".localized())
    }
    

    override func layoutUI() {
        self.title = LocalEdit.localized()
        
        let contentView = UIView(.wallet_bg)
        contentView.dealCorner(type: .topLeftRight, corner: 20.w)
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(44.w)
            make.size.equalTo(CGSize(width: 76.w, height: 76.w))
        }
        
        let maskView = UIImageView(UIColor.init(white: 1, alpha: 0.4))
        icon.addSubview(maskView)
        maskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let imageV = UIImageView(image: UIImage(named: "icon_user_edit"))
        icon.addSubview(imageV)
        imageV.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        contentView.addSubview(textName)
        textName.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(icon.snp.bottom).offset(40.w)
            make.size.equalTo(CGSize(width: 277.w, height: 46.w))
        }
        
    }

    lazy var icon : UIImageView = {
        let icon = UIImageView()
        icon.sd_setImage(with: URL(string: FS(emUserInfo?.Avatar)), placeholderImage: UIImage(named: "icon_community_logo"))
        icon.dealLayer(corner: 38.w)
        icon.isUserInteractionEnabled = true
        icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickPhoto)))
        return icon
    }()
    
    
    lazy var textName : UITextField = {
        let text = UITextField.init(LocalTokenContractPlaceholder.localized(),font:UIFont.Medium(size: 12),textColor:.textPrimary,text: FS(emUserInfo?.Nickname))
        text.themeBackgroundColor = .forget_textView_bg
        text.dealLayer(corner: 4.w)
        text.addLeftView(14.w)
        text.delegate = self
        return text
    }()
    
    var uploadImages : [PHAsset] = []
}


extension EMUserEditPage : TZImagePickerControllerDelegate{
    @objc func onclickPhoto(){
        let vc = TZImagePickerController.init(maxImagesCount: 1, delegate: self)!
        vc.modalPresentationStyle = .fullScreen
        vc.allowPickingVideo = false
        self.present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        self.icon.image = photos.first
        self.uploadImages = (assets as? [PHAsset]) ?? []
    }
}

extension EMUserEditPage: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func onRightAction() {
        guard let userInfo = emUserInfo else{
            return
        }
        AnimationManager.shared.setAnimation(self.view)
        Task{
            if await EMUserController.editUserInfo(name: FS(textName.text), icon: uploadImages, userInfo: userInfo){
                self.popPage()
                NotificationCenter.default.post(name: kNotifyRefreshCommunity, object: nil)
            }
            AnimationManager.shared.removeAnimaition(self.view)
        }
    }
}
