// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionUIKit

class EMInviteVC: BaseVC {
    
    let imageV = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.onclickShare()
    }
    
    func createUI() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickCancle)))
        imageV.image = EMLocalizationTool.shared.currentLanguage == .English ? UIImage(named: "icon_invite_en") : UIImage(named: "icon_invite_cn")
        self.view.addSubview(imageV)
        imageV.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
    
    
    @objc func onclickCancle() {
        UIView.animate(withDuration: 0.1) {
            self.view.backgroundColor = UIColor.init(white: 0, alpha: 0.0)
        };
        self.dismiss(animated: true, completion: nil)
    }
    
    func onclickShare() {
//        if let image = self.getScreenViewImage(view: self.imageV) {
//            EMShareManager.shareToPaltm(title: "", image: image, urlStr: "",presentVC: self)
//        }
//
////        self.imageV.superview?.layoutIfNeeded()
        
//        let image = EMLocalizationTool.shared.currentLanguage == .English ? UIImage(named: "icon_invite_en") : UIImage(named: "icon_invite_cn")
        EMShareManager.shareToPaltm(title: "", image: self.imageV.image, urlStr: "",presentVC: self)
    }
}
