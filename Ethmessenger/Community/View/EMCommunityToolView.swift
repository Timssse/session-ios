// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMCommunityToolView: UIView {
    
    var likeBlock : (()->())?
    var replyBlock : (()->())?
    var forwardBlock : (()->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(btnLike)
        btnLike.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.height.equalTo(30.w)
        }
        
        self.addSubview(btnReply)
        btnReply.snp.makeConstraints { make in
            make.left.equalTo(btnLike.snp.right).offset(28.w)
            make.centerY.equalTo(btnLike)
        }
        
        self.addSubview(btnForward)
        btnForward.snp.makeConstraints { make in
            make.left.equalTo(btnReply.snp.right).offset(28.w)
            make.centerY.equalTo(btnLike)
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var btnLike : UIButton = {
        let btn = UIButton(type: .custom,font: UIFont.Medium(size: 11),image: UIImage(named: "icon_community_like")?.withRenderingMode(.alwaysTemplate),selectImage: UIImage(named: "icon_community_like_selelct"))
        btn.addTarget(self, action: #selector(onclickLike), for: .touchUpInside)
        return btn
    }()
    
    lazy var btnReply : UIButton = {
        let btn = UIButton(type: .system,font: UIFont.Medium(size: 11),image: UIImage(named: "icon_community_reply"),tintColor: .communitTool)
        btn.addTarget(self, action: #selector(onclickReply), for: .touchUpInside)
        return btn
    }()
    
    lazy var btnForward : UIButton = {
        let btn = UIButton(type: .system,font: UIFont.Medium(size: 11),image: UIImage(named: "icon_community_forward"),tintColor: .communitTool)
        btn.addTarget(self, action: #selector(onclickForword), for: .touchUpInside)
        return btn
    }()
    
    var model : EMHomeListEntity!{
        didSet{
            btnLike.setTitle("  \(model.LikeCount)", for: .normal)
            btnReply.setTitle("  \(model.CommentCount)", for: .normal)
            btnForward.setTitle("  \(model.ForwardCount)", for: .normal)
            btnLike.isSelected = model.isTwLike
            btnLike.setThemeTitleColor(model.isTwLike ? .danger : .communitTool, for: .normal)
            btnLike.themeTintColor = model.isTwLike ? .danger : .communitTool
        }
    }
    
    @objc func onclickLike(){
        self.likeBlock?()
    }
    
    @objc func onclickReply(){
        self.replyBlock?()
    }
    
    @objc func onclickForword(){
        self.forwardBlock?()
    }
}
