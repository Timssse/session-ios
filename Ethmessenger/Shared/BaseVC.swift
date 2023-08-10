// Copyright © 2022 Rangeproof Pty Ltd. All rights reserved.

import UIKit
import SessionUIKit

public class BaseVC: UIViewController {
    
    var navigationBackground: ThemeValue { .navBack }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.currentTheme.statusBarStyle
    }

    lazy var navBarTitleLabel: UILabel = {
        let result = UILabel()
        result.font = .boldSystemFont(ofSize: Values.veryLargeFontSize)
        result.themeTextColor = .textPrimary
        result.textAlignment = .center
        result.alpha = 1
        
        return result
    }()

    lazy var crossfadeLabel: UILabel = {
        let result = UILabel()
        result.font = .boldSystemFont(ofSize: Values.veryLargeFontSize)
        result.themeTextColor = .textPrimary
        result.textAlignment = .center
        result.alpha = 0
        
        return result
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = ""
        view.themeBackgroundColor = .navBack
        ThemeManager.applyNavigationStylingIfNeeded(to: self)
        
        setNeedsStatusBarAppearanceUpdate()
        self.layoutUI()
    }
    
    func layoutUI() {
        
    }
    
    
    func push(_ vc : UIViewController)  {
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func popPage()  {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true)
    }
    
    

    internal func setNavBarTitle(_ title: String, customFontSize: CGFloat? = nil) {
        let container = UIView()
        navBarTitleLabel.text = title
        crossfadeLabel.text = title
        
        if let customFontSize = customFontSize {
            navBarTitleLabel.font = .boldSystemFont(ofSize: customFontSize)
            crossfadeLabel.font = .boldSystemFont(ofSize: customFontSize)
        }
        
        container.addSubview(navBarTitleLabel)
        container.addSubview(crossfadeLabel)
        
        navBarTitleLabel.pin(to: container)
        crossfadeLabel.pin(to: container)
        
        navigationItem.titleView = container
    }
    
    internal func setUpNavBarSessionHeading() {
        let headingImageView = UIImageView(
            image: UIImage(named: "SessionHeading")?
                .withRenderingMode(.alwaysTemplate)
        )
        headingImageView.themeTintColor = .textPrimary
        headingImageView.contentMode = .scaleAspectFit
        headingImageView.set(.width, to: 150)
        headingImageView.set(.height, to: Values.mediumFontSize)
        
        navigationItem.titleView = headingImageView
    }

    var navHeight : CGFloat{
        get{
            return navigationBarHeight + statusBarH
        }
    }
    
    var navigationBarHeight : CGFloat{
        get{
            return (navigationController?.navigationBar.frame.size.height ?? 44)
        }
    }
}
