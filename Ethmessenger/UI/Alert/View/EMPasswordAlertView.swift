// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMPasswordAlertView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        themeBackgroundColor = .communitInput
        layer.masksToBounds = true
        layer.cornerRadius = 22.w
    }
    
    func setup() {
        addSubview(title)
        addSubview(textPassword)
        addSubview(btnPassword)
        addSubview(confirmButton)
        title.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(25.w)
            make.trailing.equalToSuperview().offset(-25.w)
            make.top.equalToSuperview().offset(25.w)
        }
        
        textPassword.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalTo(title.snp.bottom).offset(20.w)
            make.right.equalToSuperview().offset(-25.w)
            make.height.equalTo(41.w)
        }
        
        btnPassword.snp.makeConstraints { make in
            make.right.top.bottom.equalTo(textPassword)
            make.width.equalTo(48.w)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(title)
            make.top.equalTo(textPassword.snp.bottom).offset(30.w)
            make.height.equalTo(41.w)
            make.bottom.equalToSuperview().offset(-20.w)
        }
        
    }
    
    lazy var title = {
        let label = UILabel(font: UIFont.Bold(size: 19), textColor: .textPrimary,text:LocalPassword.localized())
        label.numberOfLines = 0
        return label
    }()
    
    lazy var textPassword : UITextField = {
        let text = UITextField.init(LocalPassword.localized(),font:UIFont.Medium(size: 12),textColor:.textPlaceholder)
        text.dealBorderLayer(corner: 9.w, bordercolor: .password_border_color, borderwidth: 1)
        text.addLeftView(16.w)
        text.delegate = self
        text.isSecureTextEntry = true
        return text
    }()
    
    lazy var btnPassword : UIButton = {
        let btn = UIButton.init(type: .system,image: UIImage(named: "icon_user_eye_close"),selectImage: UIImage(named: "icon_user_eye_open"),tintColor: .textGary1)
        btn.addTarget(self, action: #selector(clickHiddenPassword(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var confirmButton = {
        let btn = UIButton(title:LocalConfirm.localized(),font: UIFont.Bold(size: 15), color: .white, backgroundColor:.messageBubble_outgoingBackground)
        btn.dealLayer(corner: 10.w)
        return btn
    }()
}

extension EMPasswordAlertView:UITextFieldDelegate{
    @objc func clickHiddenPassword(_ sender : UIButton){
        sender.isSelected = !sender.isSelected
        self.textPassword.isSecureTextEntry = !sender.isSelected
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
