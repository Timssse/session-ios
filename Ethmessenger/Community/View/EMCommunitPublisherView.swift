// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMCommunitPublisherView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.size.equalTo(CGSize(width: 52.w, height: 52.w))
        }
        
        self.addSubview(labName)
        labName.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(18.w)
            make.top.equalToSuperview()
        }
        
        self.addSubview(labTime)
        labTime.snp.makeConstraints { make in
            make.left.equalTo(labName)
            make.top.equalTo(labName.snp.bottom)
        }
        
        let more = UIButton(type: .system,image: UIImage(named: "icon_community_more"),tintColor: .setting_icon_icon)
        more.addTarget(self, action: #selector(onclickMore), for: .touchUpInside)
        self.addSubview(more)
        more.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var icon : UIImageView = {
        let icon = UIImageView()
        icon.dealLayer(corner: 26.w)
        return icon
    }()
    
    lazy var labName : UILabel = {
        let lab = UILabel(font: UIFont.Bold(size: 15),textColor: .textPrimary)
        return lab
    }()
    
    lazy var labTime : UILabel = {
        let lab = UILabel(font: UIFont.Medium(size: 12),textColor: .textGary1)
        return lab
    }()
    
    
    var model : EMHomeListEntity!{
        didSet{
            icon.sd_setImage(with: URL(string: model.UserInfo?.Avatar ?? ""),placeholderImage: UIImage(named: "icon_community_default"))
            labName.text = model.UserInfo?.Nickname
            labTime.text = model.showTime
        }
    }
    
    @objc func onclickMore(){
        
    }
}
