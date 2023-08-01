// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMRPCCell: BaseTableViewCell {

    let labName = UILabel(font:UIFont.Bold(size: 16),textColor: .textPrimary)
    let labRPC = UILabel(font:UIFont.Regular(size: 12),textColor: .color_91979D)
    let labMS = UILabel(font:UIFont.Bold(size: 13),textColor: .textPrimary)
    let statusView = UIView()
    let activity = UIActivityIndicatorView()
    
    override func layoutUI() {
        let bgView = UIView(.forget_textView_bg)
        bgView.dealLayer(corner: 20.w)
        self.contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5.w, leading: 25.w, bottom: 5.w, trailing: 25.w))
        }
        
        bgView.addSubview(labName)
        labName.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(23.w)
            make.top.equalToSuperview().offset(13.w)
            make.width.lessThanOrEqualTo(180.w)
        }
        
        bgView.addSubview(labRPC)
        labRPC.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(23.w)
            make.top.equalTo(labName.snp.bottom).offset(5.w)
            make.width.lessThanOrEqualTo(180.w)
            make.bottom.equalToSuperview().offset(-13.w)
        }
        
        statusView.dealLayer(corner: 3.w)
        bgView.addSubview(statusView)
        statusView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-18.w)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 6.w, height: 6.w))
        }
        
        bgView.addSubview(labMS)
        labMS.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-28.w)
            make.centerY.equalToSuperview()
        }
        
        bgView.addSubview(activity)
        activity.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-18.w)
            make.centerY.equalToSuperview()
        }
        
    }
    
    var model : EMRPCModel?{
        didSet{
            labName.text = model?.name
            labRPC.text = model?.rpc
            labMS.text = FS(model?.ms) + "ms"
            let ms = model?.ms ?? 0
            statusView.backgroundColor = ms > 1000 ? UIColor(hex: "FF0000") : ms > 200 ? UIColor(hex: "F9B132") : UIColor(hex: "54D6B6")
            statusView.isHidden = ms == 0
            labMS.isHidden = ms == 0
            if ms == 0 {
                activity.startAnimating()
            }else{
                activity.stopAnimating()
            }
            activity.isHidden = ms > 0
        }
    }
    
    var isSelect : Bool = false{
        didSet{
            labName.superview?.dealBorderLayer(corner: 20.w, bordercolor: isSelect ? .messageBubble_outgoingBackground : .clear, borderwidth: 1)
        }
    }
}
