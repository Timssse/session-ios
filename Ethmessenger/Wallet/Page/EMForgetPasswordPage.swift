// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMForgetPasswordPage: BaseVC {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func layoutUI() {
        self.title = LocalForgotPassword.localized()
        
        let contentView = UIView(.wallet_bg)
        contentView.dealCorner(type: .topLeftRight, corner: 20.w)
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let labTitle = UILabel(font: UIFont.Medium(size: 16),textColor: .textPrimary,text: LocalMnemonicAndPrivateKey.localized())
        contentView.addSubview(labTitle)
        labTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalToSuperview().offset(34.w)
        }
        
        let labTips = UILabel(font: UIFont.Medium(size: 16),textColor: .textPrimary,text: LocalForgetTips.localized())
        labTips.numberOfLines = 0
        contentView.addSubview(labTips)
        labTips.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.right.equalToSuperview().offset(-25.w)
            make.top.equalTo(labTitle.snp.bottom).offset(10.w)
        }
        
        contentView.addSubview(self.textView)
        self.textView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.right.equalToSuperview().offset(-25.w)
            make.height.equalTo(196.w)
            make.top.equalTo(labTips.snp.bottom).offset(35.w)
        }
        
        let btnSubmit = UIButton.init(title: LocalConfirm.localized(),color: .white,backgroundColor: .messageBubble_outgoingBackground)
        btnSubmit.dealLayer(corner: 8.w)
        btnSubmit.addTarget(self, action: #selector(onclickSubmit), for: .touchUpInside)
        contentView.addSubview(btnSubmit)
        btnSubmit.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.right.equalToSuperview().offset(-25.w)
            make.bottom.equalToSuperview().offset(-safeBottomH)
            make.height.equalTo(41.w)
        }
    }
    
    lazy var textView : UITextView = {
        let text = UITextView.init(.forget_textView_bg)
        text.delegate = self
        text.themeTextColor = .textPlaceholder
        text.text = LocalMnemonicAndPrivateKey.localized()
        text.dealLayer(corner: 8.w)
        text.textContainer.lineFragmentPadding = 0.0
        text.textContainerInset = UIEdgeInsets.init(top: 18.w, left: 16.w, bottom: 34.w, right: 16.w)
        text.font = UIFont.Medium(size: 14)
        return text
    }()
    
}



extension EMForgetPasswordPage : UITextViewDelegate{
        
    @objc func onclickSubmit(){
        guard let inputMnemonic = self.textView.text?.replacingOccurrences(of: " ", with: "") else{
            return
        }
//        "lesson busy swift remember image hammer proud limb attract brick winner genuine"
//       lesson busy swift remember image hammer proud limb attract brick winner genius
        if self.textView.text?.split(separator: " ").count == 12{
            if (WalletUtilities.account.mnemonic.replacingOccurrences(of: " ", with: "").lowercased() != inputMnemonic.lowercased()){
                Toast.toast(hit: LocalMenmonicValidationFail.localized())
                return
            }
            UIUtil.visibleNav()?.popViewController(animated: false)
            UIUtil.visibleNav()?.pushViewController(EMWalletSetPasswordPage(), animated: true)
            return
        }
        if (WalletUtilities.account.privateKey.lowercased() != inputMnemonic.lowercased()){
            Toast.toast(hit: LocalPrivateKeyErrorPrompt.localized())
            return
        }
        UIUtil.visibleNav()?.popViewController(animated: false)
        UIUtil.visibleNav()?.pushViewController(EMWalletSetPasswordPage(), animated: true)
    }
    
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == LocalMnemonicAndPrivateKey.localized() {
            textView.text = ""
            textView.themeTextColor = .textPrimary
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text.replacingOccurrences(of: " ", with: "") == "" {
            textView.text = LocalMnemonicAndPrivateKey.localized()
            textView.themeTextColor = .textPlaceholder
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.textView.resignFirstResponder()
    }
}
