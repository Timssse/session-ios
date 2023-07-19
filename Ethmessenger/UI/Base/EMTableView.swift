// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionUIKit
class EMTableView: UITableView {

    convenience init(delegate : UITableViewDelegate,dataSource : UITableViewDataSource,backgroundColor : ThemeValue) {
        self.init()
        self.delegate = delegate
        self.dataSource = dataSource
        self.themeBackgroundColor = backgroundColor
        self.separatorColor = UIColor.clear
        self.showsVerticalScrollIndicator = false
        self.separatorStyle = .none
        if #available(iOS 15.0, *) {
            self.sectionHeaderTopPadding = 0
        }
    }

}
