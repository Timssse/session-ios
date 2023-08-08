// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMTabBar: UITabBar {
    var emItems : [EMTabBarItem] = []
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setUpItems()
    }
    
    func setUpItems() {
        
        let line = UIView(.line)
        line.frame = CGRect.init(x: 0, y: 0, width: Screen_width, height: 1)
        self.addSubview(line)
        
        let width = self.frame.width / CGFloat(self.emItems.count)
        let height = self.frame.height
        for i in 0..<self.emItems.count {
            let item = self.emItems[i]
            item.frame = CGRect.init(x: CGFloat(i)*width, y: 0, width: width, height: height)
            self.addSubview(item)
        }
    }
    
}
