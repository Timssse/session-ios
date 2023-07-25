// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMCommunitySendView: UIView {
    var commentBlock : (()->())?
    
    private var model : EMCommunityHomeListEntity!
    convenience init(model : EMCommunityHomeListEntity) {
        self.init()
        self.model = model
        self.layer.shadowColor = UIColor.init(white: 0, alpha: 0.15).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 28
        self.layer.shadowRadius = 25.w
        self.isUserInteractionEnabled = true
        let bgView = UIView(.communitInput)
        bgView.isUserInteractionEnabled = true
        bgView.dealLayer(corner: 25.w)
        self.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        bgView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        bgView.addSubview(sendBtn)
        sendBtn.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.size.equalTo(CGSize(width: 82.w, height: 50.w))
        }
    }

    lazy var textView : UITextView = {
        let text = UITextView()
        text.textContainerInset = UIEdgeInsets(top: 15.w, leading: 20.w, bottom: 15.w, trailing: 20.w)
        text.font = UIFont.Regular(size: 13)
        text.themeTextColor = .textPlaceholder
        text.delegate = self
        text.text = LocalComment.localized() + "..."
        return text
    }()
    
    lazy var sendBtn : UIButton = {
        let btn = UIButton(title: LocalSend.localized(),font: UIFont.Medium(size: 16),color: .messageBubble_outgoingBackground)
        btn.addTarget(self, action: #selector(send), for: .touchUpInside)
        return btn
    }()
    
}

extension EMCommunitySendView{
    @objc func send(){
        if textView.text.removeSpace() == ""{
            textView.resignFirstResponder()
            return
        }
        Task{
            let relust = await EMCommunityController.commentRelease(twAddress: self.model.TwAddress, content: textView.text)
            if relust {
                self.commentBlock?()
                textView.text = ""
                textView.resignFirstResponder()
            }
                
        }
    }
}

extension EMCommunitySendView : UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text.removeSpace() == LocalComment.localized() + "..."{
            textView.text = ""
        }
        textView.themeTextColor = .textPrimary
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text.removeSpace() == ""{
            textView.text = LocalComment.localized() + "..."
        }
        textView.themeTextColor = .textPlaceholder
        return true
    }
}
