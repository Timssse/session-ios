// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMTransferTokenView: UIView {

    let icon = UIImageView()
    let labName = UILabel(font: UIFont.Bold(size: 15),textColor: .textPrimary)
    let labAddress = UILabel(font: UIFont.Regular(size: 12),textColor: .color_91979D)
    let copyIcon = UIImageView(image: UIImage(named: "icon_user_copy")?.withRenderingMode(.alwaysTemplate))
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutUI(){
        self.dealBorderLayer(corner: 14.w, bordercolor: .line, borderwidth: 1)
        
        
        icon.dealLayer(corner: 18.w)
        self.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(17.w)
            make.top.equalToSuperview().offset(17.w)
            make.bottom.equalToSuperview().offset(-17.w)
            make.size.equalTo(CGSize(width: 36.w, height: 36.w))
        }
        
        self.addSubview(labName)
        labName.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(11.w)
            make.top.equalTo(icon)
        }
        
        
        
        self.addSubview(labAddress)
        labAddress.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(11.w)
            make.bottom.equalTo(icon)
        }
        
        
        copyIcon.themeTintColor = .color_91979D
        self.addSubview(copyIcon)
        copyIcon.snp.makeConstraints { make in
            make.left.equalTo(labAddress.snp.right).offset(4.w)
            make.centerY.equalTo(labAddress)
        }
        
        let arrowIcon = UIImageView(image: UIImage(named: "icon_user_arrow"))
        self.addSubview(arrowIcon)
        arrowIcon.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-17.w)
            make.centerY.equalToSuperview()
        }
    }
    
    
    var token : EMTokenModel!{
        didSet{
            icon.sd_setImage(with: URL(string: FS(token.icon)), placeholderImage: icon_default)
            labName.text = token.symbol
            labAddress.text = token.contract.showAddress(6)
            if token.contract == ""{
                labAddress.isHidden = true
                copyIcon.isHidden = true
                labName.snp.updateConstraints { make in
                    make.top.equalTo(icon).offset(8.w)
                }
            }else{
                labAddress.isHidden = false
                copyIcon.isHidden = false
                labName.snp.updateConstraints { make in
                    make.top.equalTo(icon)
                }
            }
        }
    }
    
}
