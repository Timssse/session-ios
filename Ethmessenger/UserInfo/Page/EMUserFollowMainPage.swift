// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionUIKit

class EMUserFollowMainPage: BaseVC,EMHideNavigationBarProtocol {
    
    let vc1 = EMUserFollowingPage()
    let vc2 = EMUserFollowerPage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func layoutUI() {
        self.view.themeBackgroundColor = .navBack
        self.view.addSubview(pageTitleView)
        
        let backBtn = UIButton(type: .system,image: UIImage(named: "icon_back"),tintColor: .textPrimary)
        backBtn.addTarget(self, action: #selector(popPage), for: .touchUpInside)
        self.view.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.top.bottom.equalTo(pageTitleView)
            make.width.equalTo(80.w)
            make.left.equalToSuperview()
        }
        
        self.view.addSubview(pageView)
    }
    
    lazy var pageTitleView : SGPagingTitleView = {
        let configure = SGPagingTitleViewConfigure(showBottomSeparator: false, font: UIFont.Bold(size: 16), selectedFont: UIFont.Bold(size: 16),indicatorColor: #colorLiteral(red: 0.2431372549, green: 0.4, blue: 0.9843137255, alpha: 1),indicatorHeight: 3.w,indicatorFixedWidth: 44.w,indicatorType: .Fixed)
        let titleView = SGPagingTitleView(frame: CGRect(x: 40.w, y: statusBarH, width: Screen_width-40.w, height: 50.w), titles: [LocalFollowing.localized(),LocalFollower.localized()], configure: configure)
        titleView.delegate = self
        titleView.themeBackgroundColor = .navBack
        return titleView
    }()
    
    lazy var pageView : SGPagingContentScrollView = {
        let view = SGPagingContentScrollView(frame: CGRect(x: 0, y: statusBarH + 50.w, width: Screen_width, height: Screen_height - statusBarH - 50.w), parentVC: self, childVCs: [vc1,vc2])
        view.dealCorner(type: .topLeftRight, corner: 20.w)
        view.delegate = self
        view.themeBackgroundColor = .conversationButton_background
        return view
    }()
    
}

extension EMUserFollowMainPage : SGPagingContentViewDelegate,SGPagingTitleViewDelegate{

    
    func pagingTitleView(titleView: SGPagingTitleView, index: Int) {
        pageView.setPagingContentView(index: index)
    }
    
    func pagingContentView(contentView: SGPagingContentView, progress: CGFloat, currentIndex: Int, targetIndex: Int) {
        pageTitleView.setPagingTitleView(progress: progress, currentIndex: currentIndex, targetIndex: targetIndex)
    }
}
