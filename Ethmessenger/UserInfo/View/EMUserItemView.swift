// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMUserItemView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutUI() {
        self.themeBackgroundColor = .Color_F9FAFF_272727
        self.dealLayer(corner: 10.w)
        
        let monentsView = createItem(UIImage(named: "icon_user_moments")?.withRenderingMode(.alwaysTemplate), title: LocalMoments.localized())
        monentsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickMoments)))
        self.addSubview(monentsView)
        monentsView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(1/4.0)
        }
        
        let likeView = createItem(UIImage(named: "icon_user_like")?.withRenderingMode(.alwaysTemplate), title: LocalLike.localized())
        likeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickLike)))
        self.addSubview(likeView)
        likeView.snp.makeConstraints { make in
            make.left.equalTo(monentsView.snp.right)
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(1/4.0)
        }
        
        let replyView = createItem(UIImage(named: "icon_user_reply")?.withRenderingMode(.alwaysTemplate), title: LocalReply.localized())
        replyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickReply)))
        self.addSubview(replyView)
        replyView.snp.makeConstraints { make in
            make.left.equalTo(likeView.snp.right)
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(1/4.0)
        }
        
        let repostView = createItem(UIImage(named: "icon_user_repost")?.withRenderingMode(.alwaysTemplate), title: LocalRepost.localized())
        repostView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onclickRepost)))
        self.addSubview(repostView)
        repostView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(1/4.0)
        }
    }
    
    func createItem(_ icon : UIImage?,title : String) -> UIView {
        let view = UIView()
        let imageV = UIImageView(image: icon)
        imageV.themeTintColor = .textPrimary
        view.addSubview(imageV)
        imageV.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16.w)
        }
        
        let lab = UILabel(font: UIFont.Medium(size: 11),textColor: .color_91979D,text: title)
        view.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageV.snp.bottom).offset(2.w)
            make.bottom.equalToSuperview().offset(-12.w)
        }
        return view
    }
}

extension EMUserItemView{
    @objc func onclickMoments(){
        UIUtil.visibleNav()?.pushViewController(EMMomentsUserPage(), animated: true)
    }
    
    @objc func onclickLike(){
        UIUtil.visibleNav()?.pushViewController(EMLikePage(), animated: true)
    }
    
    @objc func onclickReply(){
        UIUtil.visibleNav()?.pushViewController(EMReplyPage(), animated: true)
    }
    
    @objc func onclickRepost(){
        UIUtil.visibleNav()?.pushViewController(EMRepostPage(), animated: true)
    }
}
