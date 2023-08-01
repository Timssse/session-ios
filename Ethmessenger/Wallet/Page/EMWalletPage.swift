// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionUIKit

class EMWalletPage: EMRefreshController ,EMHideNavigationBarProtocol,ThemedNavigation{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getData()
        NotificationCenter.default.addObserver(self, selector: #selector(updateToken), name: kNotifyAddToken, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(chainChange), name: kNotifychangeChain, object: nil)
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
        
        self.view.addSubview(headView)
        headView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(navView.snp.bottom)
        }
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(headView.snp.bottom).offset(-20.w)
        }
    }
    
    lazy var navView : EMWalletNav = EMWalletNav()
    
    lazy var headView : EMWalletHeadView = {
        let view = EMWalletHeadView()
        view.hiddenMoneyBlock = {
            self.tableView.reloadData()
        }
        return view
    }()
    
    lazy var tableView : UITableView = {
        let tableView = EMTableView(delegate: self, dataSource: self, backgroundColor: .wallet_bg)
        tableView.dealCorner(type: .topLeftRight, corner: 20.w)
        tableView.register(EMWalletTokenCell.self, forCellReuseIdentifier: "EMWalletTokenCell")
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: Screen_width, height: 20.w))
        let footerView = UIView(.conversationButton_background)
        footerView.frame = CGRect(x: 0, y: 0, width: Screen_width, height: 90.w)
        tableView.tableFooterView = footerView
        setRefreshView(tableView)
        return tableView
    }()

    var dataArr : [EMTokenModel] = []

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension EMWalletPage{
    func getData(){
        self.navView.chain = EMWalletConfigModel.shared.network.first
        updateToken()
    }
    
    @objc func updateToken(){
        dataArr = EMTableToken.selectTokenWithChainId(WalletUtilities.account.chain.chainId)
        self.tableView.reloadData()
        Task{
            await EMWalletController.getTokensBalance(WalletUtilities.account.chain.chainId)
            dataArr = EMTableToken.selectTokenWithChainId(WalletUtilities.account.chain.chainId)
            self.tableView.reloadData()
        }
    }
    
    @objc func chainChange(){
        navView.chain = EMNetworkModel.getNetwork()
    }
}

extension EMWalletPage{
    @objc func onclickPublish(){
        let vc = EMPublishPage(forward: nil)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

extension EMWalletPage : UITableViewDelegate,UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EMWalletTokenCell", for: indexPath) as! EMWalletTokenCell
        cell.model = self.dataArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.w
    }
        
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Screen_width, height: 60.w))
        let lab = UILabel(font: UIFont.Medium(size: 16),textColor: .textPrimary,text: "Tokens")
        view.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(25.w)
        }
        let btnAdd = UIButton(image: UIImage(named: "icon_wallet_add_token"))
        view.addSubview(btnAdd)
        btnAdd.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-25.w)
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
