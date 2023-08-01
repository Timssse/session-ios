// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

enum EMAlert {
    case tip
    case success
    case input
    case password
    case selectNetwork
    
    static func alert(_ type: EMAlert = .tip) -> EMAlertController {
        if type == .tip{
            return EMTipAlertViewController()
        }
        if type == .input{
            return EMInputAlertViewController()
        }
        if type == .password{
            return EMPasswordAlertViewController()
        }
        if type == .selectNetwork{
            return EMSelectNetworkVC()
        }
        
        let alert = EMAlertController()
        alert.type = type
        return alert
    }
}

extension EMAlertController {
    
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
        let bgView = UIView()
        self.view.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelButtonAction)))
        
        setup()
    }
    
    func setup() {
        
    }
    
    @discardableResult
    func title(_ title: String) -> EMAlertController {
        
        return self
    }
    
    @discardableResult
    func content(_ content: String) -> EMAlertController {
        
        return self
    }
    
    @discardableResult
    func confirm(_ buttonText: String) -> EMAlertController {
        
        return self
    }
    
    @discardableResult
    func cancel(_ buttonText: String) -> EMAlertController {
        
        return self
    }
    
    @discardableResult
    func confirmAction(_ action: @escaping (Any) -> Void) -> EMAlertController {
        confirmAction = action
        return self
    }
    
    @discardableResult
    func cancelAction(_ action: @escaping () -> Void) -> EMAlertController {
        cancelAction = action
        return self
    }
    
    @objc func confirmButtonAction() {
        confirmAction?("")
        dismiss(animated: false, completion: nil)
    }
    
    @objc func cancelButtonAction() {
        dismiss(animated: false, completion: cancelAction)
    }
    
    var confirmAction: ((Any) -> Void)? = nil
    private var cancelAction: (() -> Void)? = nil
}


