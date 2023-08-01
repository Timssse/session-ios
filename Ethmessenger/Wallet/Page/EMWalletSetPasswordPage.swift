// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMWalletSetPasswordPage: BaseVC {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func layoutUI() {
        self.title = LocalPassword.localized()
        
        let contentView = UIView(.wallet_bg)
        contentView.dealCorner(type: .topLeftRight, corner: 20.w)
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let labPasswordTips = UILabel.init(font:UIFont.Medium(size: 12),textColor:.color_91979D,text:LocalPasswordTips.localized())
        labPasswordTips.numberOfLines = 0
        contentView.addSubview(labPasswordTips)
        labPasswordTips.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.right.equalToSuperview().offset(-25.w)
            make.top.equalToSuperview().offset(25.w)
        }
        
        
        let labPassword = UILabel.init(font:UIFont.Medium(size: 16),textColor:.textPrimary,text:LocalPassword.localized())
        contentView.addSubview(labPassword)
        labPassword.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalTo(labPasswordTips.snp.bottom).offset(10.w)
        }
        
        contentView.addSubview(textPassword)
        textPassword.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalTo(labPassword.snp.bottom).offset(15.w)
            make.right.equalToSuperview().offset(-25.w)
            make.height.equalTo(58.w)
        }
        
        contentView.addSubview(btnPassword)
        btnPassword.snp.makeConstraints { make in
            make.right.top.bottom.equalTo(textPassword)
            make.width.equalTo(58.w)
        }
        
        let labConfirmPassword = UILabel.init(font:UIFont.Medium(size: 16),textColor:.textPrimary,text:LocalConfirmPassword.localized())
        contentView.addSubview(labConfirmPassword)
        labConfirmPassword.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalTo(textPassword.snp.bottom).offset(14.w)
        }
        contentView.addSubview(textEnsurePassword)
        textEnsurePassword.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalTo(labConfirmPassword.snp.bottom).offset(15.w)
            make.right.equalToSuperview().offset(-25.w)
            make.height.equalTo(58.w)
        }
        
        contentView.addSubview(btnEnsurePassword)
        btnEnsurePassword.snp.makeConstraints { make in
            make.right.top.bottom.equalTo(textEnsurePassword)
            make.width.equalTo(58.w)
        }
        
        let labPasswordTips2 = UILabel.init(font:UIFont.Medium(size: 12),textColor:.color_91979D,text:LocalPasswordTips2.localized())
        labPasswordTips2.numberOfLines = 0
        contentView.addSubview(labPasswordTips2)
        labPasswordTips2.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.right.equalToSuperview().offset(-25.w)
            make.top.equalTo(textEnsurePassword.snp.bottom).offset(22.w)
        }
        
        
        contentView.addSubview(self.saveBtn)
        self.saveBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.right.equalToSuperview().offset(-25.w)
            make.bottom.equalToSuperview().offset(-safeBottomH-20.w)
            make.height.equalTo(41.w)
        }
    }
    
    
    lazy var textPassword : UITextField = {
        let text = UITextField.init(LocalPassword.localized(),font:UIFont.Medium(size: 12),textColor:.textPlaceholder)
        text.dealBorderLayer(corner: 14.w, bordercolor: .password_border_color, borderwidth: 1)
        text.addLeftView(16.w)
        text.delegate = self
        text.isSecureTextEntry = true
        return text
    }()
    
    lazy var btnPassword : UIButton = {
        let btn = UIButton.init(type: .system,image: UIImage(named: "icon_user_eye_open"),selectImage: UIImage(named: "icon_user_eye_close"),tintColor: .textGary1)
        btn.addTarget(self, action: #selector(clickHiddenPassword(_:)), for: .touchUpInside)
        return btn
    }()
    
    
    lazy var textEnsurePassword : UITextField = {
        let text = UITextField.init(LocalConfirmPassword.localized(),font:UIFont.Medium(size: 12),textColor:.textPlaceholder)
        text.dealBorderLayer(corner: 14.w, bordercolor: .password_border_color, borderwidth: 1)
        text.addLeftView(16.w)
        text.delegate = self
        text.isSecureTextEntry = true
        return text
    }()

    lazy var btnEnsurePassword : UIButton = {
        let btn = UIButton.init(type: .system,image: UIImage(named: "icon_user_eye_open"),selectImage: UIImage(named: "icon_user_eye_close"),tintColor: .textGary1)
        btn.addTarget(self, action: #selector(clickHiddenConfirmPassword(_:)), for: .touchUpInside)
        return btn
    }()
    
    
    lazy var saveBtn : UIButton = {
        let btn = UIButton.init(title:LocalConfirm.localized(),font: UIFont.Bold(size: 15),color: .white,backgroundColor: .messageBubble_outgoingBackground)
        btn.addTarget(self, action: #selector(clickCreatetBtn), for: UIControl.Event.touchUpInside)
        btn.dealLayer(corner: 8.w)
        return btn
    }()
    
}

extension EMWalletSetPasswordPage : UITextFieldDelegate{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension EMWalletSetPasswordPage{
    @objc func clickHiddenPassword(_ sender : UIButton){
        sender.isSelected = !sender.isSelected
        self.textPassword.isSecureTextEntry = !sender.isSelected
    }
    
    @objc func clickHiddenConfirmPassword(_ sender : UIButton){
        sender.isSelected = !sender.isSelected
        self.textEnsurePassword.isSecureTextEntry = !sender.isSelected
    }
    
    @objc func clickCreatetBtn() {
        if self.textPassword.text!.count < 6 {
            Toast.toast(hit: LocalPasswordLength.localized())
            return
        }
        if self.textPassword.text!.count > 20 {
            Toast.toast(hit: LocalPasswordLength.localized())
            return
        }
        
        if self.textPassword.text != self.textEnsurePassword.text {
            Toast.toast(hit: LocalPasswordDifferentPrompt.localized())
            
            return
        }
        WalletUtilities.account.password = FS(self.textPassword.text)
        Toast.toast(hit: LocalSaveSuccess.localized())
        self.popPage()
    }
    
}

