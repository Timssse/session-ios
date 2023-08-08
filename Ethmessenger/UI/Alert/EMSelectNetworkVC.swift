// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMSelectNetworkVC: EMAlertController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setup() {
        let contentView = UIView(.communitInput)
        contentView.dealCorner(type: .topLeftRight, corner: 20.w)
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(350.h + safeBottomH)
        }
        
        let labTitle = UILabel(font: UIFont.Bold(size: 17),textColor: .textPrimary,text: "Network")
        contentView.addSubview(labTitle)
        labTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(18.w)
        }
        
        let btnConfirm = UIButton(title:LocalConfirm.localized(),font: UIFont.Bold(size: 15), color: .white, backgroundColor:.messageBubble_outgoingBackground)
        btnConfirm.addTarget(self, action: #selector(confirmButtonAction), for: .touchUpInside)
        btnConfirm.dealLayer(corner: 10.w)
        contentView.addSubview(btnConfirm)
        btnConfirm.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-safeBottomH)
            make.size.equalTo(CGSize(width: 325.w, height: 41.w))
        }
        
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(btnConfirm.snp.top).offset(-10.w)
            make.top.equalTo(labTitle.snp.bottom).offset(15.w)
        }
        
    }
    
    
    override func confirmButtonAction() {
        if dataArr.count == 0{
            return
        }
        let model = dataArr[selectIndex]
        EMNetworkModel.save(network: model)
        confirmAction?(model)
        dismiss(animated: true)
    }
    
    lazy var tableView : UITableView = {
        let tableView = EMTableView(delegate: self, dataSource: self, backgroundColor: .communitInput)
        tableView.register(EMSelelctNetworkCell.self, forCellReuseIdentifier: "EMSelelctNetworkCell")
        return tableView
    }()
    
    lazy var dataArr : [EMNetworkModel] = {
        return EMWalletConfigModel.shared.network
    }()
    
    lazy var selectIndex : Int = {
        guard let currentNetwork = EMNetworkModel.getNetwork() else{
            return 0
        }
        for (index,value) in dataArr.enumerated(){
            if value.chain_id == currentNetwork.chain_id{
                return index
            }
        }
        return 0
    }()
}


extension EMSelectNetworkVC: UITableViewDelegate,UITableViewDataSource{
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "EMSelelctNetworkCell", for: indexPath) as! EMSelelctNetworkCell
        cell.model = self.dataArr[indexPath.row]
        cell.isSelect = indexPath.row == selectIndex
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectIndex = indexPath.row
        tableView.reloadData()
    }
}
