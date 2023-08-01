// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMPasswordAlertViewController: EMAlertController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func confirmButtonAction() {
        if WalletCrypto.md5Encrypt(value: FS(alert.textPassword.text)) != WalletUtilities.account.password{
            Toast.toast(hit: LocalPasswordFailPrompt.localized())
            return
        }
        confirmAction?(FS(alert.textPassword.text))
        dismiss(animated: false, completion: nil)
    }
    
    override func setup() {
        view.addSubview(alert)
        alert.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(24.w)
            make.trailing.equalToSuperview().offset(-24.w)
        }
    }
    
    private lazy var alert: EMPasswordAlertView = {
        let view = EMPasswordAlertView()
        view.confirmButton.addTarget(self, action: #selector(confirmButtonAction), for: .touchUpInside)
        return view
    }()
}

