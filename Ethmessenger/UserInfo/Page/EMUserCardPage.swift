// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionUIKit
import Curve25519Kit

class EMUserCardPage: BaseVC ,EMHideNavigationBarProtocol {

    var userInfo : Profile?
    var emUserInfo : EMCommunityUserEntity?
    let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: Screen_width, height: Screen_height-safeBottomH-72.w))
    init(userInfo : Profile,emUserInfo : EMCommunityUserEntity){
        self.userInfo = userInfo
        self.emUserInfo = emUserInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func layoutUI() {
        self.view.backgroundColor =  UIColor.white
        scrollView.backgroundColor = UIColor.white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset = UIEdgeInsets(top: -statusBarH, leading: 0, bottom: 0, trailing: 0)
        self.view.addSubview(scrollView)
        
        self.view.addSubview(navView)
        navView.snp.makeConstraints { make in
            make.left.right.top.equalTo(self.view)
            make.height.equalTo(navHeight)
        }
        
        let topBG = UIImageView(image: UIImage(named: "icon_user_card_top_bg"))
        scrollView.addSubview(topBG)
        topBG.snp.makeConstraints { make in
            make.left.right.equalTo(self.view)
            make.top.equalToSuperview()
        }
        
        scrollView.addSubview(self.contentView)
        self.contentView.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.width.equalTo(321.w)
            make.top.equalTo(topBG.snp.bottom).offset(-25.w)
            make.bottom.equalToSuperview().offset(-20.w)
        }
        
        self.contentView.superview?.layoutIfNeeded()
        
        let contentBg = UIView(UIColor(hex: "fbfbfb"))
        contentBg.frame = self.contentView.bounds
        if let image = self.getGaussianBlurViewImage(view: contentBg) {
            self.contentView.backgroundColor = UIColor.clear
            let bg = UIImageView(image: image)
            bg.alpha = 0.6
            bg.frame = self.contentView.bounds
            self.contentView.insertSubview(bg, at: 0)
        }
        
        let iconHead = UIImageView()
        iconHead.dealBorderLayer(corner: 48.w, bordercolor: .white, borderwidth: 2)
        iconHead.sd_setImage(with: URL(string: FS(self.emUserInfo?.Avatar)), placeholderImage: UIImage(named: "icon_community_default"))
        scrollView.addSubview(iconHead)
        iconHead.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.contentView.snp.top)
            make.size.equalTo(CGSize(width: 96.w, height: 96.w))
        }
        
        self.view.addSubview(btnView)
        btnView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-safeBottomH)
            make.height.equalTo(72.w)
        }
    }
    
    

    lazy var navView : UIView = {
        let view = UIView()
        let nav = UIView()
        view.addSubview(nav)
        nav.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(navigationBarHeight)
        }
        
        let backBtn = UIButton(image: UIImage(named: "icon_back"))
        backBtn.addTarget(self, action: #selector(popPage), for: .touchUpInside)
        nav.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(52.w)
        }
        
        let name = UILabel(font: UIFont.Bold(size: 16),color: .black,text: LocalCard.localized())
        nav.addSubview(name)
        name.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let backScan = UIButton(image: UIImage(named: "icon_user_scan"))
        backScan.addTarget(self, action: #selector(scan), for: .touchUpInside)
        nav.addSubview(backScan)
        backScan.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(55.w)
        }
        
        return view
    }()

    lazy var contentView : UIView = {
        let view = UIView(UIColor(hex: "fbfbfb",alpha: 0.6))
        view.dealBorderLayer(corner: 27.w, bordercolor: UIColor(hex: "f6f6f6"))
        let labName = UILabel(font: UIFont.Bold(size: 22),textColor: .black,text: self.emUserInfo?.Nickname)
        view.addSubview(labName)
        labName.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(47.w)
        }
        
        let followingView = self.createNumItem(FS(self.emUserInfo?.FollowCount), lab: LocalFollowing.localized())
        view.addSubview(followingView)
        followingView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(44.w)
            make.top.equalTo(labName.snp.bottom).offset(14.w)
            make.height.equalTo(25.w)
        }
        
        let followerView = self.createNumItem(FS(self.emUserInfo?.FansCount), lab: LocalFollower.localized())
        view.addSubview(followerView)
        followerView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-44.w)
            make.centerY.equalTo(followingView)
            make.height.equalTo(25.w)
        }
        
        let qrcodeView = UIView()
        qrcodeView.dealBorderLayer(corner: 4.w, bordercolor: .black, borderwidth: 1)
        view.addSubview(qrcodeView)
        qrcodeView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(followerView.snp.bottom).offset(24.w)
            make.size.equalTo(CGSize(width: 116.w, height: 116.w))
        }
        
        let qrCodeImageView = UIImageView(
            image: QRCode.generate(for: getUserHexEncodedPublicKey(), hasBackground: false)
                .withRenderingMode(.alwaysTemplate)
        )
        qrCodeImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        qrCodeImageView.tintColor = .black
        qrcodeView.addSubview(qrCodeImageView)
        qrCodeImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 7.w, leading: 7.w, bottom: 7.w, trailing: 7.w))
        }
        
        let labTips = UILabel(font: UIFont.Regular(size: 12),color: UIColor(hex: "A2A2A2"),text: LocalScanTips.localized())
        view.addSubview(labTips)
        labTips.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(qrcodeView.snp.bottom).offset(16.w)
        }
        
        let labSessionIdTitle = UILabel(font: UIFont.Regular(size: 12),color: .black,text: "Session ID")
        view.addSubview(labSessionIdTitle)
        labSessionIdTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.top.equalTo(labTips.snp.bottom).offset(16.w)
        }
        
        let labSessionId = UILabel(font: UIFont.Regular(size: 12),color: .black,text: self.userInfo?.id)
        labSessionId.numberOfLines = 0
        view.addSubview(labSessionId)
        labSessionId.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20.w)
            make.right.equalToSuperview().offset(-20.w)
            make.top.equalTo(labSessionIdTitle.snp.bottom).offset(6.w)
        }
        
        let btnCopy = UIButton(title: LocalCopy.localized(),font: UIFont.Regular(size: 12),color: .black)
        btnCopy.dealBorderLayer(corner: 20.w, bordercolor: .black, borderwidth: 1)
        view.addSubview(btnCopy)
        btnCopy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(labSessionId.snp.bottom).offset(20.w)
            make.bottom.equalToSuperview().offset(-38.w)
            make.size.equalTo(CGSize(width: 130.w, height: 40.w))
        }
        
        return view
    }()
    
    func createNumItem(_ num : String,lab : String) -> UIView{
        let view = UIView()
        let labNum = UILabel(font: UIFont.Medium(size: 14),textColor: .black,text: num)
        view.addSubview(labNum)
        labNum.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        let labContent = UILabel(font: UIFont.Medium(size: 12),color: UIColor(hex: "91979D"),text: lab)
        view.addSubview(labContent)
        labContent.snp.makeConstraints { make in
            make.centerY.right.equalToSuperview()
            make.left.equalTo(labNum.snp.right).offset(8.w)
        }
        return view
    }
    
    lazy var btnView : UIView = {
        let view = UIView()
        let btnSave = UIButton(title: "context_menu_save".localized(),font: UIFont.Regular(size: 14),color: .black,image: UIImage(named: "icon_user_save"))
        btnSave.addTarget(self, action: #selector(save), for: .touchUpInside)
        view.addSubview(btnSave)
        btnSave.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        let btnShare = UIButton(title: "share".localized(),font: UIFont.Regular(size: 14),color: .black,image: UIImage(named: "icon_user_share"))
        btnShare.addTarget(self, action: #selector(share), for: .touchUpInside)
        view.addSubview(btnShare)
        btnShare.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        let line = UIView(UIColor.init(hex: "F2F2F2"))
        view.addSubview(line)
        line.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 1, height: 15.w))
        }
        return view
    }()
    
}

extension EMUserCardPage{
    @objc func scan(){
        let message = "vc_qr_code_view_scan_qr_code_explanation".localized()
        let result = ScanQRCodeWrapperVC(message: message)
        result.delegate = self
        self.present(result, animated: true)
    }
    
    @objc func save(){
        if canPhotoLibary() == false {
            return
        }
        if let image = self.getScreenViewImage(view: self.scrollView) {
            self.saveImage(image: image)
        }
    }
    
    @objc func share(){
        if let image = self.getScreenViewImage(view: self.scrollView) {
            EMShareManager.shareToPaltm(title: "", image: image, urlStr: "")
        }
    }
}

extension EMUserCardPage : QRScannerDelegate{
    func controller(_ controller: QRCodeScanningViewController, didDetectQRCodeWith string: String) {
        let hexEncodedPublicKey = string
        Thread.safe_main {
            self.startNewPrivateChatIfPossible(with: hexEncodedPublicKey)
        }
        
    }
    
    fileprivate func startNewPrivateChatIfPossible(with hexEncodedPublicKey: String) {
        if !ECKeyPair.isValidHexEncodedPublicKey(candidate: hexEncodedPublicKey) {
            let modal: ConfirmationModal = ConfirmationModal(
                targetView: self.view,
                info: ConfirmationModal.Info(
                    title: "invalid_Ethmessenger_id".localized(),
                    body: .text("INVALID_Ethmessenger_ID_MESSAGE".localized()),
                    cancelTitle: "BUTTON_OK".localized(),
                    cancelStyle: .alert_text
                )
            )
            self.present(modal, animated: true)
        }
        else {
            let maybeThread: SessionThread? = Storage.shared.write { db in
                try SessionThread.fetchOrCreate(db, id: hexEncodedPublicKey, variant: .contact)
            }
            
            guard maybeThread != nil else { return }
            
            self.dismiss(animated: false, completion: nil)
            SessionApp.presentConversation(for: hexEncodedPublicKey, action: .compose, animated: false,currentVC: self)
        }
    }
}
