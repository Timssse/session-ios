// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMCommunityForwardView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.dealLayer(corner: 4.w)
        self.themeBackgroundColor = .forwardingBGColor
        self.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(15.w)
            make.size.equalTo(CGSize(width: 28.w, height: 28.w))
        }
        
        self.addSubview(labName)
        labName.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(6.w)
            make.centerY.equalTo(icon)
        }
        
        self.addSubview(labTime)
        labTime.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-13.w)
            make.centerY.equalTo(labName)
        }
    
        self.addSubview(labContent)
        labContent.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-13.w)
            make.left.equalToSuperview().offset(15.w)
            make.top.equalTo(icon.snp.bottom).offset(6.w)
        }
        
        self.addSubview(imagesCollectionView)
        imagesCollectionView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-45.w)
            make.left.equalToSuperview().offset(15.w)
            make.top.equalTo(labContent.snp.bottom).offset(5.w)
            make.height.equalTo(0)
            make.bottom.equalToSuperview().offset(-17.w)
        }
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var icon : UIImageView = {
        let icon = UIImageView()
        icon.dealLayer(corner: 14.w)
        return icon
    }()
    
    lazy var labName : UILabel = {
        let lab = UILabel(font: UIFont.Bold(size: 15),textColor: .textPrimary)
        return lab
    }()
    
    lazy var labTime : UILabel = {
        let lab = UILabel(font: UIFont.Medium(size: 12),textColor: .textGary1)
        return lab
    }()
    
    lazy var labContent : UILabel = {
        let lab = UILabel(font: UIFont.Regular(size: 13),textColor: .textPrimary)
        lab.numberOfLines = 3
        return lab
    }()
    
    lazy var imagesCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0;
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(EMCommunityImageItem.self, forCellWithReuseIdentifier: "EMCommunityImageItem")
        return collectionView
    }()
    
    var model : EMCommunityHomeListEntity?{
        didSet{
            icon.sd_setImage(with: URL(string: model?.UserInfo?.Avatar ?? ""),placeholderImage: UIImage(named: ""))
            labName.text = model?.UserInfo?.Nickname
            labTime.text = model?.CreatedAt.showTime
            labContent.text = model?.Content
            let imageHeight = model!.images.count > 0 ? 66.w : 0
            
            imagesCollectionView.snp.updateConstraints { make in
                make.height.equalTo(imageHeight)
            }
            imagesCollectionView.reloadData()
        }
    }
    
    var viewHeight : CGFloat{
        self.superview?.layoutIfNeeded()
        return self.frame.height
    }
    
    @objc func onclickMore(){
        
    }
}

extension EMCommunityForwardView : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.model?.images.count ?? 0 > 3 ? 3 : self.model?.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EMCommunityImageItem", for: indexPath) as! EMCommunityImageItem
        cell.model = self.model!.images[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 60.w, height: 60.w)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
