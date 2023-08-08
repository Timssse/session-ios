// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMWalletCardView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutUI()
//        Task{
//            await update()
//        }
//        NotificationCenter.default.addObserver(self, selector: #selector(refresshWalletMoney), name: kNotifyRefreshWallet, object: nil)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickCard)))
        
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
        
        let arrowIcon = UIImageView(image: UIImage(named: "icon_user_arrow"))
        self.addSubview(arrowIcon)
        arrowIcon.snp.makeConstraints { make in
            make.left.equalTo(labWallet.snp.right).offset(10.w)
            make.centerY.equalTo(labWallet)
        }
        
//        btnEye.addTarget(self, action: #selector(onclickEye), for: .touchUpInside)
//        self.addSubview(btnEye)
//        btnEye.snp.makeConstraints { make in
//            make.left.equalTo(labWallet.snp.right)
//            make.centerY.equalTo(walletIcon)
//            make.size.equalTo(CGSize(width: 50.w, height: 20.w))
//        }
        
        labAddress.isUserInteractionEnabled = true
        labAddress.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickCopy)))
        self.addSubview(labAddress)
        labAddress.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18.w)
            make.top.equalTo(walletIcon.snp.bottom).offset(10.w)
        }
        
        let copyIcon = UIImageView(image: UIImage(named: "icon_user_copy")?.withRenderingMode(.alwaysTemplate))
        copyIcon.isUserInteractionEnabled = true
        copyIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickCopy)))
        copyIcon.themeTintColor = .white
        self.addSubview(copyIcon)
        copyIcon.snp.makeConstraints { make in
            make.centerY.equalTo(labAddress)
            make.left.equalTo(labAddress.snp.right).offset(6.w)
        }
        
        
//        let labUsdTitle = UILabel(font: UIFont.Medium(size: 11),color: UIColor(white: 1, alpha: 0.7),text: "（USD）")
//        self.addSubview(labUsdTitle)
//        labUsdTitle.snp.makeConstraints { make in
//            make.left.equalTo(labUsd.snp.right).offset(8.w)
//            make.centerY.equalTo(labUsd)
//        }
        
        
    }
    
//    lazy var btnEye : UIButton = UIButton(image: UIImage(named: "icon_user_eye_close"),selectImage: UIImage(named: "icon_user_eye_open"))
    
    lazy var labAddress : UILabel = UILabel(font: UIFont.Medium(size: 11),color: .white,text: WalletUtilities.address.showAddress(6))
    
//    var moneny = "0.00"
    
//    func updateMoney() {
//        btnEye.isSelected = EMWalletCache.shared.isMoneyVisiable
//        if !EMWalletCache.shared.isMoneyVisiable {
//            labUsd.text  = "****"
//        }else{
//            labUsd.text  = moneny
//        }
//    }
    
//    deinit{
//        NotificationCenter.default.removeObserver(self)
//    }
}

extension EMWalletCardView{
    @objc func onclickCopy(){
        UIPasteboard.general.string = WalletUtilities.address
        Toast.toast(hit: "copied".localized())
    }
    
    
    @objc func onclickCard(){
        UIUtil.visibleNav()?.pushViewController(EMWalletPage(), animated: true)
    }
}
