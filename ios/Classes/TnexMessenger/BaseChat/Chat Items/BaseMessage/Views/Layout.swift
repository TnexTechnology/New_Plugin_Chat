//
//  Layout.swift
//  tnexchat
//
//  Created by Din Vu Dinh on 28/03/2022.
//

import Foundation

struct Layout {
    private (set) var size = CGSize.zero
    private (set) var failedButtonFrame = CGRect.zero
    private (set) var messageStatusFrame = CGRect.zero
    private (set) var singleAvatarSeenFrame = CGRect.zero
    private (set) var bubbleViewFrame = CGRect.zero
    private (set) var avatarViewFrame = CGRect.zero
    private (set) var selectionIndicatorFrame = CGRect.zero
    private (set) var actionFrame = CGRect.zero
    private (set) var paddingContainerViewToActionBody: CGFloat = 0
    private (set) var preferredMaxWidthForBubble: CGFloat = 0

    mutating func calculateLayout(parameters: LayoutParameters) {
        let containerWidth = parameters.containerWidth
        let isIncoming = parameters.isIncoming
        let isShowingFailedButton = parameters.isShowingFailedButton
        let failedButtonSize = parameters.failedButtonSize
        let bubbleView = parameters.bubbleView
        let horizontalMargin = parameters.horizontalMargin
        let horizontalInterspacing = parameters.horizontalInterspacing
        let avatarSize = parameters.avatarSize
        let selectionIndicatorSize = parameters.selectionIndicatorSize
        let action = parameters.action

        let preferredWidthForBubble = (containerWidth * parameters.maxContainerWidthPercentageForBubbleView).bma_round()
        let bubbleSize: CGSize
        if case ActionMessageType.remove = action {
            bubbleSize = CGSize.zero
        } else {
            bubbleSize = bubbleView.sizeThatFits(CGSize(width: preferredWidthForBubble, height: .greatestFiniteMagnitude))
        }
        let actionSize = actionBodySize(action: action, maxWidthContent: preferredWidthForBubble, actionAttributesString: parameters.actionAttributesString)
        let messageStatusSize = MessageConstants.Sizes.statusSize
        let singleAvatarSeenSize = MessageConstants.Sizes.seenAvatarSize
        self.paddingContainerViewToActionBody = paddingContainerViewWithActionBody(for: action)
        let containerHeight = bubbleSize.height + actionSize.height + paddingContainerViewToActionBody
        let containerRect = CGRect(origin: CGPoint.zero,
                                   size: CGSize(width: containerWidth, height: containerHeight))
        
        self.messageStatusFrame = messageStatusSize.bma_rect(
            inContainer: containerRect,
            xAlignament: .right,
            yAlignment: .bottom
        )
        
        self.singleAvatarSeenFrame = singleAvatarSeenSize.bma_rect(
            inContainer: containerRect,
            xAlignament: .right,
            yAlignment: .bottom
        )
        
        self.actionFrame = actionSize.bma_rect(
            inContainer: containerRect,
            xAlignament: .center,
            yAlignment: .top
        )
        
        self.bubbleViewFrame = bubbleSize.bma_rect(
            inContainer: containerRect,
            xAlignament: .center,
            yAlignment: .center
        )

        self.failedButtonFrame = failedButtonSize.bma_rect(
            inContainer: containerRect,
            xAlignament: .center,
            yAlignment: .center
        )

        self.avatarViewFrame = avatarSize.bma_rect(
            inContainer: containerRect,
            xAlignament: .center,
            yAlignment: parameters.avatarVerticalAlignment
        )

        self.selectionIndicatorFrame = selectionIndicatorSize.bma_rect(
            inContainer: containerRect,
            xAlignament: .right,
            yAlignment: .center
        )

        // Adjust horizontal positions

        var currentX: CGFloat = 0

        if parameters.isShowingSelectionIndicator {
            self.selectionIndicatorFrame.origin.x = containerWidth - 12 - selectionIndicatorSize.width
            if !isIncoming {
                currentX -= (selectionIndicatorSize.width + parameters.selectionIndicatorMargins.left)
            }
            
        } else {
            self.selectionIndicatorFrame.origin.x += selectionIndicatorSize.width
        }
        if isIncoming {
            currentX += horizontalMargin
            self.avatarViewFrame.origin.x = currentX
            currentX += avatarSize.width
            if isShowingFailedButton {
                currentX += horizontalInterspacing
                self.failedButtonFrame.origin.x = currentX
                currentX += failedButtonSize.width
                currentX += horizontalInterspacing
            } else {
                self.failedButtonFrame.origin.x = currentX - failedButtonSize.width
                currentX += horizontalInterspacing
            }
            self.bubbleViewFrame.origin.x = currentX
            self.actionFrame.origin.x = currentX
        } else {
            currentX = containerRect.maxX - horizontalMargin
            if parameters.isShowingSelectionIndicator {
                currentX -= (selectionIndicatorSize.width + parameters.selectionIndicatorMargins.left)
            }
            currentX -= avatarSize.width
            self.avatarViewFrame.origin.x = currentX
            currentX -= horizontalInterspacing
            currentX -= bubbleSize.width
            self.bubbleViewFrame.origin.x = currentX
            self.actionFrame.origin.x = currentX - (actionSize.width - bubbleSize.width)
            self.failedButtonFrame.origin.x = self.bubbleViewFrame.origin.x - failedButtonSize.width - horizontalInterspacing
        }
        
        self.bubbleViewFrame.origin.y = self.actionFrame.maxY + paddingContainerViewToActionBody
        self.avatarViewFrame.origin.y = self.bubbleViewFrame.maxY - avatarSize.height
        self.messageStatusFrame.origin.x = containerWidth - 7 - messageStatusSize.width
        self.messageStatusFrame.origin.y = self.bubbleViewFrame.maxY - messageStatusSize.height
        self.singleAvatarSeenFrame.origin.x = containerWidth - 6 - singleAvatarSeenSize.width
        self.singleAvatarSeenFrame.origin.y = self.bubbleViewFrame.maxY - singleAvatarSeenSize.height
        self.size = containerRect.size
        self.preferredMaxWidthForBubble = preferredWidthForBubble
    }
    
    func actionBodySize(action: ActionMessageType, maxWidthContent: CGFloat, actionAttributesString: NSAttributedString?) -> CGSize {
        switch action {
        case .reply(let replyMessage):
            if (replyMessage.medias?.count ?? 0) > 0 || replyMessage.thumb != nil {
                var contentSize: CGSize = .zero
                if let attributedString = actionAttributesString {
                    contentSize = TextBubbleLayoutModel.labelSize(for: attributedString, considering: maxWidthContent)
                }
                return self.getSizeOfReplyMedia(contentSize: contentSize)
            }
            let contentInset = MessageConstants.ActionView.ReplyView.contentTextInset
            var actionContainerSize: CGSize = .zero
            if let attributedString = actionAttributesString {
                actionContainerSize = TextBubbleLayoutModel.labelSize(for: attributedString, considering: maxWidthContent - contentInset.horizontal)
                if actionContainerSize.height > MessageConstants.Limit.maxActionReplyTextHeight {
                    actionContainerSize.height = MessageConstants.Limit.maxActionReplyTextHeight
                }
                actionContainerSize.width += contentInset.horizontal
                actionContainerSize.height += contentInset.vertical
                let bottomPadding = MessageConstants.ActionView.ReplyView.bottomPadding < 0 ? -MessageConstants.ActionView.ReplyView.bottomPadding : 0
                actionContainerSize.height += bottomPadding
            }
            return actionContainerSize
        case .remove:
            if let attributedString = actionAttributesString {
                let contentInset = MessageConstants.ActionView.RemoveView.contentInset
                var actionContainerSize: CGSize
                actionContainerSize = TextBubbleLayoutModel.labelSize(for: attributedString, considering: maxWidthContent)
                actionContainerSize.width += contentInset.horizontal
                actionContainerSize.height += contentInset.vertical
                let bottomPadding = MessageConstants.ActionView.RemoveView.bottomPadding < 0 ? -MessageConstants.ActionView.RemoveView.bottomPadding : 0
                actionContainerSize.height += bottomPadding
                return actionContainerSize
            } else {
                return CGSize.zero
            }
        default:
            return CGSize.zero
        }
        
    }
    
    func paddingContainerViewWithActionBody(for action: ActionMessageType) -> CGFloat {
        switch action {
        case .reply:
            return MessageConstants.ActionView.ReplyView.bottomPadding
        default:
            return 0
        }
    }
    
    private func getSizeOfReplyMedia(contentSize: CGSize) -> CGSize {
        let contentOffset = MessageConstants.ActionView.ReplyView.contentMediaInset
        let heightOfImage: CGFloat = MessageConstants.ActionView.ReplyView.mediaSize.height
        let widthOfImage: CGFloat = MessageConstants.ActionView.ReplyView.mediaSize.width
        let padding: CGFloat = MessageConstants.ActionView.ReplyView.bottomPadding
        let height: CGFloat = contentOffset.top + heightOfImage + contentOffset.bottom - padding
        return CGSize(width: contentOffset.horizontal + widthOfImage + 5 + contentSize.width, height: height)
    }
    
}

struct LayoutParameters {
    let containerWidth: CGFloat
    let horizontalMargin: CGFloat
    let horizontalInterspacing: CGFloat
    let maxContainerWidthPercentageForBubbleView: CGFloat // in [0, 1]
    let bubbleView: UIView
    let isIncoming: Bool
    let isShowingFailedButton: Bool
    let failedButtonSize: CGSize
    let avatarSize: CGSize
    let avatarVerticalAlignment: VerticalAlignment
    let isShowingSelectionIndicator: Bool
    let selectionIndicatorSize: CGSize
    let action: ActionMessageType
    let selectionIndicatorMargins: UIEdgeInsets
    let actionAttributesString: NSAttributedString?
}
