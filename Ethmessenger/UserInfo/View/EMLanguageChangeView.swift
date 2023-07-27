// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionUtilitiesKit
class EMLanguageChangeView: UIView {
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
        let labTitle = UILabel.init(font: UIFont.Bold(size: 18),textColor: .textPrimary,text: LocalLanguage.localized())
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
        
        let btnChinese = UIButton(title: EMLocalizationTool.getLanguageName(.Chinese),font: UIFont.Medium(size: 18),color: EMLocalizationTool.shared.currentLanguage == Language.Chinese ? .messageBubble_outgoingBackground : .textGary)
        btnChinese.addTarget(self, action: #selector(onclickChinese), for: .touchUpInside)
        backView.addSubview(btnChinese)
        btnChinese.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(line).offset(13.w)
            make.height.equalTo(43.w)
        }
        
        let btnEnglish = UIButton(title: EMLocalizationTool.getLanguageName(Language.English),font: UIFont.Medium(size: 18),color: EMLocalizationTool.shared.currentLanguage == Language.English ? .messageBubble_outgoingBackground : .textGary)
        btnEnglish.addTarget(self, action: #selector(onclickEnglish), for: .touchUpInside)
        backView.addSubview(btnEnglish)
        btnEnglish.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(btnChinese.snp.bottom).offset(13.w)
            make.bottom.equalToSuperview().offset(-safeBottomH-20.w)
            make.height.equalTo(43.w)
        }
        
    }
    
    @discardableResult
    class func show() -> EMLanguageChangeView {
        let view = EMLanguageChangeView()
        topWindow()?.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        animationAddView(view: view.backView)
        return view
    }
}

extension EMLanguageChangeView{
    @objc func onclickDismiss(){
        animationRemoveview()
    }
    
    @objc func onclickChinese(){
        onclickDismiss()
        if EMLocalizationTool.shared.currentLanguage == .Chinese{
            return
        }
        EMLocalizationTool.shared.setLanguage(language: .Chinese)
        topWindow()?.rootViewController = EMTabBarController()
    }
    
    @objc func onclickEnglish(){
        onclickDismiss()
        if EMLocalizationTool.shared.currentLanguage == .English{
            return
        }
        EMLocalizationTool.shared.setLanguage(language: .English)
        topWindow()?.rootViewController = EMTabBarController()
    }
    
}

