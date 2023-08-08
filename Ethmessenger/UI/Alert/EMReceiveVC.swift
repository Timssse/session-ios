// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMReceiveVC: EMAlertController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setup() {
        let contentView = UIView(.communitInput)
        contentView.dealCorner(type: .topLeftRight, corner: 20.w)
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(390.w + safeBottomH)
        }
        
        let labTitle = UILabel(font: UIFont.Bold(size: 17),textColor: .color_616569,text: LocalReceive.localized())
        contentView.addSubview(labTitle)
        labTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalTo(26.w)
        }
        
        let chain = EMNetworkModel.getNetwork()
        let labChain = UILabel(font: UIFont.Medium(size: 15),textColor: .textPrimary,text: chain?.chain_symbol)
        contentView.addSubview(labChain)
        labChain.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(labTitle.snp.bottom).offset(23.w)
        }
        
        let qrcodeView = UIView(UIColor.white)
        qrcodeView.dealBorderLayer(corner: 4.w, bordercolor: .black, borderwidth: 1)
        view.addSubview(qrcodeView)
        qrcodeView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(labChain.snp.bottom).offset(14.w)
            make.size.equalTo(CGSize(width: 116.w, height: 116.w))
        }
        
        let qrCodeImageView = UIImageView(
            image: QRCode.generate(for: WalletUtilities.address, hasBackground: false)
                .withRenderingMode(.alwaysTemplate)
        )
        qrCodeImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        qrCodeImageView.tintColor = .black
        qrcodeView.addSubview(qrCodeImageView)
        qrCodeImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 7.w, leading: 7.w, bottom: 7.w, trailing: 7.w))
        }
        
        let labScanTips = UILabel(font: UIFont.Medium(size: 15),textColor: .textPrimary,text: LocalScanReceiveTips.localized())
        contentView.addSubview(labScanTips)
        labScanTips.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(qrcodeView.snp.bottom).offset(7.w)
        }
        
        let addressView = UIView(.line)
        addressView.dealBorderLayer(corner: 8.w, bordercolor: .line, borderwidth: 1)
        contentView.addSubview(addressView)
        addressView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(labScanTips.snp.bottom).offset(21.w)
            make.size.equalTo(CGSize(width: 318.w, height: 41.w))
        }
        
        let labAddress = UILabel(font: UIFont.Medium(size: 14),textColor: .color_616569,text: WalletUtilities.address.showAddress())
        addressView.addSubview(labAddress)
        labAddress.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        
        let btnConfirm = UIButton(title:LocalCopy.localized(),font: UIFont.Bold(size: 15), color: .white, backgroundColor:.messageBubble_outgoingBackground)
        btnConfirm.addTarget(self, action: #selector(copyAddress), for: .touchUpInside)
        btnConfirm.dealLayer(corner: 10.w)
        contentView.addSubview(btnConfirm)
        btnConfirm.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-safeBottomH)
            make.size.equalTo(CGSize(width: 325.w, height: 41.w))
        }
    }
    
    @objc func copyAddress(){
        UIPasteboard.general.string = WalletUtilities.address
        Toast.toast(hit: "copied".localized())
    }
}
