/*
 The MIT License (MIT)

 Copyright (c) 2015-present Badoo Trading Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

import UIKit

public protocol SeenViewProtocol: UIView {
    var userId: String { get }
    var messageId: String { get }
}


public struct ReplyIndicatorStyle {
    let image: UIImage
    let size: CGSize
    let maxOffsetToReplyIndicator: CGFloat

    public init(image: UIImage, size: CGSize, maxOffsetToReplyIndicator: CGFloat) {
        self.image = image
        self.size = size
        self.maxOffsetToReplyIndicator = maxOffsetToReplyIndicator
    }

    var maxOffset: CGFloat { self.maxOffsetToReplyIndicator + size.width }
}

public protocol BaseMessageCollectionViewCellStyleProtocol {
    func avatarSize(viewModel: MessageViewModelProtocol) -> CGSize // .zero => no avatar
    func avatarVerticalAlignment(viewModel: MessageViewModelProtocol) -> VerticalAlignment
    var failedIcon: UIImage { get }
    var failedIconHighlighted: UIImage { get }
    var selectionIndicatorMargins: UIEdgeInsets { get }
    func selectionIndicatorIcon(for viewModel: MessageViewModelProtocol) -> UIImage
    func attributedStringForDate(_ date: String) -> NSAttributedString
    func layoutConstants(viewModel: MessageViewModelProtocol) -> BaseMessageCollectionViewCellLayoutConstants
    var replyIndicatorStyle: ReplyIndicatorStyle? { get }
    func actionAttributesString(action: ActionMessageType) -> NSAttributedString?
}

public struct BaseMessageCollectionViewCellLayoutConstants {
    public let leftMargin: CGFloat
    public let rightMargin: CGFloat
    public let horizontalMargin: CGFloat
    public let horizontalInterspacing: CGFloat
    public let horizontalTimestampMargin: CGFloat
    public let maxContainerWidthPercentageForBubbleView: CGFloat

    public init(horizontalMargin: CGFloat,
                rightMargin: CGFloat = 26,
                horizontalInterspacing: CGFloat,
                horizontalTimestampMargin: CGFloat,
                maxContainerWidthPercentageForBubbleView: CGFloat) {
        self.leftMargin = horizontalMargin
        self.rightMargin = rightMargin
        self.horizontalMargin = horizontalMargin
        self.horizontalInterspacing = horizontalInterspacing
        self.horizontalTimestampMargin = horizontalTimestampMargin
        self.maxContainerWidthPercentageForBubbleView = maxContainerWidthPercentageForBubbleView
    }
}

/**
    Base class for message cells

    Provides:

        - Reveleable timestamp
        - Failed icon
        - Incoming/outcoming styles
        - Selection support

    Subclasses responsability
        - Implement createBubbleView
        - Have a BubbleViewType that responds properly to sizeThatFits:
*/

open class BaseMessageCollectionViewCell<BubbleViewType>: MessageCollectionViewCell, BackgroundSizingQueryable, AccessoryViewRevealable, ReplyIndicatorRevealable, UIGestureRecognizerDelegate where
    BubbleViewType: UIView,
    BubbleViewType: MaximumLayoutWidthSpecificable,
    BubbleViewType: BackgroundSizingQueryable {

    public var animationDuration: CFTimeInterval = 0.33
    open var viewContext: ViewContext = .normal

    public private(set) var isUpdating: Bool = false
    open func performBatchUpdates(_ updateClosure: @escaping () -> Void, animated: Bool, completion: (() -> Void)?) {
        self.isUpdating = true
        let updateAndRefreshViews = {
            updateClosure()
            self.isUpdating = false
            self.updateViews()
        }
        if animated {
            UIView.animate(withDuration: self.animationDuration, animations: updateAndRefreshViews, completion: { (_) -> Void in
                completion?()
            })
        } else {
            updateAndRefreshViews()
        }
    }

    open var messageViewModel: MessageViewModelProtocol! {
        didSet {
            self.updateViews()
            self.observeAvatar()
            self.addBubbleViewConstraintsIfNeeded()
        }
    }
        
        open weak var delegate: MKMessageLabelDelegate? {
            didSet {
                if let textBubbleView = self.bubbleView as? TextBubbleProtocol {
                    textBubbleView.delegate = delegate
                }
            }
        }

    public var baseStyle: BaseMessageCollectionViewCellStyleProtocol! {
        didSet {
            self.updateViews()
            self.addBubbleViewConstraintsIfNeeded()
        }
    }

    private var shouldShowFailedIcon: Bool {
        return self.messageViewModel?.decorationAttributes.canShowFailedIcon == true && self.messageViewModel?.isShowingFailedIcon == true
    }

    override open var isSelected: Bool {
        didSet {
            if oldValue != self.isSelected {
                self.updateViews()
            }
        }
    }

    open var useAutolayoutForBubbleView: Bool { false }

    open var canCalculateSizeInBackground: Bool {
        return self.bubbleView.canCalculateSizeInBackground
    }

    public private(set) var bubbleView: BubbleViewType!
    open func createBubbleView() -> BubbleViewType! {
        assert(false, "Override in subclass")
        return nil
    }
        
    open var singleAvatarSeenView: SeenViewProtocol!
    
        @objc
        func failedButtonTapped() {
            self.onFailedButtonTapped?(self)
        }
        
        public var onFailedButtonTapped: ((_ cell: BaseMessageCollectionViewCell) -> Void)?
        public var onAvatarTapped: ((_ cell: BaseMessageCollectionViewCell) -> Void)?
        public var onActionViewTapped: ((_ action: ActionMessageType, _ imageView: UIImageView?) -> Void)?
        public var onBubbleTapped: ((_ cell: BaseMessageCollectionViewCell) -> Void)?
        public var onBubbleDoubleTapped: ((_ cell: BaseMessageCollectionViewCell) -> Void)?
        public var onBubbleLongPressBegan: ((_ cell: BaseMessageCollectionViewCell) -> Void)?
        public var onBubbleLongPressEnded: ((_ cell: BaseMessageCollectionViewCell, _ touchPoint: CGPoint) -> Void)?
        public var onAvatarLongPressEnded: ((_ cell: BaseMessageCollectionViewCell, _ touchPoint: CGPoint) -> Void)?
        public var onSelection: ((_ cell: BaseMessageCollectionViewCell) -> Void)?
        public var onTapSingleSeenView: ((_ cell: BaseMessageCollectionViewCell) -> Void)?
        
        open var statusMessageImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.layer.cornerRadius = 7.5
            imageView.clipsToBounds = true
            return imageView
        }()
        
        lazy var actionContainerView: ActionMessageView = {
            let actionView = ActionMessageView(action: self.messageViewModel.actionType)
            actionView.backgroundColor = MessageConstants.ActionView.backgroundColor
            actionView.layer.cornerRadius = MessageConstants.ActionView.cornerRadius
            actionView.clipsToBounds = true
            actionView.isUserInteractionEnabled = true
            self.contentView.insertSubview(actionView, belowSubview: self.bubbleView)
             self._actionContainerView = actionView
            return actionView
        }()
        public var _actionContainerView: UIView?

    public private(set) var avatarView: UIImageView!
    open func createAvatarView() -> UIImageView! {
        let avatarImageView = UIImageView(frame: CGRect.zero)
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.clipsToBounds = true
        return avatarImageView
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        self.avatarView = self.createAvatarView()
        self.bubbleView = self.createBubbleView()
        self.bubbleView.isExclusiveTouch = true
        self.contentView.addSubview(self.bubbleView)
//        self.bubbleView.addGestureRecognizer(self.tapGestureRecognizer)
//        self.bubbleView.addGestureRecognizer(self.longPressGestureRecognizer)
//        self.bubbleView.addGestureRecognizer(self.doubleTapGestureRecognizer)
//        self.tapGestureRecognizer.require(toFail: self.longPressGestureRecognizer)
//        self.tapGestureRecognizer.require(toFail: self.doubleTapGestureRecognizer)
        self.contentView.addSubview(self.statusMessageImageView)
        self.contentView.addSubview(self.avatarView)
        self.contentView.addSubview(self.failedButton)
        self.contentView.addSubview(self.selectionIndicator)
        self.contentView.addSubview(self.replyIndicator)
        self.replyIndicator.alpha = 0
        self.contentView.isExclusiveTouch = true
        self.isExclusiveTouch = true
        self.backgroundColor = .clear
        singleAvatarSeenView = AvatarSeenView(userId: "", messageId: "")
        self.contentView.addSubview(singleAvatarSeenView)
    }

    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return self.bubbleView.bounds.contains(touch.location(in: self.bubbleView))
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        self.removeAccessoryView()
    }

    public private(set) lazy var failedButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(BaseMessageCollectionViewCell.failedButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: View model binding

    final private func updateViews() {
        if self.viewContext == .sizing { return }
        if self.isUpdating { return }
        guard let viewModel = self.messageViewModel, let style = self.baseStyle else { return }
        self.bubbleView.isUserInteractionEnabled = viewModel.isUserInteractionEnabled
        self.updateFailedIconState()
        self.accessoryTimestampView.attributedText = style.attributedStringForDate(viewModel.date)
        self.updateSelectionIndicator(with: style)
        if !(viewModel.actionType == ActionMessageType.default) {
            self.updateActionView(viewModel: viewModel)
        }
        self.contentView.isUserInteractionEnabled = !viewModel.decorationAttributes.isShowingSelectionIndicator
        self.selectionIndicator.isHidden = !viewModel.decorationAttributes.isShowingSelectionIndicator
        self.statusMessageImageView.image = viewModel.status.icon
        if let replyIndicatorStyle = style.replyIndicatorStyle {
            replyIndicator.image = replyIndicatorStyle.image
            replyIndicator.bounds.size = replyIndicatorStyle.size
        }

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
        
        private func updateActionView(viewModel: MessageViewModelProtocol) {
//            UIView.performWithoutAnimation {
//                let attributedText = self.baseStyle.actionAttributesString(action: viewModel.actionType)
//                self.actionContainerView.applyUI(isOutgoingMessage: !viewModel.isIncoming, action: viewModel.actionType, attributedText: attributedText)
//                self.actionContainerView.layoutIfNeeded()
//            }
//            if let imageView = self.actionContainerView.imageView {
//                viewModel.messageActionThumb?(imageView, viewModel.actionType)
//            }
        }

    public func updateFailedIconState() {
        let oldAlpha = self.failedButton.alpha
        if self.shouldShowFailedIcon {
            self.failedButton.setImage(self.baseStyle.failedIcon, for: .normal)
            self.failedButton.setImage(self.baseStyle.failedIconHighlighted, for: .highlighted)
            self.failedButton.alpha = 1
        } else {
            self.failedButton.alpha = 0
        }
        if oldAlpha != self.failedButton.alpha {
            // to recalculate bubble offsets
            self.setNeedsLayout()
        }
    }

    private func observeAvatar() {
        guard self.viewContext != .sizing else { return }
        guard let viewModel = self.messageViewModel else { return }
        self.avatarView.isHidden = !viewModel.decorationAttributes.isShowingAvatar
        self.avatarView.layer.cornerRadius = self.baseStyle.avatarSize(viewModel: viewModel).height/2
        self.avatarView.setThumbMessage(url: viewModel.avatarUrl)
    }

    // MARK: layout

    private var didAddConstraintsForBubbleView = false
    private func addBubbleViewConstraintsIfNeeded() {
        guard !self.didAddConstraintsForBubbleView, let viewModel = self.messageViewModel, let style = self.baseStyle else { return }
        guard self.useAutolayoutForBubbleView else { return }
        self.didAddConstraintsForBubbleView = true
        let layoutConstants = style.layoutConstants(viewModel: viewModel)
        let percentage = layoutConstants.maxContainerWidthPercentageForBubbleView
        let offset = layoutConstants.horizontalMargin + layoutConstants.horizontalInterspacing
        let xConstraint: NSLayoutConstraint
        if viewModel.isIncoming {
            xConstraint = bubbleView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: offset)
        } else {
            xConstraint = bubbleView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -offset)
        }

        NSLayoutConstraint.activate([
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: percentage),
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            xConstraint
        ])
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        let layout = self.calculateLayout(availableWidth: self.contentView.bounds.width)
        self.updateSingleAvatarSeenView(layout: layout)
        self.failedButton.bma_rect = layout.failedButtonFrame
        if !self.useAutolayoutForBubbleView {
            self.bubbleView.bma_rect = layout.bubbleViewFrame
            self.bubbleView.preferredMaxLayoutWidth = layout.preferredMaxWidthForBubble
            self.bubbleView.layoutIfNeeded()
        }

        self.avatarView.bma_rect = layout.avatarViewFrame
        self.avatarView.layer.cornerRadius = layout.avatarViewFrame.size.width / 2
        self.selectionIndicator.bma_rect = layout.selectionIndicatorFrame
        self.statusMessageImageView.bma_rect = layout.messageStatusFrame
        self.updateTimestampView()
        if self.messageViewModel.decorationAttributes.isShowingSelectionIndicator {
            self.singleAvatarSeenView?.isHidden = true
            self.statusMessageImageView.isHidden = true
        } else {
            self.updateSingleAvatarSeenView(layout: layout)
        }
        self.updatereplyIndicator()
    }
        
        private func updateSingleAvatarSeenView(layout: Layout) {
            if let seenUserId = self.messageViewModel.singleSeenUserId, let avatarSeenView = self.singleAvatarSeenView as? AvatarSeenView {
                avatarSeenView.imgAvatar.loadAvatar(url: seenUserId.getAvatarUrl())
                singleAvatarSeenView.isHidden = false
                self.statusMessageImageView.isHidden = true
            } else {
                singleAvatarSeenView.isHidden = true
                self.statusMessageImageView.isHidden = self.messageViewModel.status == .normal
            }
            self.singleAvatarSeenView?.bma_rect = layout.singleAvatarSeenFrame
            self.singleAvatarSeenView?.layer.cornerRadius = 8
        }
        
        private func updatereplyIndicator() {
            guard let style = self.baseStyle?.replyIndicatorStyle, offsetToRevealAccessoryView == 0 else { return }
            let offset = self.offsetToRevealReplyIndicator
            guard -offset < self.bounds.width/2 else { return }
            let width = style.size.width
            self.replyIndicator.center = CGPoint(
                x: self.bounds.width - min(style.maxOffset + offset, 0) + width / 2,
                y: self.bounds.height / 2
            )
            self.contentView.frame.origin.x = offset
        }
        
        private func updateTimestampView() {
            guard self.accessoryTimestampView.superview != nil else { return }
            let layoutConstants = baseStyle.layoutConstants(viewModel: messageViewModel)
            self.accessoryTimestampView.bounds = CGRect(origin: CGPoint.zero, size: self.accessoryTimestampView.intrinsicContentSize)
            let accessoryViewWidth = self.accessoryTimestampView.bounds.width
            let leftOffsetForContentView = max(0, offsetToRevealAccessoryView)
            let leftOffsetForAccessoryView = min(leftOffsetForContentView, accessoryViewWidth + layoutConstants.horizontalTimestampMargin)
            var contentViewframe = self.contentView.frame
            if self.messageViewModel.isIncoming {
                contentViewframe.origin = CGPoint.zero
            } else {
                contentViewframe.origin.x = -leftOffsetForContentView
            }
            self.contentView.frame = contentViewframe
            self.accessoryTimestampView.center = CGPoint(x: self.bounds.width - leftOffsetForAccessoryView + accessoryViewWidth / 2, y: self.contentView.center.y)
        }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        if self.useAutolayoutForBubbleView {
            return contentView.systemLayoutSizeFitting(.init(width: size.width, height: 0),
                                                       withHorizontalFittingPriority: .required,
                                                       verticalFittingPriority: .defaultLow)
        } else {
            return self.calculateLayout(availableWidth: size.width).size
        }
    }

        private func calculateLayout(availableWidth: CGFloat) -> Layout {
            let layoutConstants = self.baseStyle.layoutConstants(viewModel: self.messageViewModel)
            let parameters = LayoutParameters(
                containerWidth: availableWidth,
                horizontalMargin: layoutConstants.leftMargin,
                horizontalInterspacing: layoutConstants.horizontalInterspacing,
                maxContainerWidthPercentageForBubbleView: layoutConstants.maxContainerWidthPercentageForBubbleView,
                bubbleView: self.bubbleView,
                isIncoming: self.messageViewModel.isIncoming,
                isShowingFailedButton: self.shouldShowFailedIcon,
                failedButtonSize: self.baseStyle.failedIcon.size,
                avatarSize: self.baseStyle.avatarSize(viewModel: self.messageViewModel),
                avatarVerticalAlignment: self.baseStyle.avatarVerticalAlignment(viewModel: self.messageViewModel),
                isShowingSelectionIndicator: self.messageViewModel.decorationAttributes.isShowingSelectionIndicator,
                selectionIndicatorSize: self.baseStyle.selectionIndicatorIcon(for: self.messageViewModel).size,
                action: self.messageViewModel.actionType,
                selectionIndicatorMargins: self.baseStyle.selectionIndicatorMargins,
                actionAttributesString: self.baseStyle.actionAttributesString(action: self.messageViewModel.actionType)
            )
            var layoutModel = Layout()
            layoutModel.calculateLayout(parameters: parameters)
            return layoutModel
        }

    // MARK: timestamp revealing

    private let accessoryTimestampView = UILabel()

    var offsetToRevealAccessoryView: CGFloat = 0 {
        didSet {
            self.setNeedsLayout()
        }
    }

    public var allowRevealing: Bool = true

    open func preferredOffsetToRevealAccessoryView() -> CGFloat? {
        let layoutConstants = baseStyle.layoutConstants(viewModel: messageViewModel)
        return self.accessoryTimestampView.intrinsicContentSize.width + layoutConstants.horizontalTimestampMargin
    }

    open func revealAccessoryView(withOffset offset: CGFloat, animated: Bool) {
        self.offsetToRevealAccessoryView = offset
        if self.accessoryTimestampView.superview == nil {
            if offset > 0 {
                self.addSubview(self.accessoryTimestampView)
                self.layoutIfNeeded()
            }

            if animated {
                UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
                    self.layoutIfNeeded()
                })
            }
        } else {
            if animated {
                UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
                    self.layoutIfNeeded()
                    }, completion: { (_) -> Void in
                        if offset == 0 {
                            self.removeAccessoryView()
                        }
                })
            }
        }
    }

    func removeAccessoryView() {
        self.accessoryTimestampView.removeFromSuperview()
    }

    // MARK: Reply revealing

    private let replyIndicator = UIImageView()

    private var offsetToRevealReplyIndicator: CGFloat = 0 {
        didSet { self.setNeedsLayout() }
    }

    open func canShowReply() -> Bool {
        self.messageViewModel?.canReply ?? false
    }

    open func revealReplyIndicator(withOffset offset: CGFloat, animated: Bool) -> Bool {
        guard let maxOffset = self.baseStyle?.replyIndicatorStyle?.maxOffset else { return false }
        self.offsetToRevealReplyIndicator = offset
        let updateAlpha = { [weak self] in
            self?.replyIndicator.alpha = min(offset, maxOffset) / maxOffset
        }
        if animated {
            UIView.animate(withDuration: self.animationDuration) {
                self.layoutIfNeeded()
                updateAlpha()
            }
        } else {
            updateAlpha()
        }
        return offset >= maxOffset
    }

    // MARK: Selection

    private let selectionIndicator = UIImageView(frame: .zero)

    private func updateSelectionIndicator(with style: BaseMessageCollectionViewCellStyleProtocol) {
        self.selectionIndicator.image = style.selectionIndicatorIcon(for: self.messageViewModel)
        self.updateSelectionIndicatorAccessibilityIdentifier()
    }

    private func updateSelectionIndicatorAccessibilityIdentifier() {
        let accessibilityIdentifier: String
        if self.messageViewModel.decorationAttributes.isShowingSelectionIndicator {
            if self.messageViewModel.decorationAttributes.isSelected {
                accessibilityIdentifier = "chat.message.selection_indicator.selected"
            } else {
                accessibilityIdentifier = "chat.message.selection_indicator.deselected"
            }
        } else {
            accessibilityIdentifier = "chat.message.selection_indicator.hidden"
        }
        self.selectionIndicator.accessibilityIdentifier = accessibilityIdentifier
    }
        
        // MARK: User interaction
        
        private var workItem: DispatchWorkItem?
        private var timeout: TimeInterval = 0.3
        private var tapCount = 0
        
        private func countTapAction(completion: @escaping((_ isDoubleTap: Bool) -> Void)) {
            tapCount += 1
            if tapCount == 1 {
                workItem = DispatchWorkItem { [weak self] in
                    guard let self = self else { return }
                    self.tapCount = 0
                    completion(false)
                }
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + timeout,
                    execute: workItem!
                )
            } else {
                workItem?.cancel()
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.tapCount = 0
                    completion(true)
                }
            }
        }
        
        func handleTapBubbleView(touchLocation: CGPoint) {
            self.onBubbleTapped?(self)
        }
        
        public override func handleTapGesture(_ gesture: UIGestureRecognizer) {
            guard allowRevealing else {
                self.onSelection?(self)
                return
            }
            let touchLocation = gesture.location(in: self)
            switch true {
            case self.bubbleView.frame.contains(touchLocation):
                self.countTapAction {[weak self] (isDoubleTap) in
                    guard let self = self else { return }
                    if isDoubleTap {
                        self.onBubbleDoubleTapped?(self)
                    } else {
                        let touchPointInBubbleView = self.convert(touchLocation, to: self.bubbleView)
                        self.handleTapBubbleView(touchLocation: touchPointInBubbleView)
                    }
                }
            case self.actionContainerView.frame.contains(touchLocation):
                self.onActionViewTapped?(self.messageViewModel.actionType, self.actionContainerView.imageView)
            case self.avatarView.frame.contains(touchLocation) && !avatarView.isHidden && self.avatarView.image != nil:
                self.onAvatarTapped?(self)
            default:
                self.onSelection?(self)
            }
        }
        
        public override func handleDoubleTapGesture(_ gesture: UIGestureRecognizer) {
            self.onBubbleDoubleTapped?(self)
        }
        
        public override func handleLongPressGesture(in touchLocation: CGPoint, touchPointInWindow: CGPoint) {
            guard self.messageViewModel.decorationAttributes.isShowingSelectionIndicator == false else { return }
            if let textBubbleView = self.bubbleView as? TextBubbleProtocol {
                let newTouch = self.convert(touchLocation, to: textBubbleView.messageLabel)
                if textBubbleView.messageLabel.rangesForDetectors[.url]?.count ?? 0 > 1 {
                    if textBubbleView.messageLabel.handleGesture(newTouch) {
                        //Longpress to richtext
                        return
                    }
                }
            }
            switch true {
            case self.bubbleView.frame.contains(touchLocation):
                self.spotlightBubleView {[weak self] in
                    if let self = self {
                        self.onBubbleLongPressEnded?(self, touchPointInWindow)
                    }
                }
            case avatarView.frame.contains(touchLocation) && !avatarView.isHidden && self.avatarView.image != nil:
                self.onAvatarLongPressEnded?(self, touchPointInWindow)
            default:
                break
            }
        }
        
        func setDidEndPressGesture() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {[weak self] in
                self?.didEndPressGesture()
            }
        }
        
        public override func didEndPressGesture() {
            if let textBubbView = self.bubbleView as? TextBubbleProtocol {
                textBubbView.messageLabel.activeLink = nil
            }
        }
        
        @objc
        private func bubbleLongPressed(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
            let touchPointInWindow = longPressGestureRecognizer.location(in: UIApplication.key)
            switch longPressGestureRecognizer.state {
            case .began:
                self.spotlightBubleView {[weak self] in
                    if let self = self {
                        self.onBubbleLongPressEnded?(self, touchPointInWindow)
                    }
                }
            case .ended, .cancelled:
                break
            default:
                break
            }
        }
        
        final public func spotlightBubleView(completion: (()->Void)? = nil) {
            self.bubbleView.alpha = 0.8
            UIView.animate(withDuration: 0.3 / 1.5, animations: {
                self.bubbleView.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
            }) { _ in
                UIView.animate(withDuration: 0.3 / 2, animations: {
                    self.bubbleView.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
                }) { _ in
                    UIView.animate(withDuration: 0.3 / 2, animations: {
                        self.bubbleView.transform = CGAffineTransform.identity
                        self.bubbleView.alpha = 1.0
                        completion?()
                    })
                }
            }
        }

}

open class MessageCollectionViewCell: UICollectionViewCell {

    // MARK: - Initializers

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /// Handle tap gesture on contentView and its subviews.
    open func handleTapGesture(_ gesture: UIGestureRecognizer) {
        // Should be overridden
    }

    open func handleDoubleTapGesture(_ gesture: UIGestureRecognizer) {
        // Should be overridden
    }
    
    open func handleLongPressGesture(in touchLocation: CGPoint, touchPointInWindow: CGPoint) {
        // Should be overridden
    }
    
    open func didEndPressGesture() {
        // Should be overridden
    }
}
