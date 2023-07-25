// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMUserCommunitCell: BaseTableViewCell {
    
    override func layoutUI() {
        self.backgroundColor = .clear
        self.contentView.themeBackgroundColor = .user_communit_bg
        self.contentView.addSubview(labName)
        labName.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(36.w)
            make.top.equalToSuperview().offset(20.w)
        }
        
        self.contentView.addSubview(labTime)
        labTime.snp.makeConstraints { make in
            make.left.equalTo(labName)
            make.top.equalTo(labName.snp.bottom)
        }
        
        self.addSubview(btnMore)
        btnMore.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(22.w)
            make.centerY.equalTo(labName)
        }
        
        self.addSubview(circleView)
        circleView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(21.w)
            make.centerY.equalTo(labName)
            make.size.equalTo(CGSize(width: 8.w, height: 8.w))
        }
        
        self.addSubview(topLine)
        topLine.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalTo(circleView)
            make.bottom.equalTo(circleView.snp.top)
            make.width.equalTo(1)
        }
        
        self.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalTo(circleView)
            make.top.equalTo(circleView.snp.bottom)
            make.width.equalTo(1)
        }
        
        self.contentView.addSubview(labContent)
        labContent.snp.makeConstraints { make in
            make.left.equalTo(labName)
            make.right.equalToSuperview().offset(-25.w)
            make.top.equalTo(labTime.snp.bottom).offset(5.w)
        }
        
        self.contentView.addSubview(imagesCollectionView)
        imagesCollectionView.snp.makeConstraints { make in
            make.left.equalTo(labName)
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
            make.top.equalTo(imagesCollectionView.snp.bottom).offset(10.w)
            make.bottom.equalToSuperview().offset(-10.w)
        }
        
        let line = UIView(.line)
        self.contentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.equalTo(imagesCollectionView)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        let walletBottom = UIImageView(image: UIImage(named: "icon_user_wallet_bottom"))
        self.contentView.addSubview(walletBottom)
        walletBottom.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(17.w)
            make.right.equalToSuperview().offset(-17.w)
            make.top.equalToSuperview().offset(-8.w)
        }
        
    }

    let topLine = UIView(.line)
    let bottomLine = UIView(.line)
    lazy var circleView : UIView = {
        let view = UIView(UIColor.clear)
        view.dealBorderLayer(corner: 4.w, bordercolor: .textPrimary, borderwidth: 1)
        return view
    }()
    
    lazy var labName : UILabel = {
        let lab = UILabel(font: UIFont.Bold(size: 15),textColor: .textPrimary)
        return lab
    }()
    
    lazy var labTime : UILabel = {
        let lab = UILabel(font: UIFont.Medium(size: 12),textColor: .textGary1)
        return lab
    }()
    
    lazy var btnMore : UIButton = {
        let btn = UIButton(type: .system,image: UIImage(named: "icon_community_more"),tintColor: .setting_icon_icon)
        btn.addTarget(self, action: #selector(onclickMore(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var labContent : UILabel = {
        let lab = UILabel(font: UIFont.Regular(size: 13),textColor: .textPrimary)
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
            labName.text = model.UserInfo?.Nickname
            labTime.text = model.CreatedAt.showTime
            labContent.text = model.Content
            let imageHeight = ceil(CGFloat((model.images.count > 9 ? 9 : model.images.count))/3.0) * 106.w
            imagesCollectionView.snp.updateConstraints { make in
                make.height.equalTo(imageHeight)
            }
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
            toolView.model = model
            imagesCollectionView.reloadData()
        }
    }
    
    var isFirst : Bool = false{
        didSet{
            topLine.isHidden = isFirst
            let top = isFirst ? 0 : 20.w
            circleView.snp.updateConstraints { make in
                make.centerY.equalTo(labName).offset(top)
            }
        }
    }
    
    
    
    @objc func onclickMore(_ sender : UIButton){
        var frame = sender.convert(sender.bounds, to: UIUtil.getWindow()!)
        frame.origin.x -= 55.w
        frame.origin.y += 31.w
        frame.size = CGSize(width: 77.w, height: 35.w)
        EMCommunityMoreView.share.show(UIUtil.getWindow()!,contentFrame: frame)
        EMCommunityMoreView.share.reportBlock = {
            
        }
    }
}


extension EMUserCommunitCell : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
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
        return CGSize.init(width: 80.w, height: 80.w)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        EMPhotoLookUtilities.showImages(images: self.model.images, selectIndex: indexPath.row)
    }
}
