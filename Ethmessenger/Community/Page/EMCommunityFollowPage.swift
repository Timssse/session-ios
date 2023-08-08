// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMCommunityFollowPage: EMRefreshController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(refressh), name: kNotifyRefreshCommunity, object: nil)
    }
    
    override func layoutUI() {
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.refressh()
    }

    lazy var tableView : UITableView = {
        let tableView = EMTableView(delegate: self, dataSource: self, backgroundColor: .conversationButton_background)
        tableView.register(EMCommunityCell.self, forCellReuseIdentifier: "EMCommunityCell")
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: Screen_width, height: 20.w))
        
        
        setRefreshView(tableView)
        return tableView
    }()

    
    lazy var notDataView : UIView = {
        let view = EMPlaceholder.show(EMPlaceholder.emptyTwitter())
        return view
    }()
    
    lazy var dataArr : [EMCommunityHomeListEntity] = {
        return []
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension EMCommunityFollowPage{
    override func refressh() {
        self.page = 1
        isLoadMore = false
        getData()
    }
    
    func getData(){
        if isLoadMore == true{
            return
        }
        isLoadMore = true
        Task{
            let cursor = self.page == 1 ? "" : self.dataArr.last?.Cursor ?? ""
            let data = await EMCommunityController.followTwitterList(cursor)
            isLoadMore = data.count < 10
            if self.page == 1{
                self.dataArr.removeAll()
            }
            self.endRefreshing()
            self.page += 1
            self.dataArr += data
            self.tableView.reloadData()
            self.tableView.tableFooterView = self.dataArr.count > 0 ? UIView() : notDataView
        }
    }
}


extension EMCommunityFollowPage : UITableViewDelegate,UITableViewDataSource{
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "EMCommunityCell", for: indexPath) as! EMCommunityCell
        cell.model = self.dataArr[indexPath.row]
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
        let vc = EMCommunityDetailPage(model: self.dataArr[indexPath.row])
        self.push(vc)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoadMore || self.dataArr.count < 10{
            return
        }
        let lastRow = tableView.numberOfRows(inSection: 0) - 1
        if indexPath.row == lastRow {
            isLoadMore = true
            getData()
        }
    }
}
