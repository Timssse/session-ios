// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionUIKit
class EMCommunityMainPage: BaseVC,EMHideNavigationBarProtocol,ThemedNavigation {

    let vc1 = EMCommunityExplorePage()
    let vc2 = EMCommunityFollowPage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func layoutUI() {
        self.view.themeBackgroundColor = .navBack
        self.view.addSubview(pageTitleView)
        self.view.addSubview(pageView)
        self.view.addSubview(btnAdd)
        btnAdd.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10.w)
            make.bottom.equalToSuperview().offset(-safeBottomH-110.w)
        }
    }
    
    lazy var pageTitleView : SGPagingTitleView = {
        let configure = SGPagingTitleViewConfigure(showBottomSeparator: false, font: UIFont.Bold(size: 16), selectedFont: UIFont.Bold(size: 16),indicatorColor: #colorLiteral(red: 0.2431372549, green: 0.4, blue: 0.9843137255, alpha: 1),indicatorHeight: 3.w,indicatorFixedWidth: 164.w,indicatorType: .Fixed)
        let titleView = SGPagingTitleView(frame: CGRect(x: 0, y: statusBarH, width: Screen_width, height: 50.w), titles: [LocalExplore.localized(),LocalFollowing.localized()], configure: configure)
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
    
    lazy var btnAdd : UIButton = {
        let btn = UIButton(image: UIImage(named: "icon_community_add"))
        btn.addTarget(self, action: #selector(onclickAdd), for: .touchUpInside)
        return btn
    }()
}

extension EMCommunityMainPage : SGPagingContentViewDelegate,SGPagingTitleViewDelegate{
    @objc func onclickAdd(){
        let vc = EMPublishPage(forward: nil)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func pagingTitleView(titleView: SGPagingTitleView, index: Int) {
        pageView.setPagingContentView(index: index)
    }
    
    func pagingContentView(contentView: SGPagingContentView, progress: CGFloat, currentIndex: Int, targetIndex: Int) {
        pageTitleView.setPagingTitleView(progress: progress, currentIndex: currentIndex, targetIndex: targetIndex)
    }
}
