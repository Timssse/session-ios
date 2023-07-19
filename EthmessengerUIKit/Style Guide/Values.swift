import UIKit

@objc(LKValues)
public final class Values : NSObject {
    
    // MARK: - Alpha Values
    @objc public static let veryLowOpacity = CGFloat(0.12)
    @objc public static let lowOpacity = CGFloat(0.4)
    @objc public static let mediumOpacity = CGFloat(0.6)
    @objc public static let highOpacity = CGFloat(0.75)
    
    // MARK: - Font Sizes
    @objc public static let verySmallFontSize = CGFloat(12)
    @objc public static let smallFontSize = CGFloat(15)
    @objc public static let mediumFontSize = CGFloat(17)
    @objc public static let largeFontSize = CGFloat(22)
    @objc public static let veryLargeFontSize = CGFloat(26)
    @objc public static let massiveFontSize = CGFloat(50)
    
    // MARK: - Element Sizes
    @objc public static let smallButtonHeight = CGFloat(28)
    @objc public static let mediumButtonHeight = CGFloat(34)
    @objc public static let largeButtonHeight = CGFloat(45)
    @objc public static let alertButtonHeight: CGFloat = 51 // 19px tall font with 16px margins
    
    @objc public static let accentLineThickness = CGFloat(4)
    
    @objc public static let verySmallProfilePictureSize = CGFloat(26)
    @objc public static let smallProfilePictureSize = CGFloat(33)
    @objc public static let mediumProfilePictureSize = CGFloat(52)
    @objc public static let largeProfilePictureSize = CGFloat(124)
    
    @objc public static let searchBarHeight = CGFloat(36)

    @objc public static var separatorThickness: CGFloat { return 1 / UIScreen.main.scale }
    
    public static func footerGradientHeight(window: UIWindow?) -> CGFloat {
        return (
            Values.veryLargeSpacing +
            Values.largeButtonHeight +
            Values.smallSpacing +
            (window?.safeAreaInsets.bottom ?? 0)
        )
    }
    
    // MARK: - Distances
    @objc public static let verySmallSpacing = CGFloat(4)
    @objc public static let smallSpacing = CGFloat(8)
    @objc public static let mediumSpacing = CGFloat(16)
    @objc public static let largeSpacing = CGFloat(24)
    @objc public static let veryLargeSpacing = CGFloat(35)
    @objc public static let massiveSpacing = CGFloat(64)
    @objc public static let onboardingButtonBottomOffset = CGFloat(72)
    
    // MARK: - iPad Sizes
    @objc public static let iPadModalWidth = UIScreen.main.bounds.width / 2
    @objc public static let iPadButtonWidth = CGFloat(196)
    @objc public static let iPadButtonSpacing = CGFloat(32)
    @objc public static let iPadUserSessionIdContainerWidth = iPadButtonWidth * 2 + iPadButtonSpacing
}
