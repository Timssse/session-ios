

import swiftScan
import AssetsLibrary
import Photos
import UIKit
import Lottie

class EMScanViewController: LBXScanViewController {

    
    var okayBlock: ((EMScanViewController, String) -> Void)?
    
    let topBar = EMDiyTopBar()
    let l = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(topBar)
        self.setEmptyCircle()
        
        topBar.backBtn.setImage(UIImage(named: "NavBarBack"), for: .normal)
        topBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            } else {
                // Fallback on earlier versions
            }
        }
        topBar.backgroundColor = .clear
        topBar.titleLabel.font = UIFont.Medium(size: 16)
        topBar.titleLabel.text = LocalScan.localized()
        topBar.titleLabel.textColor = .white
        topBar.backBtn.addTarget(self, action: #selector(dismissClick), for: .touchUpInside)
        let btn = UIButton.init( image: UIImage(named: "scan_photo"))
        topBar.contentView.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        btn.addTarget(self, action: #selector(openPhotoAlbum), for: .touchUpInside)
        view.addSubview(l)
        l.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }
        //需要识别后的图像
        setNeedCodeImage(needCodeImg: false)
        //框向上移动10个像素
        scanStyle?.isNeedShowRetangle = false
        scanStyle?.colorAngle = UIColor.clear
        scanStyle?.color_NotRecoginitonArea = UIColor.clear
        scanStyle?.centerUpOffset = 0
        scanStyle?.anmiationStyle = .LineMove
        scanStyle?.animationImage = UIImage(named: "scan_line")
        scanStyle?.colorRetangleLine = .clear
    }
    
    //设置镂空
    private func setEmptyCircle(){
        let circleView = UIView()
        circleView.backgroundColor = UIColor.clear
        self.view.addSubview(circleView)
        circleView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(Screen_width - 120)
        }
        circleView.dealBorderLayer(corner: 20, bordercolor: .white, borderwidth: 3)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.bringSubviewToFront(topBar)
        view.bringSubviewToFront(l)
    }

    override func handleCodeResult(arrayResult: [LBXScanResult]) {
        guard let result = arrayResult.first?.strScanned else {return}
        dismiss(animated: true) {
            Thread.safe_main {
                self.okayBlock?(self,result)
            }
        }
    }
    
    @objc func dismissClick() {
        dismiss(animated: true, completion: nil)
    }
    
    override func startScan() {
        let hasCameraAccess = (AVCaptureDevice.authorizationStatus(for: .video) == .authorized) || (AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined)
        if hasCameraAccess{
            super.startScan()
            return
        }
        let alter = UIAlertController(title: LocalTips.localized(), message: LocalCameraNotPermission.localized(), preferredStyle: .alert)
        let action = UIAlertAction(title: LocalConfirm.localized(), style: .default) { (_) in
            self.lqc_jumpToSystemPrivacySetting()
            alter.dismiss(animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: LocalCancel.localized(), style: .default) { (_) in
            alter.dismiss(animated: true, completion: nil)
        }
        alter.addAction(cancel)
        alter.addAction(action)
        self.present(alter, animated: true, completion: nil)
    }
    
    override func openPhotoAlbum() {
        
        if canPhotoLibary() {
            super.openPhotoAlbum()
            return
        }
        let alter = UIAlertController(title: LocalTips.localized(), message: LocalAlbumNotPermission.localized(), preferredStyle: .alert)
        let action = UIAlertAction(title: LocalConfirm.localized(), style: .default) { (_) in
            self.lqc_jumpToSystemPrivacySetting()
            alter.dismiss(animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: LocalCancel.localized(), style: .default) { (_) in
            alter.dismiss(animated: true, completion: nil)
        }
        alter.addAction(cancel)
        alter.addAction(action)
        self.present(alter, animated: true, completion: nil)
    }
    
    func lqc_jumpToSystemPrivacySetting() {
        guard let appSetting = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if #available(iOS 10, *) {
            UIApplication.shared.open(appSetting, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(appSetting)
        }
    }
    
}
