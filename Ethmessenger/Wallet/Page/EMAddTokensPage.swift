// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import web3swift
import Web3Core

class EMAddTokensPage: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        showNavRight("context_menu_save".localized())
    }
    

    override func layoutUI() {
        self.title = LocalAddTokens.localized()
        
        let contentView = UIView(.wallet_bg)
        contentView.dealCorner(type: .topLeftRight, corner: 20.w)
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let labTokenContract = UILabel.init(font:UIFont.Medium(size: 15),textColor:.textPrimary,text:LocalTokenContract.localized())
        contentView.addSubview(labTokenContract)
        labTokenContract.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalTo(contentView).offset(40.w)
        }
        
        contentView.addSubview(textContract)
        textContract.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalTo(labTokenContract.snp.bottom).offset(5.w)
            make.right.equalToSuperview().offset(-25.w)
            make.height.equalTo(58.w)
        }
        
        let labSymbol = UILabel.init(font:UIFont.Medium(size: 15),textColor:.textPrimary,text:LocalSymbol.localized())
        contentView.addSubview(labSymbol)
        labSymbol.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalTo(textContract.snp.bottom).offset(20.w)
        }
        
        contentView.addSubview(textSymbol)
        textSymbol.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalTo(labSymbol.snp.bottom).offset(5.w)
            make.right.equalToSuperview().offset(-25.w)
            make.height.equalTo(58.w)
        }
        
        let labDecimals = UILabel.init(font:UIFont.Medium(size: 15),textColor:.textPrimary,text:LocalDecimals.localized())
        contentView.addSubview(labDecimals)
        labDecimals.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalTo(textSymbol.snp.bottom).offset(20.w)
        }
        
        contentView.addSubview(textDecimal)
        textDecimal.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalTo(labDecimals.snp.bottom).offset(5.w)
            make.right.equalToSuperview().offset(-25.w)
            make.height.equalTo(58.w)
        }
    }
    
    lazy var textContract : UITextField = {
        let text = UITextField.init(LocalTokenContractPlaceholder.localized(),font:UIFont.Medium(size: 12),textColor:.textPrimary)
        text.dealBorderLayer(corner: 14.w, bordercolor: .password_border_color, borderwidth: 1)
        text.addLeftView(14.w)
        text.delegate = self
        return text
    }()
    
    lazy var textSymbol : UITextField = {
        let text = UITextField.init(LocalSymbol.localized(),font:UIFont.Medium(size: 12),textColor:.textPrimary)
        text.dealBorderLayer(corner: 14.w, bordercolor: .password_border_color, borderwidth: 1)
        text.addLeftView(14.w)
        text.isUserInteractionEnabled = false
        text.delegate = self
        return text
    }()
    
    
    lazy var textDecimal : UITextField = {
        let text = UITextField.init("18",font:UIFont.Medium(size: 12),textColor:.textPrimary)
        text.dealBorderLayer(corner: 14.w, bordercolor: .password_border_color, borderwidth: 1)
        text.addLeftView(14.w)
        text.isUserInteractionEnabled = false
        text.keyboardType = .numberPad
        text.delegate = self
        return text
    }()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension EMAddTokensPage: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.textContract{
            Task{
                await getTokenInfo()
            }
        }
    }
    
    @discardableResult
    func getTokenInfo() async -> ERC20?{
        
        guard let network = EMNetworkModel.getNetwork() else{
            return nil
        }
        
        if (self.textContract.text == ""){
            return nil
        }
        
        AnimationManager.shared.setAnimation(self.view)
        let chain = EMChain.init(chainId: network.chain_id)
        guard let token = await EMWalletController.getTokenInfo(chain, token: self.textContract.text ?? "") else{
            AnimationManager.shared.removeAnimaition(self.view)
            return nil
        }
        AnimationManager.shared.removeAnimaition(self.view)
        self.textDecimal.text = FS(token.decimals)
        self.textSymbol.text = FS(token.symbol)
        return token
    }
    
    override func onRightAction() {
        Task{
            guard let token = await getTokenInfo() else{
                return
            }
            guard let network = EMNetworkModel.getNetwork() else{
                return
            }
            let tokens = await EMWalletController.searchToken(network.chain_id, name: FS(token.address.address))
            var isAdd = false
            tokens.forEach { model in
                if model.contract.lowercased() == FS(token.address.address).lowercased(){
                    EMTableToken.insert(model)
                    NotificationCenter.default.post(name: kNotifyRefreshWallet, object: nil)
                    self.popPage()
                    isAdd = true
                    return
                }
            }
            if isAdd{
                return
            }
            let tokenModel = EMTokenModel.create(token, chainID: network.chain_id)
            EMTableToken.insert(tokenModel)
            NotificationCenter.default.post(name: kNotifyAddToken, object: nil)
            self.popPage()
        }
    }
}
