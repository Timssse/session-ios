// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import BigInt

class EMTransferPage: BaseVC {
    var costFeeModel : EMCostFeeModel?
    var token : EMTokenModel!
    init(token:EMTokenModel,receiveAddress : String = ""){
        self.token = token
        super.init(nibName: nil, bundle: nil)
        self.textReviceAddress.text = receiveAddress
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func layoutUI() {
        self.title = LocalRepost.localized()
        let contentView = UIView(.wallet_bg)
        contentView.dealCorner(type: .topLeftRight, corner: 20.w)
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let labAssetTitle = UILabel.init(font: UIFont.Medium(size: 16),textColor: .textPrimary,text: LocalAsset.localized())
        contentView.addSubview(labAssetTitle)
        labAssetTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.top.equalToSuperview().offset(33.w)
        }
        
        contentView.addSubview(tokenView)
        tokenView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview().offset(-20.w)
            make.top.equalTo(labAssetTitle.snp.bottom).offset(15.w)
        }
        
        let labReceiverTitle = UILabel.init(font: UIFont.Medium(size: 16),textColor: .textPrimary,text: LocalReceive.localized())
        contentView.addSubview(labReceiverTitle)
        labReceiverTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.top.equalTo(tokenView.snp.bottom).offset(15.w)
        }
        
        contentView.addSubview(self.textReviceAddress)
        textReviceAddress.snp.makeConstraints { make in
            make.left.right.equalTo(tokenView)
            make.top.equalTo(labReceiverTitle.snp.bottom).offset(15.w)
            make.height.equalTo(58.w)
        }
        
        textReviceAddress.addSubview(self.btnScan)
        btnScan.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.width.equalTo(56.w)
        }
        
        let labAmountTitle = UILabel.init(font: UIFont.Medium(size: 16),textColor: .textPrimary,text: LocalAmount.localized())
        contentView.addSubview(labAmountTitle)
        labAmountTitle.snp.makeConstraints { make in
            make.left.equalTo(textReviceAddress)
            make.top.equalTo(self.textReviceAddress.snp.bottom).offset(15.w)
        }
        
        contentView.addSubview(self.labAmount)
        self.labAmount.snp.makeConstraints { make in
            make.right.equalTo(textReviceAddress)
            make.centerY.equalTo(labAmountTitle)
        }
        
        
        contentView.addSubview(self.textSendNum)
        self.textSendNum.snp.makeConstraints { make in
            make.left.right.equalTo(tokenView)
            make.top.equalTo(labAmountTitle.snp.bottom).offset(15.w)
            make.height.equalTo(58.w)
        }
        
        let btnAll = UIButton.init(title: LocalAll.localized(),font: UIFont.Medium(size: 13),color: .Color_91979D_616569)
        btnAll.addTarget(self, action: #selector(onclickAll), for: .touchUpInside)
        btnAll.dealLayer(corner: 10.w)
        contentView.addSubview(btnAll)
        btnAll.snp.makeConstraints { make in
            make.right.equalTo(self.textSendNum).offset(-10.w)
            make.centerY.equalTo(self.textSendNum)
            make.size.equalTo(CGSize(width: 77.w, height: 42.w))
        }
        
        
        let btnNext = UIButton.init(submitTitle: LocalConfirm.localized())
        btnNext.addTarget(self, action: #selector(onclickNext), for: .touchUpInside)
        btnNext.dealLayer(corner: 10)
        self.view.addSubview(btnNext)
        btnNext.snp.makeConstraints { make in
            make.left.right.equalTo(tokenView)
            make.bottom.equalToSuperview().offset(-(safeBottomH))
            make.height.equalTo(41.w)
        }
        
    }
    
    
    lazy var tokenView : EMTransferTokenView = {
        let view = EMTransferTokenView()
        view.token = self.token
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeToken)))
        return view
    }()
    
    lazy var textReviceAddress : UITextField = {
        let text = UITextField.init(LocalInputReviceWalletAddress.localized(),font: UIFont.Medium(size: 13),textColor: .textPrimary)
        text.dealBorderLayer(corner: 14.w, bordercolor: .line, borderwidth: 1)
        text.addLeftView(20,width: 17.w)
        text.delegate = self
        return text
    }()
    
    
    lazy var btnScan : UIButton = {
        let btn = UIButton.init(type: .system,image: UIImage(named: "icon_user_scan"),tintColor: .Color_91979D_616569)
        btn.addTarget(self, action: #selector(onclickScan), for: .touchUpInside)
        return btn
    }()
    
    lazy var labAmount : UILabel = {
        let lab = UILabel.init(font:UIFont.Medium(size: 16),textColor: .textPrimary,text: token.balance)
        lab.isUserInteractionEnabled = true
        return lab
    }()
    
    lazy var textSendNum : UITextField = {
        let text = UITextField.init(LocalInputReviceWalletAddress.localized(),font: UIFont.Medium(size: 13),textColor: .textPrimary)
        text.dealBorderLayer(corner: 14.w, bordercolor: .line, borderwidth: 1)
        text.addLeftView(20,width: 17.w)
        text.delegate = self
        text.keyboardType = .numbersAndPunctuation
        return text
    }()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension EMTransferPage:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension EMTransferPage{
    @objc func changeToken(){
        EMAlert.alert(.selectToken)?.confirmAction({ model in
            guard let token = model as? EMTokenModel else{
                return
            }
            self.token = token
            self.tokenView.token = token
        }).popup()
    }
    
    @objc func onclickScan(){
        let vc = EMScanViewController()
        vc.okayBlock = { [weak self] (_, code) in//扫描地址
            let address = code.split(separator: ":").last
            self?.textReviceAddress.text = FS(address)
        }
        vc.modalPresentationStyle = .overFullScreen
        UIUtil.visibleVC()?.present(vc, animated: true, completion: nil)
    }
    
    override func onRightAction() {
//        let vc = QQScanViewController()
//        vc.okayBlock = { [weak self] (_, code) in//扫描地址
//            let address = code.split(separator: ":")
//            self?.textReviceAddress.text =  FS(address.last)
//            self?.getGasLimit()
//        }
//        vc.modalPresentationStyle = .overFullScreen
//        present(vc, animated: true, completion: nil)
    }
    
    @objc func onclickAll() {
        if self.token.contract == "" {
            if costFeeModel == nil{
                Task{
                    AnimationManager.shared.setAnimation(self.view)
                    costFeeModel = await getFeedRequest()
                    AnimationManager.shared.removeAnimaition(self.view)
                    self.onclickAll()
                }
                return
            }
            let fee = self.costFeeModel!.getGasFee()
            if token.balance.toDouble() < fee.toDouble() {
                //余额小于矿工费
                Toast.toast(hit: LocalLackFee.localized())
                return
            }
            self.textSendNum.text = token.balance.reduction(numberString: fee)
            return
        }
        self.textSendNum.text = FS(token.balance).toNumber8PointFormatter()
    }
    
    @objc func onclickNext() {
        self.view.endEditing(true)
        guard let reviceAddress = textReviceAddress.text ,reviceAddress.count > 0  else {
            Toast.toast(hit: LocalPleaseInputRightAcceptAddress.localized())
            return
        }
        guard let sendNum = textSendNum.text ,sendNum.count > 0  else {
            Toast.toast(hit: LocalPleaseInputMoney.localized())
            return
        }
    
        if costFeeModel == nil{
            Task{
                AnimationManager.shared.setAnimation(self.view)
                costFeeModel = await getFeedRequest()
                AnimationManager.shared.removeAnimaition(self.view)
                self.onclickNext()
            }
            return
        }
        //比较余额
        let tokenBalance = self.token.balance.toDouble()
        guard sendNum.toDouble() <= tokenBalance else {
            Toast.toast(hit: LocalLackBalance.localized())
            return
        }
        //比较矿工费
        let gasFee = costFeeModel!.getGasFee()
        if token.isMainNetwork == true {
            let value = tokenBalance - gasFee.toDouble()
            if value < sendNum.toDouble() {
                Toast.toast(hit: LocalLackFee.localized())
                return
            }
            self.showDetail()
        }else{
            guard let mainToken = EMTableToken.selectMainTokenWithChainId(self.token.chain_id) else{
                return
            }
            let balance = mainToken.balance.toDouble()
            guard  balance >=  gasFee.toDouble()  else{
                Toast.toast(hit: LocalLackFee.localized())
                return
            }
            self.showDetail()
        }
    }
    
    func showDetail()  {
        self.view.endEditing(true)
        EMPayforeDetailView
            .show(num: FS(textSendNum.text), receiver: FS(self.textReviceAddress.text), gas: self.costFeeModel!, token: self.token)
            .confirmAction {
                EMAlert.alert(.password)?.confirmAction {[weak self] _ in
                    self?.getBalaceRequest()
                }.popup()
        }
    }
}

//发送
extension EMTransferPage{
    
    func getFeedRequest() async -> EMCostFeeModel{
        let gasPrice = await EMWalletController.getGasPrice(self.token.chain_id)
        let gasLimit = await EMWalletController.getGasLimit(transNum: FS(self.textSendNum.text), token: self.token,toAddress: FS(self.textReviceAddress.text),gasPrice: gasPrice)
        return EMCostFeeModel(gasPrice: gasPrice, gasLimit: gasLimit)
    }
    
    func getBalaceRequest() {
        Task{
            AnimationManager.shared.setAnimation(self.view)
            await self.token.getBalance()
            AnimationManager.shared.removeAnimaition(self.view)
            let num = self.token.balance.toDouble()
            guard  let input = self.textSendNum.text else{
                Toast.toast(hit: LocalLackBalance.localized())
                return
            }
            let inputNum = input.toDouble()
            guard inputNum <= num else{
                Toast.toast(hit: LocalLackBalance.localized())
                return
            }
            EMAlert.alert(.password)?.confirmAction {[weak self] _ in
                self?.sendCoinToRequest(num: input)
            }.popup()
        }
        
    }
    

    
    func sendCoinToRequest(num: String) {
        
        guard let fee = self.costFeeModel else{
            return
        }
        AnimationManager.shared.setAnimation(self.view)
        let  addressTo = FS(textReviceAddress.text)
        Task{
            do{
                let relust = try await EMWalletController.send(toAddress: addressTo, num: num, token: token, gas: fee)
                if relust != nil{
                    
                }
            }catch{
                Toast.toast(hit: error.localizedDescription)
            }
            
            
        }
        
//        FWRPCApi.transferReuqest(addressTo: addressTo,
//                                  model: model,
//                                  coinModel: self.coinModel,
//                                 fee: fee,
//                                  transnum: FS(num)) { (item) in
//            Thread.safe_main {
//                if let vc = R.storyboard.home.fwTransfinishVC() {
//                    vc.addressTo = addressTo
//                    vc.hashstr = FS(item?.hash)
//                    vc.coinTypeNum = FS(num) + self.coinModel.symbol
//                    vc.coinnum = FS(num)
//                    vc.coinType = self.coinModel.assets_name
//                    vc.coinModel = self.coinModel
//                    if let item = item {
//                        vc.tradeModel = item
//                    }
//                    vc.model = self.model
//                    self.xPush(controller: vc)
//                }
//                FWTableTransferRecord.insert(FWTransferRecordModel(address: addressTo, createDate: FS(Date().timeIntervalSince1970), network: self.model.network))
//            }
//        } failed: { (error) in
//
//        }
    }
    
   
}

