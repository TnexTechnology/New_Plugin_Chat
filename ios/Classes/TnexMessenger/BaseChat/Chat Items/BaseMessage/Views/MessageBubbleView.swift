//
//  MessageBubbleView.swift
//  tnexchat
//
//  Created by Din Vu Dinh on 28/03/2022.
//

import Foundation

open class MessageBubbleView: UIView, MaximumLayoutWidthSpecificable, BackgroundSizingQueryable {
    
    public var preferredMaxLayoutWidth: CGFloat = 0
    public var animationDuration: CGFloat = 0.33
    public var canCalculateSizeInBackground: Bool {
        return true
    }
    
    public func updateViews() {}
    
    public private(set) var isUpdating: Bool = false
    public func performBatchUpdates(_ updateClosure: @escaping () -> Void, animated: Bool, completion: (() -> Void)?) {
        self.isUpdating = true
        let updateAndRefreshViews = {
            updateClosure()
            self.isUpdating = false
            self.updateViews()
            if animated {
                self.layoutIfNeeded()
            }
        }
        if animated {
            UIView.animate(withDuration: TimeInterval(animationDuration), animations: updateAndRefreshViews, completion: { (_) -> Void in
                completion?()
            })
        } else {
            updateAndRefreshViews()
        }
    }
}
