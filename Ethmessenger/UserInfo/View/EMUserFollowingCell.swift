// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMUserFollowingCell: BaseTableViewCell {
    
    var update:((EMCommunityUserEntity)->())?
    
    let iconHead = UIImageView()
    let labName = UILabel(font: UIFont.Bold(size: 15),textColor: .textPrimary)
    let labAddress = UILabel(font: UIFont.Regular(size: 12),textColor: .color_91979D)
    let btnStatus = UIButton(font:UIFont.Regular(size: 13.w))
    
    override func layoutUI() {
        iconHead.dealLayer(corner: 26.w)
        self.contentView.addSubview(iconHead)
        iconHead.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25.w)
            make.top.equalToSuperview().offset(15.w)
            make.bottom.equalToSuperview().offset(-15.w)
            make.size.equalTo(CGSize(width: 52.w, height: 52.w))
        }
        
        self.contentView.addSubview(labName)
        labName.snp.makeConstraints { make in
            make.left.equalTo(iconHead.snp.right).offset(15.w)
            make.top.equalTo(iconHead).offset(3.w)
        }
        
        self.contentView.addSubview(labAddress)
        labAddress.snp.makeConstraints { make in
            make.left.equalTo(iconHead.snp.right).offset(15.w)
            make.bottom.equalTo(iconHead).offset(-3.w)
        }
        
        
        btnStatus.addTarget(self, action: #selector(onclickFans), for: .touchUpInside)
        btnStatus.dealBorderLayer(corner: 6.w, bordercolor: .line, borderwidth: 1)
        self.contentView.addSubview(btnStatus)
        btnStatus.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-25.w)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 94.w, height: 34.w))
        }
    }
    
    ///关注
    var follow : EMCommunityUserEntity?{
        didSet{
            iconHead.sd_setImage(with: URL(string: FS(follow?.Avatar)), placeholderImage: icon_default)
            labName.text = follow?.Nickname
            labAddress.text = FS(follow?.UserAddress).showAddress(6)
            btnStatus.setTitle(follow?.IsFollow == true ? LocalUnFollowing.localized() : LocalFollowing.localized(), for: .normal)
            btnStatus.setThemeTitleColor(.alertTextColor, for: .normal)
        }
    }
    
    ///粉丝
    var fans : EMCommunityUserEntity?{
        didSet{
            iconHead.sd_setImage(with: URL(string: FS(fans?.Avatar)), placeholderImage: icon_default)
            labName.text = fans?.Nickname
            labAddress.text = FS(fans?.UserAddress).showAddress(6)
            btnStatus.setTitle(fans?.IsFollow == true ? LocalFriend.localized() : LocalFollowing.localized(), for: .normal)
            btnStatus.setThemeTitleColor(.alertTextColor, for: .normal)
        }
    }
    
    @objc func onclickFans(){
        if fans != nil{
            
            Task{
                var model = fans!
                let relust = await EMUserController.follow(model.IsFollow, address: model.UserAddress)
                if relust{
                    model.IsFollow = !model.IsFollow
                    self.fans = model
                    update?(model)
                }
            }
            return
        }
        if follow != nil{
            Task{
                var model = follow!
                let relust = await EMUserController.follow(model.IsFollow, address: model.UserAddress)
                if relust{
                    model.IsFollow = !model.IsFollow
                    self.follow = model
                    update?(model)
                }
            }
            return
        }
    }
    
    
}
