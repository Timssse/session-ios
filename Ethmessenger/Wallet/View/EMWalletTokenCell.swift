// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMWalletTokenCell: BaseTableViewCell {
    let icon = UIImageView()
    let labName = UILabel(font: UIFont.Bold(size: 15),textColor: .textPrimary)
    let labPrice = UILabel(font: UIFont.Regular(size: 12),textColor: .color_616569)
    let labNum = UILabel(font: UIFont.Bold(size: 12),textColor: .textPrimary)
    let labTotalPrice = UILabel(font: UIFont.Regular(size: 12),textColor: .color_616569)
    
    override func layoutUI() {
        icon.dealLayer(corner: 18.w)
        
        self.contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalToSuperview().offset(14.w)
            make.bottom.equalToSuperview().offset(-14.w)
            make.size.equalTo(CGSize(width: 36.w, height: 36.w))
        }
        
        self.contentView.addSubview(labName)
        labName.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(11.w)
            make.top.equalTo(icon).offset(-2.w)
        }
        
        self.contentView.addSubview(labPrice)
        labPrice.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(11.w)
            make.bottom.equalTo(icon)
        }
        
        self.contentView.addSubview(labNum)
        labNum.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-25.w)
            make.centerY.equalTo(labName)
        }
        
        self.contentView.addSubview(labTotalPrice)
        labTotalPrice.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-25.w)
            make.centerY.equalTo(labPrice)
        }
    }

    var model : EMTokenModel?{
        didSet{
            icon.sd_setImage(with: URL(string: FS(model?.icon)), placeholderImage: icon_default)
            labName.text = model?.symbol
            labPrice.text = EMWalletCache.shared.priceUnit.mark + FS(model?.price)
            if EMWalletCache.shared.isMoneyVisiable {
                labNum.text  = FS(model?.balance).toNumber8PointFormatter()
                let RMBStr = "≈" + EMWalletCache.shared.priceUnit.mark + FS(model?.rmbStr)
                labTotalPrice.text  = RMBStr
            }else{
                labNum.text  = "****"
                labTotalPrice.text = "****"
            }
        }
    }
    
}
