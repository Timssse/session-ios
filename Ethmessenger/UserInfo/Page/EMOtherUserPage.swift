// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionUIKit

class EMOtherUserPage: EMRefreshController,EMHideNavigationBarProtocol {
    var address : String = ""
//    var userInfo : Profile?
    var emUserInfo : EMCommunityUserEntity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(refressh), name: kNotifyRefreshCommunity, object: nil)
        self.refressh()
        
        AnimationManager.shared.setAnimation(self.view)
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
    
    
    lazy var navView : EMOtherUserNav = {
        let view = EMOtherUserNav()
        return view
    }()
    
    lazy var tableView : UITableView = {
        let tableView = EMTableView(delegate: self, dataSource: self, backgroundColor: .clear)
        tableView.register(EMUserCommunitCell.self, forCellReuseIdentifier: "EMUserCommunitCell")
        tableView.register(EMOtherUserInfo.self, forCellReuseIdentifier: "EMOtherUserInfo")
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: Screen_width, height: 20.w))
        let footerView = UIView(.conversationButton_background)
        footerView.frame = CGRect(x: 0, y: 0, width: Screen_width, height: 90.w)
        tableView.tableFooterView = footerView
        setRefreshView(tableView)
        return tableView
    }()

    lazy var footerView : UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Screen_width, height: 70.w + 90.w))
        let circleView = UIView(UIColor.clear)
        circleView.dealBorderLayer(corner: 4.w, bordercolor: .textPrimary, borderwidth: 1)
        view.addSubview(circleView)
        circleView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(21.w)
            make.top.equalToSuperview().offset(17.w)
            make.size.equalTo(CGSize(width: 8.w, height: 8.w))
        }
        
        let topLine = UIView(.line)
        view.addSubview(topLine)
        topLine.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalTo(circleView)
            make.bottom.equalTo(circleView.snp.top)
            make.width.equalTo(1)
        }
        
        let bottomLine = UIView(.line)
        view.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { make in
            make.height.equalTo(32.w)
            make.centerX.equalTo(circleView)
            make.top.equalTo(circleView.snp.bottom)
            make.width.equalTo(1)
        }
        
        return view
    }()
    
    lazy var notDataView : UIView = {
        let view = EMPlaceholder.show(EMPlaceholder.emptyTwitter(isPost: true, target: self, postAction: #selector(onclickPublish)),frame: CGRect(x: 0, y: 0, width: Screen_width, height: 380.w),centerY: -70.w)
        return view
    }()
    
    lazy var dataArr : [EMCommunityHomeListEntity] = {
        return []
    }()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension EMOtherUserPage{
    override func refressh() {
        self.page = 1
        isLoadMore = false
        getUserInfo()
        getData()
    }
    
    func getUserInfo(){
        Task{
            emUserInfo = await EMUserController.userInfo(address)
            self.navView.labTitle.text = emUserInfo?.Nickname
            self.tableView.reloadData()
            AnimationManager.shared.removeAnimaition(self.view)
        }
    }
    
    func getData(){
        if isLoadMore == true{
            return
        }
        isLoadMore = true
        Task{
            let cursor = self.page == 1 ? "" : self.dataArr.last?.Cursor ?? ""
            let data = await EMUserController.tweetsList(address,cursor: cursor)
            isLoadMore = data.count < 10
            if self.page == 1{
                self.dataArr.removeAll()
            }
            self.endRefreshing()
            self.page += 1
            self.dataArr += data
            self.tableView.reloadData()
            self.tableView.tableFooterView = dataArr.count > 0 ? self.footerView : self.notDataView
            
        }
    }
}

extension EMOtherUserPage{
    @objc func onclickPublish(){
        let vc = EMPublishPage(forward: nil)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

extension EMOtherUserPage : UITableViewDelegate,UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : self.dataArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EMOtherUserInfo", for: indexPath) as! EMOtherUserInfo
            cell.emUserInfo = self.emUserInfo
//            cell.labSessionId.text = self.emUserInfo?.UserAddress.showAddress(6)
//            cell.userInfo = self.userInfo
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "EMUserCommunitCell", for: indexPath) as! EMUserCommunitCell
        cell.model = self.dataArr[indexPath.row]
        cell.isFirst = indexPath.row == 0
        cell.toolView.likeBlock = {[weak self] in
            let model = (self?.dataArr[indexPath.row])!
            model.isTwLike = !model.isTwLike
            model.LikeCount = model.isTwLike ? (model.LikeCount + 1) : (model.LikeCount > 0 ? model.LikeCount - 1 : 0)
            self?.dataArr[indexPath.row] = model
            self?.tableView.reloadData()
            Task{
                await EMCommunityController.like(model.TwAddress)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }
        let vc = EMCommunityDetailPage(model: self.dataArr[indexPath.row])
        self.push(vc)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }
        if isLoadMore || self.dataArr.count < 10{
            return
        }
        let lastRow = tableView.numberOfRows(inSection: 1) - 1
        if indexPath.row == lastRow {
            isLoadMore = true
            getData()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 50.w {
            self.navView.backgroundColor = .clear
            self.navView.labTitle.isHidden = true
            return
        }
        
        if scrollView.contentOffset.y > 150.w {
            self.navView.labTitle.isHidden = false
            self.navView.backgroundColor = UIColor(hex: "3E66FB")
            return
        }
        self.navView.labTitle.alpha = (scrollView.contentOffset.y - 50.w)/100.w
        self.navView.backgroundColor = UIColor(hex: "3E66FB",alpha: (scrollView.contentOffset.y - 50.w)/100.w)
    }
}

