// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMTokenHeadView: UIView {
    let icon = UIImageView()
    let labName = UILabel(font: UIFont.Bold(size: 16),textColor: .textPrimary)
    let labPrice = UILabel(font: UIFont.Bold(size: 15),textColor: .color_616569)
    let labAddress = UILabel(font: UIFont.Regular(size: 12),textColor: .color_91979D)
    let labBalance = UILabel(font: UIFont.Bold(size: 16),textColor: .textPrimary)
    let labFiatMoney = UILabel(font: UIFont.Regular(size: 14),textColor: .color_616569)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layoutUI() {
        self.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(34.w)
            make.size.equalTo(CGSize(width: 60.w, height: 60.w))
        }
        
        self.addSubview(labName)
        labName.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(icon.snp.bottom).offset(12.w)
        }
        
        self.addSubview(labPrice)
        labPrice.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(labName.snp.bottom).offset(3.w)
        }
        
        let addressView = UIView(.forget_textView_bg)
        addressView.dealLayer(corner: 18.w)
        self.addSubview(addressView)
        addressView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(labPrice.snp.bottom).offset(10.w)
            make.height.equalTo(36.w)
        }
        
        addressView.addSubview(labAddress)
        labAddress.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20.w)
        }
        
        let copyIcon = UIImageView(image: UIImage(named: "icon_user_copy")?.withRenderingMode(.alwaysTemplate))
        copyIcon.themeTintColor = .alertTextColor
        addressView.addSubview(copyIcon)
        copyIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20.w)
            make.left.equalTo(labAddress.snp.right).offset(6.w)
        }
        
        
        self.addSubview(labFiatMoney)
        labFiatMoney.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-25.w)
            make.bottom.equalToSuperview().offset(-20.w)
        }
        
        self.addSubview(labBalance)
        labBalance.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-25.w)
            make.bottom.equalTo(labFiatMoney.snp.top).offset(-15.w)
        }
        
        let labBalanceTitle = UILabel(font: UIFont.Bold(size: 15),textColor: .color_616569,text: LocalAsset.localized())
        self.addSubview(labBalanceTitle)
        labBalanceTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.centerY.equalTo(labBalance)
        }
        
        let line = UIView(.line)
        self.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.right.equalToSuperview().offset(-25.w)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    var model : EMTokenModel!{
        didSet{
            icon.sd_setImage(with: URL(string: model.icon), placeholderImage: icon_default)
            labName.text = model.symbol
            labPrice.text = model.price
            labFiatMoney.text = model.rmbStr
            labBalance.text = model.balance
            labAddress.text = model.contract.showAddress()
            labAddress.superview?.isHidden = model.contract == ""
        }
    }
    
    
}
