// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMWalletManageCell: BaseTableViewCell {

    let labTitle = UILabel(font: UIFont.Bold(size: 15),textColor: .color_616569)
    let labContent = UILabel(font: UIFont.Medium(size: 15),textColor: .textPrimary)
    let imageType = UIImageView()

    override func layoutUI() {
        self.contentView.addSubview(labTitle)
        labTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14.w)
            make.bottom.equalToSuperview().offset(-14.w)
            make.left.equalToSuperview().offset(25.w)
        }
        
        imageType.themeTintColor = .textPrimary
        self.contentView.addSubview(imageType)
        imageType.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-25.w)
        }
        
        self.contentView.addSubview(labContent)
        labContent.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(imageType.snp.left).offset(-11.w)
        }
    }
    
    var model : EMWalletManageItemModel?{
        didSet{
            labTitle.text = model?.title
            labContent.text = model?.content.showAddress(6)
            imageType.image = model?.clickType == .copy ? UIImage(named: "icon_user_copy")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "icon_user_triangle")?.withRenderingMode(.alwaysTemplate)
        }
    }
    
}
