// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMCommunityImageItem: UICollectionViewCell {
    let icon = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        icon.contentMode = .scaleAspectFill
        icon.dealLayer(corner: 8.w)
        self.contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        icon.addSubview(numView)
        numView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.contentView.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.size.equalTo(CGSize(width: 32.w, height: 32.w))
        }
    }
    
    lazy var numView : UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        view.addSubview(labCount)
        labCount.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return view
    }()
    
    lazy var deleteBtn : UIButton = {
        let btn = UIButton(image: UIImage(named: "icon_community_delete"))
        btn.isHidden = true
        return btn
    }()
    
    lazy var labCount : UILabel = UILabel(font: UIFont.Medium(size: 16),textColor: .white)
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var model : EMCommunityFileEntity!{
        didSet{
            if (model.type == .image){
                icon.sd_setImage(with: URL(string: model.path), placeholderImage: icon_default)
            }
            if (model.type == .video){
                icon.image = icon_default
                Task{
                    if let image = await FileUtilities.getVideoThumbImage(videoPath: model.path){
                        icon.image = image
                    }
                }
            }
        }
    }
    
    var image : UIImage!{
        didSet{
            icon.image = image
            deleteBtn.isHidden = false
        }
    }
}
