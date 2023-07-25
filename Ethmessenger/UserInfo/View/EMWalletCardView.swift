// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMWalletCardView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutUI() {
        self.themeBackgroundColor = .messageBubble_outgoingBackground
        self.dealLayer(corner: 10.w)
        let walletIcon = UIImageView(image: UIImage(named: "icon_user_wallet"))
        self.addSubview(walletIcon)
        walletIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18.w)
            make.top.equalToSuperview().offset(16.w)
        }
        
        let labWallet = UILabel(font: UIFont.Medium(size: 12),color: UIColor(white: 1, alpha: 0.7),text: "Wallet")
        self.addSubview(labWallet)
        labWallet.snp.makeConstraints { make in
            make.left.equalTo(walletIcon.snp.right).offset(4.w)
            make.centerY.equalTo(walletIcon)
        }
        
        self.addSubview(btnEye)
        btnEye.snp.makeConstraints { make in
            make.left.equalTo(labWallet.snp.right)
            make.centerY.equalTo(walletIcon)
            make.size.equalTo(CGSize(width: 50.w, height: 20.w))
        }
        
        self.addSubview(labUsd)
        labUsd.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18.w)
            make.top.equalTo(walletIcon.snp.bottom).offset(6.w)
        }
        
        let labUsdTitle = UILabel(font: UIFont.Medium(size: 11),color: UIColor(white: 1, alpha: 0.7),text: "（USD）")
        self.addSubview(labUsdTitle)
        labUsdTitle.snp.makeConstraints { make in
            make.left.equalTo(labUsd.snp.right).offset(8.w)
            make.centerY.equalTo(labUsd)
        }
        
        let arrowIcon = UIImageView(image: UIImage(named: "icon_user_arrow"))
        self.addSubview(arrowIcon)
        arrowIcon.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20.w)
            make.centerY.equalTo(walletIcon).offset(10.w)
        }
    }
    
    lazy var btnEye : UIButton = UIButton(image: UIImage(named: "icon_user_eye_close"),selectImage: UIImage(named: "icon_user_eye_open"))
    
    lazy var labUsd : UILabel = UILabel(font: UIFont.Bold(size: 20),color: UIColor(white: 1, alpha: 0.7),text: "Wallet")
}
