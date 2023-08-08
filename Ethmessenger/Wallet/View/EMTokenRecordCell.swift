// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMTokenRecordCell: BaseTableViewCell {
    let icon = UIImageView()
    let labHash = UILabel(font: UIFont.Regular(size: 12),textColor: .textPrimary)
    let labTime = UILabel(font: UIFont.Regular(size: 12),textColor: .color_616569)
    let labNum = UILabel(font: UIFont.Bold(size: 14),textColor: .textPrimary)
    
    override func layoutUI() {
        icon.dealLayer(corner: 17.w)
        self.contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalToSuperview().offset(14.w)
            make.bottom.equalToSuperview().offset(-14.w)
            make.size.equalTo(CGSize(width: 34.w, height: 34.w))
        }
        
        labHash.isUserInteractionEnabled = true
        labHash.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(copyHash)))
        self.contentView.addSubview(labHash)
        labHash.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(11.w)
            make.top.equalTo(icon)
        }
        
        let copyIcon = UIImageView(image: UIImage(named: "icon_user_copy")?.withRenderingMode(.alwaysTemplate))
        copyIcon.isUserInteractionEnabled = true
        copyIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(copyHash)))
        copyIcon.themeTintColor = .color_91979D
        self.contentView.addSubview(copyIcon)
        copyIcon.snp.makeConstraints { make in
            make.left.equalTo(labHash.snp.right).offset(4.w)
            make.centerY.equalTo(labHash)
        }
        
        self.contentView.addSubview(labTime)
        labTime.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(11.w)
            make.bottom.equalTo(icon)
        }
        
        self.contentView.addSubview(labNum)
        labNum.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-25.w)
            make.centerY.equalTo(icon)
        }
    }
    
    var model : EMTradeListModel?{
        didSet{
            icon.image = model?.statusIcon
            labHash.text = model?.hash.showAddress(11)
            labTime.text = model?.timeStamp.toyyyyMMdd("yyyy-MM-dd : HH:mm:ss")
            labNum.text = model?.showValue
        }
    }
    
    @objc func copyHash(){
        UIPasteboard.general.string = self.model?.hash
        Toast.toast(hit: "copied".localized())
    }
}
