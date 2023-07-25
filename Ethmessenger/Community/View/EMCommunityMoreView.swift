// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMCommunityMoreView: UIView {
    static let share = EMCommunityMoreView(frame: CGRectZero)
    
    var reportBlock : (()->())?
    var collectBlock : (()->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let bgView = UIView()
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        self.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.addSubview(contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var contentView : UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 79.w, height: 35.w))
        view.layer.shadowColor = UIColor.init(white: 0, alpha: 0.15).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 28
        view.layer.shadowRadius = 18.w
        self.addSubview(view)
        let contentView = UIView(.tab_select_bg)
        contentView.dealLayer(corner: 18.w)
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.addSubview(btnReport)
        btnReport.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
//        contentView.addSubview(btnCollection)
//        btnCollection.snp.makeConstraints { make in
//            make.left.right.bottom.equalToSuperview()
//            make.height.equalToSuperview().multipliedBy(0.5)
//        }
        return view
    }()
    
    lazy var btnReport : UIButton = {
        let btn = UIButton(type: .system,title: "  " + LocalReport.localized(),font: UIFont.Regular(size: 11),image: UIImage(named: "icon_community_report"),tintColor: .textPrimary)
        return btn
    }()
    
    lazy var btnCollection : UIButton = {
        let btn = UIButton(type: .system,title: "  " + LocalCollection.localized(),font: UIFont.Regular(size: 11),image: UIImage(named: "icon_community_collection"),tintColor: .textPrimary)
        return btn
    }()
    
    func show(_ view : UIView,contentFrame : CGRect) {
        self.contentView.frame = contentFrame
        self.frame = view.bounds
        view.addSubview(self)
    }
    
}

extension EMCommunityMoreView{
    @objc func onclickReport(){
        self.reportBlock?()
    }
    
    @objc func onclickCollection(){
        self.collectBlock?()
    }
    
    @objc func dismiss() {
        self.reportBlock = nil
        self.collectBlock = nil
        self.removeFromSuperview()
    }
}
