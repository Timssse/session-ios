// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

enum EMAlert {
    case tip
    case success
    
    static func alert(_ type: EMAlert = tip) -> EMAlertController {
        let alert = EMAlertController()
        alert.type = type
        return alert
    }
}

extension EMAlertController {
    @discardableResult
    func title(_ title: String) -> EMAlertController {
        alert.titleText = title
        alert.title.isHidden = false
        return self
    }
    
    @discardableResult
    func content(_ content: String) -> EMAlertController {
        alert.contentText = content
        alert.content.isHidden = false
        return self
    }
    
    @discardableResult
    func confirm(_ buttonText: String) -> EMAlertController {
        alert.confirmText = buttonText
        alert.confirmButton.isHidden = false
        return self
    }
    
    @discardableResult
    func cancel(_ buttonText: String) -> EMAlertController {
        alert.cancelText = buttonText
        alert.cancelButton.isHidden = false
        return self
    }
    
    @discardableResult
    func confirmAction(_ action: @escaping () -> Void) -> EMAlertController {
        confirmAction = action
        return self
    }
    
    @discardableResult
    func cancelAction(_ action: @escaping () -> Void) -> EMAlertController {
        cancelAction = action
        return self
    }
    
//    @discardableResult
//    func customView(_ view: UIView) -> EMAlertController {
//        alert = view
//        return self
//    }
    
    @discardableResult
    func popup() -> EMAlertController {
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        UIUtil.visibleVC()?.present(self, animated: true)
        return self
    }
}

class EMAlertController: UIViewController {
    var type = EMAlert.tip
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setup()
    }
    
    func setup() {
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
    
    private var confirmAction: (() -> Void)? = nil
    private var cancelAction: (() -> Void)? = nil
}

extension EMAlertController {
    @objc func confirmButtonAction() {
        dismiss(animated: false, completion: confirmAction)
    }
    
    @objc func cancelButtonAction() {
        dismiss(animated: false, completion: cancelAction)
    }
}


