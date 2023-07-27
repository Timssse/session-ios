// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionUIKit
class EMThemeModeView: UIView {
    let backView = UIView(.tab_select_bg)
    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func createUI(){
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickDismiss)))
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.4)
        backView.dealCorner(type: .topLeftRight, corner: 20.w)
        self.addSubview(backView)
        backView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
        let labTitle = UILabel.init(font: UIFont.Bold(size: 18),textColor: .textPrimary,text: LocalThemeMode.localized())
        backView.addSubview(labTitle)
        labTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(21.w)
        }
        
        let line = UIView(.line)
        backView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.right.equalToSuperview().offset(-25.w)
            make.top.equalTo(labTitle.snp.bottom).offset(21.w)
            make.height.equalTo(1)
        }
        
        let btnBright = UIButton(title: LocalDayMode.localized(),font: UIFont.Medium(size: 18),color: ThemeManager.currentTheme == .classicLight ? .messageBubble_outgoingBackground : .textGary)
        btnBright.addTarget(self, action: #selector(onclickBright), for: .touchUpInside)
        backView.addSubview(btnBright)
        btnBright.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(line).offset(13.w)
            make.height.equalTo(43.w)
        }
        
        let btnDark = UIButton(title: LocalDarkMode.localized(),font: UIFont.Medium(size: 18),color: ThemeManager.currentTheme == .classicDark ? .messageBubble_outgoingBackground : .textGary)
        btnDark.addTarget(self, action: #selector(onclickDark), for: .touchUpInside)
        backView.addSubview(btnDark)
        btnDark.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(btnBright.snp.bottom).offset(13.w)
            make.height.equalTo(43.w)
            make.bottom.equalToSuperview().offset(-safeBottomH-20.w)
        }
        
//        let btnSys = UIButton(title: LocalSystemMode.localized(),font: UIFont.Medium(size: 18),color: ThemeManager.currentTheme == .classicSystem ? .messageBubble_outgoingBackground : .textGary)
//        btnSys.addTarget(self, action: #selector(onclickSystem), for: .touchUpInside)
//        backView.addSubview(btnSys)
//        btnSys.snp.makeConstraints { make in
//            make.left.right.equalToSuperview()
//            make.right.equalToSuperview()
//            make.top.equalTo(btnDark.snp.bottom).offset(13.w)
//            make.height.equalTo(33.w)
//            make.bottom.equalToSuperview().offset(-safeBottomH)
//        }
    }
    
    @discardableResult
    class func show() -> EMThemeModeView {
        let view = EMThemeModeView()
        topWindow()?.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        animationAddView(view: view.backView)
        return view
    }
}

extension EMThemeModeView{
    @objc func onclickDismiss(){
        animationRemoveview()
    }
    
    @objc func onclickBright(){
        onclickDismiss()
        if ThemeManager.currentTheme == .classicLight{
            return
        }
        ThemeManager.currentTheme = .classicLight
        topWindow()?.rootViewController = EMTabBarController()
    }
    
    @objc func onclickDark(){
        onclickDismiss()
        if ThemeManager.currentTheme == .classicDark{
            return
        }
        ThemeManager.currentTheme = .classicDark
        topWindow()?.rootViewController = EMTabBarController()
    }
    
//    @objc func onclickSystem(){
//        onclickDismiss()
//        if ThemeManager.currentTheme == .classicSystem{
//            return
//        }
//
//        let sysStyle = UITraitCollection.current.userInterfaceStyle
//        ThemeManager.currentTheme = .classicSystem
//        topWindow()?.rootViewController = EMTabBarController()
//    }
}
