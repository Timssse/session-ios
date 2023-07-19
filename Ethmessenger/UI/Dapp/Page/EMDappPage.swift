// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMDappPage: BaseVC {
    var model : EMDappModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = model.name
        self.createUI()
    }
    
    func createUI() {
        self.view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
    
    lazy var webView : EMDappView = {
        let view = EMDappView(account: WalletUtilities.account, dapp: model)
        return view
    }()

}
