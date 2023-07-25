// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import TZImagePickerController
class EMPublishPage: BaseVC {

    var forward : EMCommunityHomeListEntity?
    
    init(forward : EMCommunityHomeListEntity?){
        self.forward = forward
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func layoutUI() {
        self.view.themeBorderColor = .navBack
        let navView = UIView()
        self.view.addSubview(navView)
        navView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(navHeight)
        }
        
        let btnCancel = UIButton(type: .system,title: LocalCancel.localized(),font: UIFont.Regular(size: 13),tintColor: .textPrimary)
        btnCancel.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        navView.addSubview(btnCancel)
        btnCancel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalToSuperview().offset(statusBarH)
            make.height.equalTo(navigationBarHeight)
        }
        
        let btnPublish = UIButton(type: .system,title: LocalPublish.localized(),font: UIFont.Regular(size: 13),tintColor: .messageBubble_outgoingBackground)
        btnPublish.addTarget(self, action: #selector(onclickPublish), for: .touchUpInside)
        navView.addSubview(btnPublish)
        btnPublish.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-25.w)
            make.top.equalToSuperview().offset(statusBarH)
            make.height.equalTo(navigationBarHeight)
        }
        
        let contentView = UIView(.conversationButton_background)
        contentView.dealCorner(type: .topLeftRight, corner: 20.w)
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(navView.snp.bottom)
        }
        
        contentView.addSubview(self.imagesCollectionView)
        self.imagesCollectionView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.right.equalToSuperview().offset(-25.w)
            make.bottom.equalToSuperview()
            make.height.equalTo(95.w)
        }
        
        let line = UIView(.line)
        contentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.equalTo(self.imagesCollectionView)
            make.top.equalTo(self.imagesCollectionView.snp.bottom).offset(7.w)
            make.height.equalTo(1)
        }
        
        contentView.addSubview(labNum)
        
        if forward == nil{
            labNum.snp.makeConstraints { make in
                make.right.equalTo(self.imagesCollectionView)
                make.bottom.equalTo(self.imagesCollectionView.snp.top).offset(-9.w)
            }
        }else{
            let forwardView = EMCommunityForwardView()
            forwardView.model = self.forward
            contentView.addSubview(forwardView)
            forwardView.snp.makeConstraints { make in
                make.left.right.bottom.equalTo(self.imagesCollectionView)
            }
            labNum.snp.makeConstraints { make in
                make.right.equalTo(self.imagesCollectionView)
                make.bottom.equalTo(forwardView.snp.top).offset(-9.w)
            }
        }
        
        
        
        contentView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.right.equalToSuperview().offset(-25.w)
            make.top.equalToSuperview().offset(8.w)
            make.bottom.equalTo(self.labNum.snp.top)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillChangeFrameNotification(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    lazy var textView : UITextView = {
        let textView = UITextView("",font: UIFont.Regular(size: 13),textColor: .textPrimary)
        textView.delegate = self
        textView.contentInset = UIEdgeInsets(top: 20, leading: 0, bottom: 10.w, trailing: 0)
        textView.themeBackgroundColor = .conversationButton_background
        textView.addSubview(labPlaceholder)
        labPlaceholder.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(5)
            make.top.equalToSuperview().offset(9)
        }
        if forward != nil {
            return textView
        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Screen_width, height: 50.w))
        let btn = UIButton(type: .system,image: UIImage(named: "icon_community_photo"),tintColor: .iconColor)
        btn.addTarget(self, action: #selector(onclickPhoto), for: .touchUpInside)
        view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(80.w)
        }
        textView.inputAccessoryView = view
        
        
        
        return textView
    }()
    
    lazy var labPlaceholder : UILabel = UILabel(font: UIFont.Regular(size: 13),textColor: .textSecondary,text: LocalEnterDesc.localized())
    
    
    lazy var labNum : UILabel = UILabel(font: UIFont.Regular(size: 13),textColor: .textSecondary,text: "0/10000")
    
    lazy var imagesCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 8.w
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(EMCommunityImageItem.self, forCellWithReuseIdentifier: "EMCommunityImageItem")
        return collectionView
    }()
    
    var images : [UIImage] = []
    var uploadImages : [PHAsset] = []
}

extension EMPublishPage : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        self.labPlaceholder.isHidden = textView.text.count > 0
        labNum.text = "\(textView.text.count)/10000"
        
        if textView.text.count > 10000{
            textView.text = textView.text.prefix(10000) + ""
        }
        
    }
    
    @objc func deleteImage(_ sender : UIButton){
        images.remove(at: sender.tag)
        uploadImages.remove(at: sender.tag)
        self.imagesCollectionView.reloadData()
    }
    
    @objc func handleKeyboardWillChangeFrameNotification(_ notification: Notification) {
        let userInfo: [AnyHashable: Any] = (notification.userInfo ?? [:])
        let duration = ((userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0)
        let curveValue: Int = ((userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int) ?? Int(UIView.AnimationOptions.curveEaseInOut.rawValue))
        let options: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: UInt(curveValue << 16))
        let keyboardRect: CGRect = ((userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? CGRect.zero)
        let keyboardTop = (UIScreen.main.bounds.height - keyboardRect.minY)
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: options,
            animations: { [weak self] in
                self?.imagesCollectionView.snp.updateConstraints { make in
                    make.bottom.equalToSuperview().offset(-(keyboardTop) - 20.w)
                }
                self?.imagesCollectionView.superview?.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
    @objc func onclickPhoto(){
        let vc = TZImagePickerController.init(maxImagesCount: 9, delegate: self)!
        vc.modalPresentationStyle = .fullScreen
        vc.allowPickingMultipleVideo = true
        vc.selectedAssets = NSMutableArray(array: self.uploadImages)
        self.present(vc, animated: true)
    }
    
    @objc func onclickPublish(){
        AnimationManager.shared.setAnimation(self.view)
        Task{
            if await EMCommunityController.release(content:self.textView.text, files:self.uploadImages,forwardId:forward?.TwAddress){
                self.dismissVC()
                NotificationCenter.default.post(name: kNotifyRefreshCommunity, object: nil)
            }
            AnimationManager.shared.removeAnimaition(self.view)
        }
    }
}

extension EMPublishPage : TZImagePickerControllerDelegate{
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingVideo coverImage: UIImage!, sourceAssets asset: PHAsset!) {
        self.images = [coverImage]
        self.uploadImages = [asset]
        self.imagesCollectionView.reloadData()
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        self.images = photos
        self.uploadImages = (assets as? [PHAsset]) ?? []
        self.imagesCollectionView.reloadData()
    }
}

extension EMPublishPage : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EMCommunityImageItem", for: indexPath) as! EMCommunityImageItem
        cell.image = self.images[indexPath.row]
        cell.deleteBtn.tag = indexPath.row
        cell.deleteBtn.addTarget(self, action: #selector(deleteImage(_:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 80.w, height: 80.w)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    
}
