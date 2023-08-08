// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMOtherUserNav: UIView {
    let backBtn = UIButton(type: .system,image: UIImage(named: "icon_user_back"),tintColor: .white)
    var labTitle : UILabel = UILabel(font: UIFont.Bold(size: 16),textColor: .white)
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutUI() {
        let nav = UIView()
        self.addSubview(nav)
        nav.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(statusBarH)
        }
        backBtn.addTarget(self, action: #selector(popPage), for: .touchUpInside)
        nav.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(80.w)
        }
        
        labTitle.isHidden = true
        nav.addSubview(labTitle)
        labTitle.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    var profile : Profile?
}

extension EMOtherUserNav{
    @objc func popPage(){
        UIUtil.visibleNav()?.popViewController(animated: true)
    }
}
