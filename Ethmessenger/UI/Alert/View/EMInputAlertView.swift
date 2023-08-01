// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMInputAlertView: UIView {
    var titleText = ""
    var contentText = ""
    var confirmText = ""
    var cancelText = ""
    
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
//        icon.image = UIImage(named: imageName)
        title.text = titleText
        content.text = contentText
        confirmButton.setTitle(confirmText, for: .normal)
    }
    
    func setup() {
        addSubview(title)
        addSubview(content)
        addSubview(confirmButton)
        title.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(25.w)
            make.trailing.equalToSuperview().offset(-25.w)
            make.top.equalToSuperview().offset(25.w)
        }
        
        content.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(25.w)
            make.trailing.equalToSuperview().offset(-25.w)
            make.top.equalTo(title.snp.bottom).offset(16.w)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(title)
            make.top.equalTo(content.snp.bottom).offset(30.w)
            make.height.equalTo(41.w)
        }
        
//        cancelButton.snp.makeConstraints { make in
//            make.leading.trailing.equalTo(title)
//            make.top.equalTo(confirmButton.snp.bottom).offset(16.w)
//            make.bottom.equalToSuperview().offset(-20.w)
//        }
    }
    
    lazy var title = {
        let label = UILabel(font: UIFont.Bold(size: 19), textColor: .textPrimary)
        label.isHidden = true
        label.numberOfLines = 0
        return label
    }()
    
    lazy var content = {
        let label = UILabel(font: UIFont.Regular(size: 14), textColor: .alertTextColor)
        label.isHidden = true
        label.numberOfLines = 0
        return label
    }()
    
//    lazy var textInput : UITextField = {
//        let text = UITextView(LocalPassword.localized(),textColor: .textPrimary)
//        return text
//    }()
    
    lazy var confirmButton = {
        let btn = UIButton(font: UIFont.Bold(size: 15), color: .white, backgroundColor:.messageBubble_outgoingBackground)
        btn.isHidden  = true
        btn.dealLayer(corner: 10.w)
        return btn
    }()
}
