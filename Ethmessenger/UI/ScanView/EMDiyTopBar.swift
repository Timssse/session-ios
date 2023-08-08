//
//  FWDiyTopBar.swift
//  FairWallet
//
//  Created by FairWallet on 2022/4/22.
//  Copyright © 2022 FairWallet. All rights reserved.
//

import UIKit
import SnapKit

class EMDiyTopBar: UIView {
    
    let contentView = UIView()
    let backBtn: UIButton = {
        let rs = UIButton()
        rs.contentHorizontalAlignment = .left
        rs.setImage(UIImage(named: "NavBarBack"), for: .normal)
        return rs
    }()
    
    let titleLabel: UILabel = {
        let rs = UILabel()
        rs.textColor = UIColor.red
        rs.font = UIFont.boldSystemFont(ofSize: 16)
        return rs
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initVarsAndViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -
    final private func initVarsAndViews() {
        addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(49)
        }
        
        contentView.addSubview(backBtn)
        backBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(13)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(40)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.centerX.equalToSuperview()
        }
    }
    
    override var backgroundColor: UIColor? {
        set {
            super.backgroundColor = newValue
            contentView.backgroundColor = newValue
        }
        get {
            return super.backgroundColor
        }
    }
}


