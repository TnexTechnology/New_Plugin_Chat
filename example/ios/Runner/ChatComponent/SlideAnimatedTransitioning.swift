//
//  SlideAnimatedTransitioning.swift
//  Runner
//
//  Created by Din Vu Dinh on 05/04/2022.
//

import UIKit

class SlideAnimatedTransitioning: NSObject {

}

extension SlideAnimatedTransitioning: UIViewControllerAnimatedTransitioning {

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        let containerView = transitionContext.containerView
        guard let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)?.view,
            let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)?.view else {
                return
        }

        let width = containerView.frame.width

        var offsetLeft = fromView.frame
        offsetLeft.origin.x = width

        var offscreenRight = toView.frame
        offscreenRight.origin.x = -width / 3.33

        toView.frame = offscreenRight
        
        let blackView = UIView()
        blackView.frame = toView.frame
        blackView.backgroundColor = .black
        blackView.alpha = 0.3
        toView.addSubview(blackView)

        containerView.insertSubview(toView, belowSubview: fromView)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseIn, animations: {

            toView.frame = fromView.frame
            blackView.frame = fromView.frame
            fromView.frame = offsetLeft

            blackView.alpha = 0

            }, completion: { _ in
                blackView.removeFromSuperview()
                toView.alpha = 1.0
                fromView.layer.opacity = 1.0
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.34
    }

}
