//
//  MsgCollectionView.swift
//  MessageKit
//
//  Created by Gapo on 01/08/2021.
//

import Foundation
import UIKit

open class MsgCollectionView: UICollectionView, UIGestureRecognizerDelegate {
        
    // MARK: - Initializers

    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        backgroundColor = .collectionViewBackground
        setupGestureRecognizers()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    }

    public convenience init() {
        self.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    }
    
    public var isLongpressing: Bool = false
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }

    // MARK: - Methods
    
    private func setupGestureRecognizers() {
        let singleTapGesture = UIShortTapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        singleTapGesture.numberOfTapsRequired = 1
//        singleTapGesture.delaysTouchesBegan = true
        singleTapGesture.cancelsTouchesInView = false
        singleTapGesture.delegate = self
        addGestureRecognizer(singleTapGesture)
        //Add longpress
        let longpressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongpressGesture))
        longpressGesture.cancelsTouchesInView = true
//        longpressGesture.delegate = self
        longpressGesture.minimumPressDuration = 0.25
        addGestureRecognizer(longpressGesture)
    }
    
    @objc
    open func handleTapGesture(_ gesture: UIGestureRecognizer) {
//        guard gesture.state == .ended else { return }
        let touchLocation = gesture.location(in: self)
        guard let indexPath = indexPathForItem(at: touchLocation),
              let cell = cellForItem(at: indexPath) as? MessageCollectionViewCell else { return }
        cell.handleTapGesture(gesture)
        if gesture.state == .ended || gesture.state == .cancelled {
            isLongpressing = false
            cell.didEndPressGesture()
        }
    }
    
    @objc
    open func handleDoubleTapGesture(_ gesture: UIGestureRecognizer) {
//        guard gesture.state == .ended else { return }
        let touchLocation = gesture.location(in: self)
        guard let indexPath = indexPathForItem(at: touchLocation) else { return }
        let cell = cellForItem(at: indexPath) as? MessageCollectionViewCell
        cell?.handleDoubleTapGesture(gesture)
    }

    @objc
    open func handleLongpressGesture(_ gesture: UILongPressGestureRecognizer) {
        let touchLocation = gesture.location(in: self)
        guard let indexPath = indexPathForItem(at: touchLocation),
              let cell = cellForItem(at: indexPath) as? MessageCollectionViewCell else { return }
        if gesture.state == .ended || gesture.state == .cancelled {
            isLongpressing = false
            cell.didEndPressGesture()
        }
        let convertPoint = self.convert(touchLocation, to: cell)
        if gesture.state == .began {
            let touchPointInWindow = gesture.location(in: UIApplication.key)
            self.isLongpressing = true
            cell.handleLongPressGesture(in: convertPoint, touchPointInWindow: touchPointInWindow)
        }
    }

}

class UIShortTapGestureRecognizer: UITapGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            if self?.state != .recognized {
                self?.state = .failed
            }
        }
    }
}
