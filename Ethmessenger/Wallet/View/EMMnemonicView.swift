// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class EMMnemonicView: UIView {
    var clickBlock : ((Int,String)->())?
    var mnemonic : [String]?
    var selectMnemonic : [String] = []
    convenience init(mnemonic : [String]) {
        self.init()
        self.mnemonic = mnemonic
        self.setWordsView(words: mnemonic)
    }

    private func setWordsView(words:[String]) {
        let line: CGFloat = 3
        var x: CGFloat = 20.w
        var y: CGFloat = 12.w
        let w: CGFloat = (Screen_width - 40.w - 28.w) / 3.0
        let h: CGFloat = 78.w
        let spacex: CGFloat = 14.w
        let spacey: CGFloat = 14.w
        for index  in 0..<12 {
            let column: CGFloat = CGFloat(index % Int(line))
            let row : CGFloat = CGFloat(index / Int(line))
            x = 20.w + column * (w + spacex)
            y = 12.w + row * (h + spacey)
            let view = UIView()
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickItem(_:))))
            view.dealLayer(corner: 6.w)
            view.tag = index
            view.frame = CGRect.init(x: x, y: y, width: w, height: h)
            self.addSubview(view)
            
            let labIndex = UILabel.init(font: UIFont.Bold(size: 12), textColor: .textPrimary, text: FS(index + 1))
            view.addSubview(labIndex)
            labIndex.snp.makeConstraints { (make) in
                make.left.equalToSuperview()
                make.top.equalToSuperview().offset(10.w)
            }
            
            let value = words.count > index ? words[index] : ""
            let label = UILabel.init(font: UIFont.Bold(size: 14), textColor: .textPrimary, text: value)
            label.textAlignment = .center
            label.themeBackgroundColor = .forget_textView_bg
            label.dealLayer(corner: 8.w)
            view.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(45.w)
            }
        }
    }
    
    func updateMnemonic(mnemonic : [String]) {
        self.mnemonic = mnemonic
        self.removeAllSubviews()
        setWordsView(words: mnemonic)
    }
    
    func updateSelectMnemonic(mnemonic : [String]) {
        self.selectMnemonic = mnemonic
        self.removeAllSubviews()
        setWordsView(words: self.mnemonic ?? [])
    }
}

extension EMMnemonicView{
    @objc func clickItem(_ tap : UITapGestureRecognizer){
        guard let index = tap.view?.tag , index < (self.mnemonic?.count ?? 0) else{
            return
        }
        self.clickBlock?(index,self.mnemonic![index])
    }
}
