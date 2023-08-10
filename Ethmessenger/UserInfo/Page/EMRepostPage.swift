// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMRepostPage: EMRefreshController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func layoutUI() {
        self.title = LocalRepost.localized()
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.refressh()
    }

    lazy var tableView : UITableView = {
        let tableView = EMTableView(delegate: self, dataSource: self, backgroundColor: .conversationButton_background)
        tableView.dealCorner(type: .topLeftRight, corner: 20.w)
        tableView.register(EMLikeCell.self, forCellReuseIdentifier: "EMLikeCell")
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: Screen_width, height: 20.w))
        setRefreshView(tableView)
        return tableView
    }()

    
    lazy var dataArr : [EMCommunityLikeMeEntity] = {
        return []
    }()
    
}

extension EMRepostPage{
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
            let data = await EMCommunityController.repostListMe(self.page)
            isLoadMore = data.count < 10
            if self.page == 1{
                self.dataArr.removeAll()
            }
            self.endRefreshing()
            self.page += 1
            self.dataArr += data
            self.tableView.reloadData()
        }
    }
}


extension EMRepostPage : UITableViewDelegate,UITableViewDataSource{
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "EMLikeCell", for: indexPath) as! EMLikeCell
        cell.model = self.dataArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = EMCommunityDetailPage(model: self.dataArr[indexPath.row])
//        self.push(vc)
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
