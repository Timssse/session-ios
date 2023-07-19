import UIKit

public var isIPhone6OrSmaller: Bool {
    return (UIScreen.main.bounds.height - 667) < 1
}
