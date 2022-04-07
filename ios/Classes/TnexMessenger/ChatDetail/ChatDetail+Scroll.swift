//
//  ChatDetail+Scroll.swift
//  tnexchat
//
//  Created by Din Vu Dinh on 07/04/2022.
//

import UIKit

extension ChatDetailViewController {
    
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        if scrollView == messagesCollectionView {
            self.checkShowHideScrollButton()
        }
    }
    
    private func checkShowHideScrollButton() {
        let currentContentOffset: CGFloat = messagesCollectionView.contentOffset.y
        let heightOfCV: CGFloat = messagesCollectionView.frame.size.height
        guard heightOfCV > 0 else { return }
        if messagesCollectionView.contentSize.height - currentContentOffset > 2 * heightOfCV + 100 {
            //Set scrollButton show
            if self.messageChangeTracker?.scrollBottomButton.isHidden == true {
                self.messageChangeTracker?.showScrollButton()
            }
        } else {
            if self.messageChangeTracker?.scrollBottomButton.isHidden == false {
                if messagesCollectionView.contentSize.height - currentContentOffset < heightOfCV + 100 {
                    self.messageChangeTracker?.hideScrollButton()
                }
            }
        }
    }
}
