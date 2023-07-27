// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionUIKit

class EMTabBarController: UITabBarController {
    
    let customTabBar : EMTabBar = EMTabBar()
    let optionallyBtn: UIButton = UIButton(type: .custom)
    var currentItem : Int = 0
    var vcAry = [UIViewController]()
    var titleArray = [String]()
    var jsonArr : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task{
            await EMCommunityController.login()
            await EMCommunityController.config()
        }
        self.tabBar.isHidden = true
        WalletUtilities.createAccount()
        NotificationCenter.default.addObserver(self, selector: #selector(messageChange(_:)), name: kNotifyRefreshMessageCount, object: nil)
        setupUI()
    }
    
    func setupUI() {
        let shaowTabar = UIView();
        shaowTabar.layer.shadowColor = UIColor.init(white: 0, alpha: 0.15).cgColor
        shaowTabar.layer.shadowOffset = CGSize(width: 0, height: 0)
        shaowTabar.layer.shadowOpacity = 28
        shaowTabar.layer.shadowRadius = 22.w
        self.view.addSubview(shaowTabar)
        shaowTabar.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16.w)
            make.right.equalToSuperview().offset(-16.w)
            make.bottom.equalToSuperview().offset(-safeBottomH)
            make.height.equalTo(66.w)
        };
        
        self.customTabBar.frame = CGRect(x: 0, y: 0, width: 343.w, height: 66.w)
        customTabBar.themeBackgroundColor = .tab_select_bg
        customTabBar.dealLayer(corner: 22.w)
        shaowTabar.addSubview(customTabBar)
        
        
        let itemDAO = EMTabBarType.createItem(.DAO).setSelectd(false).clickAction {[weak self] in
            self?.selectedIndex = 1
        }
        let itemSetting = EMTabBarType.createItem(.Settings).setSelectd(false).clickAction {[weak self] in
            self?.selectedIndex = 2
        }
        self.customTabBar.emItems = [itemChats,itemDAO,itemSetting]
        let homevc = StyledNavigationController(rootViewController: HomeVC())
        homevc.delegate = self
        addChild(homevc)
        let vc = EMCommunityMainPage()
        let twitter = StyledNavigationController(rootViewController: vc)
        twitter.delegate = self
        addChild(twitter)
        let userVC = StyledNavigationController(rootViewController: EMUserPage())
        userVC.delegate = self
        addChild(userVC)
        
//        let settingVC = StyledNavigationController(rootViewController: EMSettingPage())
//        settingVC.delegate = self
//        addChild(settingVC)
    }
    
    lazy var itemChats : EMTabBarItem = {
        let itemChats = EMTabBarType.createItem(.Chats).setSelectd(true).clickAction {[weak self] in
            self?.selectedIndex = 0
        }
        return itemChats
    }()
    
    
    override var selectedIndex: Int{
        didSet{
            if self.currentItem != selectedIndex {
                let barItem = self.customTabBar.emItems[self.currentItem]
                barItem.isSelect = false
                let item = self.customTabBar.emItems[selectedIndex]
                item.isSelect = true
                self.currentItem = selectedIndex
            }
        }
    }
    
    
}


extension EMTabBarController{
    @objc func messageChange(_ notice : Notification){
        itemChats.dot.isHidden = (((notice.object as? Int64) ?? 0) == 0)
    }
}

extension EMTabBarController : UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.count > 1{
            self.customTabBar.superview?.isHidden = true
        }
        if (viewController is EMHideNavigationBarProtocol){
            navigationController.setNavigationBarHidden(true, animated: true)
        } else {
            navigationController.setNavigationBarHidden(false, animated: true)
        }
    }
    
    
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.count <= 1{
            self.customTabBar.superview?.isHidden = false
        }
    }
}
