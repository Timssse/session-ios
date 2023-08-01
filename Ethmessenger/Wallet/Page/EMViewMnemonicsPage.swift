// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMViewMnemonicsPage: BaseVC {
    var walletName : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = LocalViewMnemonics.localized()
        createUI()
    }
    
    func createUI(){
        let contentView = UIView(.wallet_bg)
        contentView.dealCorner(type: .topLeftRight, corner: 20.w)
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let labTitle = UILabel.init(font: UIFont.Bold(size: 16),textColor: .textPrimary,text: LocalMnemonicWords.localized())
        contentView.addSubview(labTitle)
        labTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalToSuperview().offset(34.w)
        }
        
        let labTips = UILabel.init(font: UIFont.Regular(size: 12),textColor: .color_91979D,text: LocalViewMnemonicTips.localized())
        labTips.numberOfLines = 0
        contentView.addSubview(labTips)
        labTips.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30.w)
            make.right.equalToSuperview().offset(-30.w)
            make.top.equalTo(labTitle.snp.bottom).offset(10.w)
        }
        
        self.view.addSubview(mnemonicView)
        mnemonicView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(labTips.snp.bottom).offset(20.w)
            make.height.equalTo( 467.w)
        }
        
        
    }
    
    lazy var mnemonics : [String] = {
        let mnemonics = WalletUtilities.account.mnemonic.split(separator: " ").map{String($0)}
        return mnemonics
    }()
    
    lazy var mnemonicView : EMMnemonicView = {
        let view = EMMnemonicView(mnemonic: self.mnemonics)
        return view
    }()
}



