// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMCommunityImageItem: UICollectionViewCell {
    let icon = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        icon.dealLayer(corner: 8.w)
        self.contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var model : EMCommunityFileEntity!{
        didSet{
            if (model.type == .image){
                icon.sd_setImage(with: URL(string: model.path), placeholderImage: UIImage(named: "icon_community_default"))
            }
            if (model.type == .video){
                icon.image = UIImage(named: "icon_community_default")
                Task{
                    if let image = await FileUtilities.getVideoThumbImage(videoPath: model.path){
                        icon.image = image
                    }
                }
            }
        }
    }
}
