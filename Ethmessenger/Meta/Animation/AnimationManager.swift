// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import Foundation
import Lottie
class AnimationManager: NSObject {
    let animationTag  = 200200
    
    static let shared = AnimationManager()
    var animationView : LottieAnimationView? = nil
//    var dappAnimationView : AnimationView? = nil
    func setAnimation(_ y : CGFloat = (Screen_height - 58.w) * 0.5) {
        if animationView != nil {
            return
        }
        Thread.safe_main {
            let animation = LottieAnimation.named("loding")
            let vh : CGFloat = 58.w
            self.animationView = LottieAnimationView(animation: animation)
            self.animationView?.frame = CGRect(x: (Screen_width - vh) * 0.5, y: y, width: vh, height: vh)
            self.animationView?.contentMode = .scaleAspectFit
            self.animationView?.loopMode = .loop
            UIApplication.shared.keyWindow?.addSubview(self.animationView!)
            self.animationView?.play { (finished) in
    //            dPrint("动画完成")
            }
        }
    }
    
    func startAnimationView() {
        if self.animationView == nil {
            return
        }
        self.animationView?.play()
    }
    
    func removeAnimaition() {
        if self.animationView == nil {
            return
        }
        Thread.safe_main {
            self.animationView?.removeFromSuperview()
            self.animationView = nil
        }
    }
    
    func setAnimation(_ view : UIView ,y:CGFloat = 0) {
        self.removeAnimaition(view)
        let animation = LottieAnimation.named("dappLoding")
        let vh : CGFloat = 58.w
        var animationY = y
        if animationY == 0{
            animationY = (view.height())/2.0 - vh/2
        }
        
        let animationView = LottieAnimationView()
        animationView.tag = animationTag
        animationView.frame = CGRect(x: (Screen_width - vh) * 0.5, y: animationY, width: vh, height: vh)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        view.addSubview(animationView)
        animationView.play { (finished) in
            SNLog("动画完成")
        }
    }
    
    func removeAnimaition(_ view : UIView) {
        let animationView = view.viewWithTag(animationTag)
        animationView?.removeFromSuperview()
    }
    
}
