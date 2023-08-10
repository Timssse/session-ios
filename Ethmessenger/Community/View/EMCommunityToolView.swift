// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMCommunityToolView: UIView {
    
    var likeBlock : (()->())?
//    var replyBlock : (()->())?
//    var forwardBlock : (()->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(btnLike)
        btnLike.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.height.equalTo(50.w)
        }
        
        self.addSubview(btnReply)
        btnReply.snp.makeConstraints { make in
            make.centerX.equalToSuperview().multipliedBy(2/3.0)
            make.centerY.equalTo(btnLike)
            make.height.equalTo(50.w)
            
        }
        
        self.addSubview(btnForward)
        btnForward.snp.makeConstraints { make in
            make.centerX.equalToSuperview().multipliedBy(4/3.0)
            make.centerY.equalTo(btnLike)
            make.height.equalTo(50.w)
            
        }
        
        self.addSubview(btnShare)
        btnShare.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalTo(btnLike)
            make.height.equalTo(50.w)
            make.width.equalToSuperview().multipliedBy(1/4.0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var btnLike : UIButton = {
        let btn = UIButton(type: .custom,font: UIFont.Medium(size: 11),image: UIImage(named: "icon_community_like")?.withRenderingMode(.alwaysTemplate),selectImage: UIImage(named: "icon_community_like_selelct")?.withRenderingMode(.alwaysTemplate))
        btn.addTarget(self, action: #selector(onclickLike), for: .touchUpInside)
        return btn
    }()
    
    lazy var btnReply : UIButton = {
        let btn = UIButton(type: .system,font: UIFont.Medium(size: 11),image: UIImage(named: "icon_community_reply"),tintColor: .iconColor)
        btn.isUserInteractionEnabled = false
//        btn.addTarget(self, action: #selector(onclickReply), for: .touchUpInside)
        return btn
    }()
    
    lazy var btnForward : UIButton = {
        let btn = UIButton(type: .system,font: UIFont.Medium(size: 11),image: UIImage(named: "icon_community_forward"),tintColor: .iconColor)
        btn.addTarget(self, action: #selector(onclickForword), for: .touchUpInside)
        return btn
    }()
    
    
    lazy var btnShare : UIButton = {
        let btn = UIButton(type: .system,font: UIFont.Medium(size: 11),image: UIImage(named: "icon_community_share"),tintColor: .iconColor)
        btn.addTarget(self, action: #selector(onclickShare), for: .touchUpInside)
        btn.contentHorizontalAlignment = .right
        return btn
    }()
    
    var model : EMCommunityHomeListEntity!{
        didSet{
            btnLike.setTitle("  \(model.LikeCount)", for: .normal)
            btnReply.setTitle("  \(model.CommentCount)", for: .normal)
            btnForward.setTitle("  \(model.ForwardCount)", for: .normal)
            btnLike.isSelected = model.isTwLike
            btnLike.setThemeTitleColor(model.isTwLike ? .heart : .iconColor, for: .normal)
            btnLike.themeTintColor = model.isTwLike ? .heart : .iconColor
            
            
            
        }
    }
    
    @objc func onclickLike(){
        self.likeBlock?()
    }
    
    @objc func onclickForword(){
        let vc = EMPublishPage(forward: self.model)
        vc.modalPresentationStyle = .fullScreen
        UIUtil.visibleVC()?.present(vc, animated: true)
    }
    
    @objc func onclickShare(){
        guard let invitation = URL(string: "https://app.ethtweet.io/#/tweet/detail?id=\(self.model.TwAddress)") else{
            return
        }
        UIUtil.visibleVC()?.present(UIActivityViewController(
            activityItems: [ invitation ],
            applicationActivities: nil
        ), animated: true)
    }
}
