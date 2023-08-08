// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

enum EMTabBarType : String{
    case Chats
    case DAO
    case Settings
    
    static func createItem(_ type : EMTabBarType) -> EMTabBarItem{
        let item = EMTabBarItem(type: type)
        return item
    }
    
}


class EMTabBarItem: UIView {
    var clickAction:(()->())?
    var type : EMTabBarType = .Chats
    
    convenience init(type : EMTabBarType) {
        self.init()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickTap)))
        self.type = type
        self.createUI()
    }
    
    func createUI() {
        self.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 66.w, height: 46.w))
        }
        
        backgroundView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        backgroundView.addSubview(dot)
        dot.snp.makeConstraints { make in
            make.right.equalTo(icon)
            make.top.equalTo(icon).offset(2)
            make.size.equalTo(CGSize(width: 6.w, height: 6.w))
        }
        
//        backgroundView.addSubview(lab)
//        lab.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.centerY.equalToSuperview()
//        }
        
    }
    
    lazy var backgroundView : UIView = {
        let view = UIView()
        view.dealLayer(corner: 18.w)
        return view
    }()
    
    lazy var icon : UIImageView = {
        let icon = UIImageView()
        return icon
    }()
    
//    lazy var lab : UILabel = {
//        let lab = UILabel(font: UIFont.Medium(size: 10),textColor: .white,text: type.rawValue)
//        lab.isHidden = true
//        return lab
//    }()
    
    lazy var dot : UIView = {
        let dot = UIView(.conversationButton_unreadBubbleBackground)
        dot.isHidden = true
        dot.dealLayer(corner: 3.w)
        return dot
    }()
    
    var isSelect : Bool = false{
        didSet{
//            backgroundView.themeBackgroundColor =  isSelect ? .textPrimary : .tab_select_bg
            icon.themeTintColor = isSelect ? .textPrimary : .color_91979D
            switch type{
            case .Chats:
                icon.image = UIImage(named: "tabbar_chat_" + (isSelect ? "s" : "n"))?.withRenderingMode(.alwaysTemplate)
                return
            case .DAO:
                icon.image = UIImage(named: "tabbar_dao_" + (isSelect ? "s" : "n"))?.withRenderingMode(.alwaysTemplate)
                return
            case .Settings:
                icon.image = UIImage(named: "tabbar_settings_" + (isSelect ? "s" : "n"))?.withRenderingMode(.alwaysTemplate)
                return
            }
            
            
        }
    }
    
}

extension EMTabBarItem{
    @objc func onclickTap(){
        self.clickAction?()
    }
    
    @discardableResult
    func clickAction(_ action: @escaping () -> Void) -> EMTabBarItem {
        clickAction = action
        return self
    }
    
    func setSelectd(_ isSelect: Bool) -> EMTabBarItem {
        self.isSelect = isSelect
        return self
    }
    
}
