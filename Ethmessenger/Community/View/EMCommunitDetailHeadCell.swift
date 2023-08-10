// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMCommunitDetailHeadCell: BaseTableViewCell {
    
    override func layoutUI() {
        
        self.contentView.themeBackgroundColor = .conversationButton_background
        self.contentView.addSubview(publisherView)
        publisherView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15.w)
            make.left.equalToSuperview().offset(25.w)
            make.right.equalToSuperview().offset(-25.w)
        }
        
        self.contentView.addSubview(labContent)
        labContent.snp.makeConstraints { make in
            make.left.equalTo(publisherView)
            make.right.equalToSuperview().offset(-25.w)
            make.top.equalTo(publisherView.snp.bottom).offset(5.w)
        }
        
        self.contentView.addSubview(imagesCollectionView)
        imagesCollectionView.snp.makeConstraints { make in
            make.left.equalTo(publisherView)
            make.right.equalToSuperview().offset(-25.w)
            make.top.equalTo(labContent.snp.bottom).offset(5.w)
            make.height.equalTo(0)
        }
        
        self.contentView.addSubview(forwordView)
        forwordView.snp.makeConstraints { make in
            make.left.right.equalTo(imagesCollectionView)
            make.top.equalTo(imagesCollectionView.snp.bottom).offset(10.w)
        }
        
        self.contentView.addSubview(toolView)
        toolView.snp.makeConstraints { make in
            make.left.right.equalTo(imagesCollectionView)
            make.top.equalTo(imagesCollectionView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        let line = UIView(.line)
        line.dealLayer(corner: 1.w)
        self.contentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.equalTo(imagesCollectionView)
            make.bottom.equalToSuperview()
            make.height.equalTo(3.w)
        }
        
    }

    lazy var publisherView : EMCommunitPublisherView = {
        let view = EMCommunitPublisherView()
        return view
    }()
    
    lazy var labContent : UILabel = {
        let lab = UILabel(font: UIFont.Medium(size: 14),textColor: .textPrimary)
        lab.numberOfLines = 0
        return lab
    }()
    
    lazy var imagesCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 8.w;
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(EMCommunityImageItem.self, forCellWithReuseIdentifier: "EMCommunityImageItem")
        return collectionView
    }()
    
    lazy var forwordView : EMCommunityForwardView = {
        let view = EMCommunityForwardView()
        return view
    }()
    
    lazy var toolView : EMCommunityToolView = {
        let view = EMCommunityToolView()
        return view
    }()
    
    
    var model : EMCommunityHomeListEntity!{
        didSet{
            self.publisherView.model = model
            labContent.text = model.Content
            labContent.setMiniLineHeight()
            let imageHeight = ceil(CGFloat((model.images.count > 9 ? 9 : model.images.count))/3.0) * 112.w
            imagesCollectionView.snp.updateConstraints { make in
                make.height.equalTo(imageHeight)
            }
            toolView.model = model
            if model.OriginTweet != nil{
                forwordView.isHidden = false
                forwordView.model = model.OriginTweet!
                toolView.snp.updateConstraints { make in
                    make.top.equalTo(imagesCollectionView.snp.bottom).offset(20.w + forwordView.viewHeight)
                }
            }else{
                forwordView.isHidden = true
                toolView.snp.updateConstraints { make in
                    make.top.equalTo(imagesCollectionView.snp.bottom).offset(10.w)
                }
            }
            imagesCollectionView.reloadData()
        }
    }
}


extension EMCommunitDetailHeadCell : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.model.images.count > 9 ? 9 : self.model.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EMCommunityImageItem", for: indexPath) as! EMCommunityImageItem
        cell.model = self.model.images[indexPath.row]
        if indexPath.row == 8 && self.model.images.count > 9{
            cell.numView.isHidden = false
            cell.labCount.text = "+\(self.model.images.count-9)"
        }else{
            cell.numView.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 104.w, height: 104.w)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIUtil.visibleVC()?.isEditing = true
        EMPhotoLookUtilities.showImages(images: self.model.images, selectIndex: indexPath.row)
    }
}
