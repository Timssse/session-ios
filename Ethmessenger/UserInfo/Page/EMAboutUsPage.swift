// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionUIKit


class EMAboutUsPage: BaseVC {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func layoutUI() {
        self.title = LocalAboutUS.localized()
        
        let contentView = UIView(.wallet_bg)
        contentView.dealCorner(type: .topLeftRight, corner: 20.w)
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let icon = UIImageView(image: ThemeManager.currentTheme == .classicDark ? UIImage(named: "icon_aboutUs_logo_dark") : UIImage(named: "icon_aboutUs_logo_light"))
        contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(75.w)
        }
        
        let labVersionTitle = UILabel(font: UIFont.Bold(size: 15),textColor: .textPrimary,text: LocalVersion.localized())
        contentView.addSubview(labVersionTitle)
        labVersionTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalTo(icon.snp.bottom).offset(80.w)
        }
        
        let labVersion = UILabel(font: UIFont.Medium(size: 15),textColor: .color_91979D,text: AppInfo.shared.version)
        contentView.addSubview(labVersion)
        labVersion.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-25.w)
            make.centerY.equalTo(labVersionTitle)
        }
        
        let twitter = createAgreementItem("Twitter")
        contentView.addSubview(twitter)
        twitter.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-25.w)
            make.left.equalToSuperview().offset(25.w)
            make.top.equalTo(labVersionTitle.snp.bottom).offset(11.w)
            make.height.equalTo(55.w)
        }
        
        let Telegarm = createAgreementItem("Telegarm")
        contentView.addSubview(Telegarm)
        Telegarm.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-25.w)
            make.left.equalToSuperview().offset(25.w)
            make.top.equalTo(twitter.snp.bottom)
            make.height.equalTo(55.w)
        }
        
        let WebSite = createAgreementItem(LocalWebsite.localized())
        contentView.addSubview(WebSite)
        WebSite.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-25.w)
            make.left.equalToSuperview().offset(25.w)
            make.top.equalTo(Telegarm.snp.bottom)
            make.height.equalTo(55.w)
        }
    }
    
    func createAgreementItem(_ title : String) -> UIView {
        let view = UIView(UIColor.clear)
        let lab = UILabel.init(font: UIFont.Bold(size: 15),textColor: .textPrimary,text: title)
        view.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }
        let arrow = UIImageView(image: UIImage(named: "icon_user_arrow")?.withRenderingMode(.alwaysTemplate))
        arrow.themeTintColor = .color_91979D
        view.addSubview(arrow)
        arrow.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }
        return view
    }
}

extension EMAboutUsPage{
    @objc func onclickTwitter(){
        UIApplication.shared.open(URL(string: "https://ethmessenger.app/")!,completionHandler: nil)
    }
    
    @objc func onclickTelegarm(){
        UIApplication.shared.open(URL(string: "https://ethmessenger.app/")!,completionHandler: nil)
    }
    
    @objc func onclickWebsite(){
        UIApplication.shared.open(URL(string: "https://ethmessenger.app/")!,completionHandler: nil)
    }
}


