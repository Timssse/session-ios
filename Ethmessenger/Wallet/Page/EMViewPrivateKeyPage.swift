// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMViewPrivateKeyPage: BaseVC {
    var walletName : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = LocalViewMnemonics.localized()
        createUI()
    }
    
    func createUI(){
        let contentView = UIView(.wallet_bg)
        contentView.dealCorner(type: .topLeftRight, corner: 20.w)
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let labTitle = UILabel.init(font: UIFont.Bold(size: 16),textColor: .textPrimary,text: "Key")
        contentView.addSubview(labTitle)
        labTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalToSuperview().offset(34.w)
        }
        
        let labTips = UILabel.init(font: UIFont.Regular(size: 12),textColor: .color_91979D,text: LocalViewMnemonicTips.localized())
        labTips.numberOfLines = 0
        contentView.addSubview(labTips)
        labTips.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30.w)
            make.right.equalToSuperview().offset(-30.w)
            make.top.equalTo(labTitle.snp.bottom).offset(10.w)
        }
        
        let privateKeyView = UIView(.forget_textView_bg)
        privateKeyView.dealLayer(corner: 8.w)
        contentView.addSubview(privateKeyView)
        privateKeyView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview().offset(-30.w)
            make.top.equalTo(labTips.snp.bottom).offset(32.w)
            make.height.equalTo(196.w)
        }
        
        let labPrivateKey = UILabel(font: UIFont.Bold(size: 14),textColor: .textPrimary,text: WalletUtilities.account.privateKey)
        labPrivateKey.numberOfLines = 0
        privateKeyView.addSubview(labPrivateKey)
        labPrivateKey.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(13.w)
            make.right.equalToSuperview().offset(-13.w)
        }
        
        let btnCopy = UIButton.init(title: LocalCopy.localized(),color: .white,backgroundColor: .messageBubble_outgoingBackground)
        btnCopy.dealLayer(corner: 8.w)
        btnCopy.addTarget(self, action: #selector(onclickCopy), for: .touchUpInside)
        contentView.addSubview(btnCopy)
        btnCopy.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.right.equalToSuperview().offset(-25.w)
            make.bottom.equalToSuperview().offset(-safeBottomH)
            make.height.equalTo(41.w)
        }
    }
    
    @objc func onclickCopy(){
        UIPasteboard.general.string = WalletUtilities.account.privateKey
        Toast.toast(hit: "copied".localized())
    }
    
}



