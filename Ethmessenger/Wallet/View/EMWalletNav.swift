// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMWalletNav: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutUI()
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutUI() {
        self.themeBackgroundColor = .messageBubble_outgoingBackground
        let nav = UIView()
        self.addSubview(nav)
        nav.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(statusBarH)
        }
        
        let backBtn = UIButton(type: .system,image: UIImage(named: "icon_back"),tintColor: .white)
        backBtn.addTarget(self, action: #selector(popPage), for: .touchUpInside)
        nav.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(32.w)
        }
        
        nav.addSubview(chainView)
        chainView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20.w)
            make.centerY.equalToSuperview().offset(-5.w)
            make.height.equalTo(36.w)
        }
        
    }
    
    lazy var chainView : UIView = {
        let view = UIView(UIColor(white: 1, alpha: 0.1),corner: 18.w)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickChain)))
        view.addSubview(chainIcon)
        chainIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(9.w)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 24.w, height: 24.w))
        }
        view.addSubview(chainName)
        chainName.snp.makeConstraints { make in
            make.left.equalTo(chainIcon.snp.right).offset(7.w)
            make.centerY.equalToSuperview()
        }
        let iconTriangle = UIImageView(image: UIImage(named: "icon_chats_triangle")?.withRenderingMode(.alwaysTemplate))
        iconTriangle.tintColor = .white
        view.addSubview(iconTriangle)
        iconTriangle.snp.makeConstraints { make in
            make.left.equalTo(chainName.snp.right).offset(7.w)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-9.w)
        }
        return view
    }()
    
    lazy var chainIcon : UIImageView = UIImageView(UIColor.clear,corner: 12.w)
    
    lazy var chainName : UILabel = UILabel(font: UIFont.Medium(size: 14),textColor: .white)
    
    var chain : EMNetworkModel? {
        didSet{
            chainIcon.sd_setImage(with: URL(string: FS(chain?.icon)), placeholderImage: UIImage(named: "icon_community_default"))
            chainName.text = chain?.chain_symbol
        }
    }
}

extension EMWalletNav{
    @objc func chainChange(){
        self.chain = EMNetworkModel.getNetwork()
    }
    
    @objc func popPage(){
        UIUtil.visibleNav()?.popViewController(animated: true)
    }
    
    @objc func onclickChain(){
        EMAlert.alert(.selectNetwork)?.popup()
    }
}
