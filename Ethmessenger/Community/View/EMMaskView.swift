// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMMaskView: UIView {
    var clickBlock : (()->())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.4)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclick)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onclick(){
        self.clickBlock?()
    }
    
}
