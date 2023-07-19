// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMRefreshController: BaseVC {
    var page = 1
    var isLoadMore = false
    private var contentScrollView : UIScrollView?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    func setRefreshView(_ scrollView : UIScrollView){
        self.contentScrollView = scrollView
        let refreshControl = UIRefreshControl();
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(refressh), for: .valueChanged)
        self.contentScrollView?.refreshControl = refreshControl;
    }

}

extension EMRefreshController{
    func beginRefreshing(){
        if self.contentScrollView?.refreshControl?.isRefreshing == false{
            self.contentScrollView?.refreshControl?.beginRefreshing()
            self.contentScrollView?.refreshControl?.sendActions(for: .valueChanged)
        }
    }
    
    func endRefreshing(){
        self.contentScrollView?.refreshControl?.endRefreshing()
    }
    
    
    @objc func refressh(){
        
    }
}
