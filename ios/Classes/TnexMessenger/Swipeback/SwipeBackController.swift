//
//  SwipeBackController.swift
//  Runner
//
//  Created by Din Vu Dinh on 05/04/2022.
//

import UIKit

public typealias CompletionBlock = () -> Void

public class SwipeBackController: NSObject {
    public static let shared = SwipeBackController()
    var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition?

    public func handleSwipe(navigationController: UINavigationController?,
                                 state: UIGestureRecognizer.State,
                                 percent: CGFloat, velocity: CGFloat,
                                 beginSwipeAction: CompletionBlock?) {
        switch state {
        case .began:
            navigationController?.delegate = self
            percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
            percentDrivenInteractiveTransition?.completionCurve = .easeIn
            percentDrivenInteractiveTransition?.completionSpeed = 1.5
            if let beginSwipeAction = beginSwipeAction {
                beginSwipeAction()
            }
        case .changed:
            percentDrivenInteractiveTransition?.update(percent)
        case .ended:
            // Continue if drag more than 50% of screen width or velocity is higher than 1000
            if percent > 0.5 || velocity > 400 {
                percentDrivenInteractiveTransition?.finish()
            } else {
                percentDrivenInteractiveTransition?.cancel()
            }
        default:
            break
        }
    }
}

public extension UIViewController {
    
    @discardableResult
    @objc open func addSwipeBackGesture() -> UIPanGestureRecognizer? {
        let canSwipeBack = navigationController?.viewControllers.count ?? 0 > 1
        if !canSwipeBack {
            // in case screen from tabbar, disable custom swipe back
            // and also override edge gesture to disable default swipe back
            overrideEdgeScreenGesture()
            return nil
        } else {
            return usingPanGesture()
        }
    }
    
    func overrideEdgeScreenGesture() {
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self,
                                                       action: #selector(screenEdgeSwiped))
        edgePan.edges = .left
        view.addGestureRecognizer(edgePan)
    }
    
    func usingPanGesture() -> UIPanGestureRecognizer? {
        let panGestureRecognizer = UIPanGestureRecognizer(
            target: self, action: #selector(handleSwipeBackGesture(_:))
        )
        view.addGestureRecognizer(panGestureRecognizer)
        return panGestureRecognizer
    }

    @objc open func removeSwipeBackGesture() {
        navigationController?.delegate = nil
    }
    
    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
    }

    @objc open func handleSwipeBackGesture(_ panGesture: UIPanGestureRecognizer) {
        let point = panGesture.location(in: view)
        let state = panGesture.state
        let percent = max(panGesture.translation(in: view).x, 0) / view.frame.width
        let velocity = panGesture.velocity(in: view).x
        
        SwipeBackController.shared.handleSwipe(navigationController: navigationController, state: state, percent: percent, velocity: velocity, beginSwipeAction: beginSwipeAction)
    }
    
    @objc func beginSwipeAction() {
        navigationController?.popViewController(animated: true)
    }
}

extension SwipeBackController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            return SlideAnimatedTransitioning()
    }

    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            navigationController.delegate = nil
            return percentDrivenInteractiveTransition
    }
}
