// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMTipAlertViewController: EMAlertController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func title(_ title: String) -> EMTipAlertViewController {
        alert.titleText = title
        alert.title.isHidden = false
        return self
    }
    
    override func content(_ content: String) -> EMTipAlertViewController {
        alert.contentText = content
        alert.content.isHidden = false
        return self
    }
    
    override func confirm(_ buttonText: String) -> EMTipAlertViewController {
        alert.confirmText = buttonText
        alert.confirmButton.isHidden = false
        return self
    }
    
    override func cancel(_ buttonText: String) -> EMAlertController {
        alert.cancelText = buttonText
        alert.cancelButton.isHidden = false
        return self
    }
    
    override func setup() {
        view.addSubview(alert)
        alert.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(24.w)
            make.trailing.equalToSuperview().offset(-24.w)
        }
    }
    
    private lazy var alert: EMCommonAlertView = {
        let view = EMCommonAlertView()
        view.confirmButton.addTarget(self, action: #selector(confirmButtonAction), for: .touchUpInside)
        view.cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        return view
    }()
}

