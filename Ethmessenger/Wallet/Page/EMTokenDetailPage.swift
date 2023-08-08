// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMTokenDetailPage: EMRefreshController {
    var token : EMTokenModel!
    
    init(token:EMTokenModel){
        self.token = token
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AnimationManager.shared.setAnimation(self.view)
        self.refressh()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnimationManager.shared.removeAnimaition(self.view)
    }
    
    override func layoutUI() {
        self.title = LocalTokenDetail.localized()
        
        self.view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(safeBottomH + 61.w)
        }
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
    }
    
    
    
    lazy var headView : EMTokenHeadView = {
        let view = EMTokenHeadView(frame: CGRect(x: 0, y: 0, width: Screen_width, height: token.contract == "" ? 250.w : 290.w))
        view.model = self.token
        return view
    }()
    
    lazy var tableView : UITableView = {
        let tableView = EMTableView(delegate: self, dataSource: self, backgroundColor: .wallet_bg)
        tableView.dealCorner(type: .topLeftRight, corner: 20.w)
        tableView.register(EMTokenRecordCell.self, forCellReuseIdentifier: "EMTokenRecordCell")
        tableView.tableHeaderView = self.headView
        setRefreshView(tableView)
        return tableView
    }()
    
    lazy var bottomView : UIView = {
        let view = UIView.init(.wallet_bg)
        let btnSend = UIButton.init(title: " " + LocalTrasfer.localized(),font: UIFont.Bold(size: 15),color: .white,backgroundColor: .FF823B)
        btnSend.addTarget(self, action: #selector(onclickSend), for: UIControl.Event.touchUpInside)
        btnSend.dealLayer(corner: 8.w)
        view.addSubview(btnSend)
        btnSend.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalToSuperview().offset(10.w)
            make.size.equalTo(CGSize.init(width: 152.w, height: 41.w))
        }
        
        let btnRevice = UIButton.init(title: " " +  LocalReceive.localized(),font: UIFont.Bold(size: 15),color: .white,backgroundColor: .messageBubble_outgoingBackground)
        btnRevice.addTarget(self, action: #selector(onclickRevice), for: UIControl.Event.touchUpInside)
        btnRevice.dealLayer(corner: 8.w)
        view.addSubview(btnRevice)
        btnRevice.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-25.w)
            make.centerY.equalTo(btnSend)
            make.size.equalTo(CGSize.init(width: 152.w, height: 41.w))
        }
        
        return view
    }()

    var dataArr : [EMTradeListModel] = []

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension EMTokenDetailPage{
            
    override func refressh() {
        Task{
            await self.token?.getBalance()
            self.headView.model = token
            self.page = 1
            await getData()
            self.endRefreshing()
            self.tableView.reloadData()
            self.setFooterView()
            AnimationManager.shared.removeAnimaition(self.view)
        }
    }
    
    func loadMore(){
        Task{
            await getData()
            self.setFooterView()
            self.tableView.reloadData()
        }
    }
    
    func setFooterView() {
        self.tableView.tableFooterView = self.dataArr.count == 0 ? EMPlaceholder.show(.empty,frame: CGRect(x: 0, y: 0, width: Screen_width, height: Screen_height - navHeight - 290.w)) : nil
    }
    
    
    func getData() async {
        let chain = EMChain(chainId: self.token.chain_id)
        let result = await EMWalletController.tradeHistoryRequest(address: WalletUtilities.address, url: chain.browserApi, apiKey: chain.browserApiKey, page: self.page,contractaddress: token.contract)
        ///小于10 就不在加载更多了
        isLoadMore = (result.count < 10)
        
        if (self.page == 1){
            self.dataArr.removeAll()
        }
        self.page += 1
        self.dataArr += result
        
    }
    
    @objc func onclickSend(){
        self.push(EMTransferPage(token: token))
    }
    
    @objc func onclickRevice(){
        EMAlert.alert(.receive)?.popup()
    }
}

extension EMTokenDetailPage : UITableViewDelegate,UITableViewDataSource{
    
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "EMTokenRecordCell", for: indexPath) as! EMTokenRecordCell
        cell.model = self.dataArr[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoadMore || self.dataArr.count < 10{
            return
        }
        let lastRow = tableView.numberOfRows(inSection: 0) - 1
        if indexPath.row == lastRow {
            isLoadMore = true
            loadMore()
        }
    }
}
