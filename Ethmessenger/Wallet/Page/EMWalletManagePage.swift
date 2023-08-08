// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMWalletManagePage: BaseVC{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func layoutUI() {
        self.title = LocalManage.localized()
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    

    lazy var tableView : UITableView = {
        let tableView = EMTableView(delegate: self, dataSource: self, backgroundColor: .wallet_bg)
        tableView.dealCorner(type: .topLeftRight, corner: 20.w)
        tableView.register(EMWalletManageCell.self, forCellReuseIdentifier: "EMWalletManageCell")
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: Screen_width, height: 20.w))
        return tableView
    }()

    lazy var dataArr : [EMWalletManageItemModel] = {
        return EMWalletManageItemType.createManageData()
    }()
    
}


extension EMWalletManagePage : UITableViewDelegate,UITableViewDataSource{
    
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "EMWalletManageCell", for: indexPath) as! EMWalletManageCell
        cell.model = self.dataArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.dataArr[indexPath.row]
        if model.clickType == .copy{
            UIPasteboard.general.string = model.content
            Toast.toast(hit: "copied".localized())
            return
        }
        if model.type == .changePassword{
            if WalletUtilities.account.password == nil{
                self.push(EMWalletSetPasswordPage())
                return
            }
            self.push(EMWalletChangePasswordPage())
            return
        }
        if model.type == .mnemonics{
            EMAlert.alert(.password)?.confirmAction {[weak self] _ in
                self?.push(EMViewMnemonicsPage())
            }.popup()
            return
        }
        if model.type == .privateKey{
            EMAlert.alert(.password)?.confirmAction {[weak self] _ in
                self?.push(EMViewPrivateKeyPage())
            }.popup()
            return
        }
        if model.type == .rpcNode{
            self.push(EMRPCPage())
        }
    }
    
}
