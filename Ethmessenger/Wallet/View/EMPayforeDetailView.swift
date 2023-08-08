// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import Web3Core

class EMPayforeDetailView: UIView {
    
    var nextBlock : (()->())?
    var cancelBlock : (()->())?
    let backView = UIView(UIColor.white)
    convenience init(num:String,receiver : String,gas : EMCostFeeModel,token: EMTokenModel) {
        self.init()
        self.createUI(num: num, receiver: receiver, gas: gas,token: token)
    }
    
    func createUI(num:String,receiver : String,gas : EMCostFeeModel,token: EMTokenModel){
        
        let bgView = UIView(UIColor.init(white: 0, alpha: 0.3))
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickCancel)))
        self.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backView.dealCorner(type: .topLeftRight, corner: 20.w)
        self.addSubview(backView)
        backView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
        
        let labTitle = UILabel.init(font: UIFont.Bold(size: 17),textColor: .color_616569,text: LocalTransferDetails.localized())
        backView.addSubview(labTitle)
        labTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalToSuperview().offset(26.w)
        }
        
        let labAmout = UILabel.init(font: UIFont.Medium(size: 22),textColor: .textPrimary,text: num)
        backView.addSubview(labAmout)
        labAmout.snp.makeConstraints { make in
            make.left.equalTo(labTitle)
            make.top.equalTo(labTitle.snp.bottom).offset(14.w)
        }
        
        let labSymbol = UILabel.init(font: UIFont.Medium(size: 13),textColor: .color_616569,text: token.symbol)
        backView.addSubview(labAmout)
        labAmout.snp.makeConstraints { make in
            make.left.equalTo(labTitle)
            make.centerY.equalTo(labAmout)
        }
        
        let line = UIView(.line)
        backView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.equalTo(labTitle)
            make.right.equalToSuperview().offset(-25.w)
            make.top.equalTo(labAmout.snp.bottom).offset(30.w)
            make.height.equalTo(1)
        }
        
        let labTypeTitle = UILabel.init(font: UIFont.Bold(size: 15),textColor: .color_616569,text: LocalType.localized())
        backView.addSubview(labTypeTitle)
        labTypeTitle.snp.makeConstraints { make in
            make.left.equalTo(labTitle)
            make.top.equalTo(line.snp.bottom).offset(21.w)
        }
        
        let labType = UILabel.init(font: UIFont.Bold(size: 15),textColor: .color_91979D,text: LocalType.localized())
        backView.addSubview(labType)
        labType.snp.makeConstraints { make in
            make.right.equalTo(line)
            make.centerY.equalTo(labType)
        }
        
        let labReceiverTitle = UILabel.init(font: UIFont.Bold(size: 15),textColor: .color_616569,text: LocalReceive.localized())
        backView.addSubview(labReceiverTitle)
        labReceiverTitle.snp.makeConstraints { make in
            make.left.equalTo(labTitle)
            make.top.equalTo(labTypeTitle.snp.bottom).offset(20.w)
        }
        
        let labReceiver = UILabel.init(font: UIFont.Bold(size: 15),textColor: .color_91979D,text: receiver)
        backView.addSubview(labReceiver)
        labReceiver.snp.makeConstraints { make in
            make.right.equalTo(line)
            make.centerY.equalTo(labReceiverTitle)
        }
        
        let labGasTitle = UILabel.init(font: UIFont.Bold(size: 15),textColor: .color_616569,text: LocalGasFees.localized())
        backView.addSubview(labGasTitle)
        labGasTitle.snp.makeConstraints { make in
            make.left.equalTo(labTitle)
            make.top.equalTo(labReceiverTitle.snp.bottom).offset(20.w)
        }
        
        if let mainToken = EMTableToken.selectMainTokenWithChainId(token.chain_id){
            let labGas = UILabel.init(font: UIFont.Bold(size: 15),textColor: .color_91979D,text: gas.getGasFee() + mainToken.symbol)
            backView.addSubview(labGas)
            labGas.snp.makeConstraints { make in
                make.right.equalTo(line)
                make.centerY.equalTo(labGasTitle)
            }
        }
        
        let labGasDetail = UILabel.init(font: UIFont.Bold(size: 15),textColor: .color_91979D,text: "Gas Price（\(Utilities.formatToPrecision(gas.gasPrice,units: .gwei))）* Gas(\(FS(gas.gasLimit))")
        backView.addSubview(labGasDetail)
        labGasDetail.snp.makeConstraints { make in
            make.right.equalTo(line)
            make.top.equalTo(labGasTitle.snp.bottom).offset(20.w)
        }
        
        
        let btnConfirm = UIButton(submitTitle: LocalConfirm.localized())
        btnConfirm.addTarget(self, action: #selector(onclickConfirm), for: .touchUpInside)
        backView.addSubview(btnConfirm)
        btnConfirm.snp.makeConstraints { make in
            make.top.equalTo(labGasDetail.snp.bottom).offset(40.w)
            make.left.right.equalTo(line)
            make.height.equalTo(41.w)
            make.bottom.equalToSuperview().offset(-safeBottomH)
        }
    }
    
    @discardableResult
    class func show(num:String,receiver : String,gas : EMCostFeeModel,token: EMTokenModel) -> EMPayforeDetailView {
        let view = EMPayforeDetailView(num: num, receiver: receiver, gas: gas, token: token)
        topWindow()?.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        animationAddView(view: view.backView)
        return view
    }

    @discardableResult
    func confirmAction(_ action: @escaping () -> Void) -> EMPayforeDetailView {
        nextBlock = action
        return self
    }

    @discardableResult
    func cancelAction(_ action: @escaping () -> Void) -> EMPayforeDetailView {
        cancelBlock = action
        return self
    }
    
}

extension EMPayforeDetailView{
    @objc func onclickConfirm(){
        self.nextBlock?()
        animationRemoveview()
    }
    
    @objc func onclickCancel(){
        self.cancelBlock?()
        animationRemoveview()
    }
}
