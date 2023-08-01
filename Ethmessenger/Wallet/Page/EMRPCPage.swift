// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMRPCPage: BaseVC {
    
    
    private var selectIndex = 0
//    private var isDefine = false
//    private var definText = ""
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func layoutUI() {
        self.title = LocalRPCNode.localized()
        getCurrentIndex()
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        dealData()
    }
    
    func dealData() {
        for (index,model) in rpcs.enumerated() {
            self.getBlockNum(model, index: index)
        }
        
//        definText = chain.rpc
//        var isContain = false
//        for (i,rpc) in rpcs.enumerated() {
//            if rpc.rpc == definText {
//                selectIndex = i
//                isContain = true
//            }
//        }
//        if isContain == false {
//            isDefine = true
//        }
//        self.tableView.reloadData()
    }
    
    func getBlockNum(_ rpc :EMRPCModel,index : Int) {
        Task{
            let time = Date().timeIntervalSince1970 * 1000
            let relust = await EMWalletController.getBlockNumberRequest(rpc.rpc, chainId: self.networkModel.chain_id)
            if relust > 0{
                if rpc.ms == 0 {
                    let model = rpc
                    let doneTime = Date().timeIntervalSince1970 * 1000
                    model.blockHeight = FS(relust)
                    model.ms = Int(doneTime - time)
                    self.rpcs[index] = model
                    self.tableView.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: .none)
                }
            }
        }
    }
    
    lazy var tableView: EMTableView = {
        let tableview = EMTableView(delegate: self, dataSource: self, backgroundColor: .wallet_bg)
        tableview.register(EMRPCCell.self, forCellReuseIdentifier: "EMRPCCell")
        tableview.dealCorner(type: .topLeftRight, corner: 20.w)
        tableview.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: Screen_width, height: 20.w))
        return tableview
    }()
    
    lazy var networkModel : EMNetworkModel  = {
        guard let currentNetwork = EMNetworkModel.getNetwork() else{
            return EMNetworkModel()
        }
        return currentNetwork
    }()
    
    lazy var rpcs : [EMRPCModel] = {
        return self.networkModel.rpc
    }()
    
    lazy var chain : EMChain = {
        return EMChain.init(chainId: self.networkModel.chain_id)
    }()
}

extension EMRPCPage{
    func getCurrentIndex(){
        let currentRPC = chain.rpc
        for (i,rpc) in rpcs.enumerated() {
            if rpc.rpc == currentRPC {
                selectIndex = i
                return
            }
        }
        selectIndex = 0
    }
    
    func selectRPC(_ index : Int) {
        guard rpcs.count != 0 else {
            return
        }
        let str = rpcs[selectIndex].rpc
        
        Task{
            let relust = await EMWalletController.getBlockNumberRequest(str, chainId: self.networkModel.chain_id)
            if relust == 0 {
                getCurrentIndex()
                self.tableView.reloadData()
                Toast.toast(hit: LocalNodeNotUse.localized())
                return
            }
            chain.saveRpc(str)
            Toast.toast(hit: LocalNodeSwitchSuccess.localized())
        }
    }
}

extension EMRPCPage: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rpcs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EMRPCCell", for: indexPath) as! EMRPCCell
        cell.model = self.rpcs[indexPath.row]
        cell.isSelect = selectIndex == indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == selectIndex{
            return
        }
        self.selectIndex = indexPath.row
        tableView.reloadData()
        selectRPC(indexPath.row)
    }
}
