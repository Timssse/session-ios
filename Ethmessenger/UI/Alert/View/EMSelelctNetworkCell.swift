// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMSelelctNetworkCell: BaseTableViewCell {

    let iconLogo = UIImageView()
    let labSymbol = UILabel(font: UIFont.Regular(size: 15),textColor: .textPrimary)
    let labName = UILabel(font: UIFont.Regular(size: 12),textColor: .color_91979D)
    let iconStatus = UIImageView()
    
    override func layoutUI() {
        iconLogo.dealLayer(corner: 18.w)
        self.contentView.addSubview(iconLogo)
        iconLogo.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalToSuperview().offset(15.w)
            make.bottom.equalToSuperview().offset(-15.w)
            make.size.equalTo(CGSize(width: 36.w, height: 36.w))
        }
        
        self.contentView.addSubview(labSymbol)
        labSymbol.snp.makeConstraints { make in
            make.left.equalTo(iconLogo.snp.right).offset(15.w)
            make.top.equalTo(iconLogo)
        }
        
        self.contentView.addSubview(labName)
        labName.snp.makeConstraints { make in
            make.left.equalTo(iconLogo.snp.right).offset(15.w)
            make.bottom.equalTo(iconLogo)
        }
        
        self.contentView.addSubview(iconStatus)
        iconStatus.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-25.w)
            make.centerY.equalToSuperview()
        }
    }
    
    var model : EMNetworkModel?{
        didSet{
            iconLogo.sd_setImage(with: URL(string: FS(model?.icon)), placeholderImage: icon_default)
            labSymbol.text = model?.chain_symbol
            labName.text = model?.chain_name
        }
    }
    
    var isSelect : Bool = false{
        didSet{
            iconStatus.image = isSelect ? UIImage(named: "icon_network_selected") : UIImage(named: "icon_network_normal")
        }
    }
    
}
