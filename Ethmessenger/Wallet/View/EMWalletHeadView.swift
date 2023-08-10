// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMWalletHeadView: UIView {

    var hiddenMoneyBlock : (()->())?
    let labUsdTitle = UILabel(font: UIFont.Medium(size: 11),color: UIColor(white: 1, alpha: 0.7),text: "（USD）")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutUI()
        Task{
            await update()
        }
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickManage)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layoutUI() {
        self.themeBackgroundColor = .messageBubble_outgoingBackground
        
        let labAssetTitle = UILabel(font: UIFont.Regular(size: 14),color: UIColor(white: 1, alpha: 0.7),text: LocalAsset.localized())
        self.addSubview(labAssetTitle)
        labAssetTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalToSuperview()
        }
        
        btnEye.addTarget(self, action: #selector(onclickEye), for: .touchUpInside)
        self.addSubview(btnEye)
        btnEye.snp.makeConstraints { make in
            make.left.equalTo(labAssetTitle.snp.right)
            make.centerY.equalTo(labAssetTitle)
            make.size.equalTo(CGSize(width: 50.w, height: 20.w))
        }
        
        self.addSubview(labUsd)
        labUsd.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalTo(labAssetTitle.snp.bottom).offset(6.w)
        }
        
        
        self.addSubview(labUsdTitle)
        labUsdTitle.snp.makeConstraints { make in
            make.left.equalTo(labUsd.snp.right).offset(8.w)
            make.centerY.equalTo(labUsd)
        }
        
        let arrowIcon = UIImageView(image: UIImage(named: "icon_user_arrow")?.withRenderingMode(.alwaysTemplate))
        arrowIcon.tintColor = UIColor.init(white: 1, alpha: 0.7)
        
        self.addSubview(arrowIcon)
        arrowIcon.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20.w)
            make.centerY.equalTo(labAssetTitle).offset(10.w)
        }
        
        let transferView = createNumItem(UIImage(named: "icon_wallet_transfer"), lab: LocalTrasfer.localized())
        transferView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickTransfer)))
        self.addSubview(transferView)
        transferView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(1/3.0)
            make.top.equalTo(labUsd.snp.bottom).offset(24.w)
            make.bottom.equalToSuperview().offset(-45.w)
        }
        
        let receiveView = createNumItem(UIImage(named: "icon_wallet_receive"), lab: LocalReceive.localized())
        receiveView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickReceive)))
        self.addSubview(receiveView)
        receiveView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(1/3.0)
            make.centerY.equalTo(transferView)
        }
        
        let scanView = createNumItem(UIImage(named: "icon_wallet_scan"), lab: LocalScan.localized())
        scanView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickScan)))
        self.addSubview(scanView)
        scanView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(1/3.0)
            make.centerY.equalTo(transferView)
        }
    }
    
    func createNumItem(_ icon : UIImage?,lab : String) -> UIView{
        let view = UIView()
        let iconView = UIImageView(image: icon)
        view.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        let labContent = UILabel(font: UIFont.Medium(size: 12),textColor: .Color_white_616569,text: lab)
        view.addSubview(labContent)
        labContent.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconView.snp.bottom).offset(3.w)
            make.bottom.equalToSuperview()
        }
        return view
    }
    
    
    lazy var btnEye : UIButton = UIButton(image: UIImage(named: "icon_user_eye_close"),selectImage: UIImage(named: "icon_user_eye_open"))
    
    lazy var labUsd : UILabel = UILabel(font: UIFont.Bold(size: 20),color: UIColor.white,text: "0.00")
    
    
    var moneny = "0.00" {
        didSet{
            labUsd.text = moneny
            labUsdTitle.text = "(\(EMWalletCache.shared.priceUnit.symbol))"
        }
    }
    
    func updateMoney() {
        btnEye.isSelected = EMWalletCache.shared.isMoneyVisiable
        if !EMWalletCache.shared.isMoneyVisiable {
            labUsd.text  = "****"
        }else{
            labUsd.text  = moneny
        }
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
}

extension EMWalletHeadView{
    @objc func onclickManage(){
        UIUtil.visibleNav()?.pushViewController(EMWalletManagePage(), animated: true)
    }
    
    @objc func onclickTransfer(){
        self.pushTransferPage()
    }
    
    
    func pushTransferPage(_ address : String = ""){
        guard let network = EMNetworkModel.getNetwork() else{
            return
        }
        guard let token = EMTableToken.selectMainTokenWithChainId(network.chain_id) else{
            return
        }
        UIUtil.visibleNav()?.pushViewController(EMTransferPage(token: token,receiveAddress: address), animated: true)
    }
    
    @objc func onclickReceive(){
        EMAlert.alert(.receive)?.popup()
    }
    
    @objc func onclickScan(){
        let vc = EMScanViewController()
        vc.okayBlock = { [weak self] (_, code) in//扫描地址
            let address = code.split(separator: ":").last
            self?.pushTransferPage(FS(address))
        }
        vc.modalPresentationStyle = .overFullScreen
        UIUtil.visibleVC()?.present(vc, animated: true, completion: nil)
    }
    
    
    
    func update()async{
        labUsd.text = String(format: "%.2f", moneny.toDouble())
    }
    
    @objc func refresshWalletMoney(){
        Task{
            await update()
        }
    }
    
    @objc func onclickEye(){
        EMWalletCache.shared.isMoneyVisiable = !EMWalletCache.shared.isMoneyVisiable
        updateMoney()
        self.hiddenMoneyBlock?()
    }
    
    
}


