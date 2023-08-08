// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionUIKit

class EMUserPage: BaseVC ,EMHideNavigationBarProtocol,ThemedNavigation{

    var userInfo : Profile?
    var emUserInfo : EMCommunityUserEntity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userInfo = Profile.fetchOrCreateCurrentUser()
        self.getUserInfo()
    }
    
    override func layoutUI() {
        self.view.themeBackgroundColor = .conversationButton_background
        let topBg = UIImageView(image: UIImage(named: "icon_user_top_bg"))
        self.view.addSubview(topBg)
        topBg.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(235.w)
        }
        
        self.view.addSubview(navView)
        navView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(navHeight)
        }
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(navView.snp.bottom)
        }
    }
    

    lazy var navView : EMMyNav = {
        let view = EMMyNav()
        return view
    }()
    
    lazy var tableView : UITableView = {
        let tableView = EMTableView(delegate: self, dataSource: self, backgroundColor: .clear)
        tableView.register(EMUserSettingCell.self, forCellReuseIdentifier: "EMUserSettingCell")
        tableView.register(EMUserInfoCell.self, forCellReuseIdentifier: "EMUserInfoCell")
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: Screen_width, height: 20.w))
        return tableView
    }()
    
    lazy var dataArr : [EMSettingCellModel] = {
        return EMSettingSectionType.createSection(.userSetting).cells
    }()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension EMUserPage{
    
    func getUserInfo(){
        Task{
            emUserInfo = await EMUserController.userInfo(WalletUtilities.address)
            self.navView.userInfo = emUserInfo
            self.navView.profile = self.userInfo
            self.tableView.reloadData()
        }
    }
}

extension EMUserPage{
    @objc func onclickPublish(){
        let vc = EMPublishPage(forward: nil)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

extension EMUserPage : UITableViewDelegate,UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return self.dataArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EMUserInfoCell", for: indexPath) as! EMUserInfoCell
            cell.emUserInfo = self.emUserInfo
            cell.userInfo = self.userInfo
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "EMUserSettingCell", for: indexPath) as! EMUserSettingCell
        cell.model = self.dataArr[indexPath.row]
        cell.labTitle.themeTextColor = .textPrimary
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }
        let model = self.dataArr[indexPath.row]
        if model.type == .invite{
            let invitation: String = "Hey, I've been using Ethmessager to chat with complete privacy and security. Come join me! Download it at https://ethmessenger.app/. My Session ID is \(userInfo?.id ?? "") !"
            self.present(UIActivityViewController(
                activityItems: [ invitation ],
                applicationActivities: nil
            ), animated: true)
            return
        }
        if model.type == .setting{
            self.push(EMSettingPage())
            return
        }
        if model.type == .aboutUs{
            self.push(EMAboutUsPage())
            return
        }
    }
    
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 20.w {
            self.navView.backgroundColor = .clear
            self.navView.userInfoView.isHidden = true
            return
        }
        
        if scrollView.contentOffset.y > 90.w {
            self.navView.backgroundColor = UIColor(hex: "3E66FB")
            self.navView.userInfoView.isHidden = false
            return
        }
        self.navView.backgroundColor = UIColor(hex: "3E66FB",alpha: (scrollView.contentOffset.y - 20.w)/70.w)
    }
}
