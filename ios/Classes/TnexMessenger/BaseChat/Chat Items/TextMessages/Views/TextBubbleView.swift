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

protocol TextBubbleProtocol: class {
    var messageLabel: MessageLabel { get }
    var delegate: MKMessageLabelDelegate? { get set }
}

public protocol BubbleViewStyleProtocol {
    func bubbleMaskLayer(viewModel: MessageViewModelProtocol, isSelected: Bool, frame: CGRect) -> CAShapeLayer?
    func bubbleBackgroundColor(viewModel: MessageViewModelProtocol, isSelected: Bool) -> UIColor?
}

public protocol TextBubbleViewStyleProtocol: BubbleViewStyleProtocol {
    func textBubbleBorderLayer(viewModel: MessageViewModelProtocol, isSelected: Bool, frame: CGRect) -> CAShapeLayer?
    func genTextAttributes(viewModel: MessageViewModelProtocol, text: String, isSelected: Bool) -> NSAttributedString?
    func detectorAttributes(for detector: DetectorType, viewModel: MessageViewModelProtocol, isSelected: Bool) -> [NSAttributedString.Key: Any]
    func getEnabledDetectors(viewModel: MessageViewModelProtocol, text: String, isSelected: Bool) -> [DetectorType]
    func textInsets(viewModel: MessageViewModelProtocol, isSelected: Bool) -> UIEdgeInsets
    func editedAttributedString(viewModel: MessageViewModelProtocol, isSelected: Bool) -> NSAttributedString?
}

public class TextBubbleView: MessageBubbleView, TextBubbleProtocol {

    public var viewContext: ViewContext = .normal {
        didSet {
            if self.viewContext == .sizing {
                self.messageLabel.enabledDetectors = []
            } else {
                self.messageLabel.enabledDetectors = []
            }
        }
    }

    public var style: TextBubbleViewStyleProtocol! {
        didSet {
            self.updateViews()
        }
    }

    var _editedView: UIView?
    public var textMessageViewModel: TextMessageViewModelProtocol! {
        didSet {
            self.accessibilityIdentifier = self.textMessageViewModel.bubbleAccessibilityIdentifier
            self.updateViews()
        }
    }

    public var selected: Bool = false {
        didSet {
            if self.selected != oldValue {
                self.updateViews()
            }
        }
    }
    
    //UI
    public weak var delegate: MKMessageLabelDelegate? {
        didSet {
            messageLabel.delegate = self.delegate
        }
    }
    open lazy var messageLabel: MessageLabel = {
        let label = MessageLabel()
        label.textInsets = MessageConstants.ContentInsets.Text.incomingMessageLabelInsets
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        self.addSubview(self.messageLabel)
    }

    private var maskLayer: CAShapeLayer?
    private var borderLayer: CAShapeLayer?

    public override func updateViews() {
        if self.viewContext == .sizing { return }
        if isUpdating { return }
        self.updateTextView()
        if self.textMessageViewModel.text.isSingleEmoji {
            self.backgroundColor = .clear
        } else {
            self.backgroundColor = self.style.bubbleBackgroundColor(viewModel: self.textMessageViewModel, isSelected: self.selected)
        }
    }

    func updateTextView() {
        guard let style = self.style, let viewModel = self.textMessageViewModel else { return }
        guard let attributedText = style.genTextAttributes(viewModel: viewModel, text: viewModel.text, isSelected: self.selected) else { return }
        if self.messageLabel.attributedText != attributedText {
            let enabledDetectors = style.getEnabledDetectors(viewModel: viewModel, text: viewModel.text, isSelected: self.selected)
            messageLabel.configure {
                messageLabel.enabledDetectors = enabledDetectors
                for detector in enabledDetectors {
                    let attributes = self.style.detectorAttributes(for: detector, viewModel: viewModel, isSelected: self.selected)
                    messageLabel.setAttributes(attributes, detector: detector)
                }
                messageLabel.attributedText = attributedText
            }
        }

        let textInsets = style.textInsets(viewModel: viewModel, isSelected: self.selected)
        if self.messageLabel.textInsets != textInsets { self.messageLabel.textInsets = textInsets }
        self.maskLayerBubble()
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.calculateTextBubbleLayout(preferredMaxLayoutWidth: size.width).size
    }

    // MARK: Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        let layout = self.calculateTextBubbleLayout(preferredMaxLayoutWidth: self.preferredMaxLayoutWidth)
        self.messageLabel.bma_rect = layout.textFrame
        UIView.performWithoutAnimation {
            self._editedView?.bma_rect = layout.editedFrame
        }
        
        self.maskLayerBubble()
    }
    
    func maskLayerBubble() {
        self.maskLayer?.removeFromSuperlayer()
        if let layer = style.bubbleMaskLayer(viewModel: self.textMessageViewModel, isSelected: self.selected, frame: self.bounds) {
           
            self.layer.mask = layer
            self.maskLayer = layer
        }
        self.borderLayer?.removeFromSuperlayer()
        if let borderLayer = style.textBubbleBorderLayer(viewModel: self.textMessageViewModel, isSelected: self.selected, frame: self.bounds) {
            
            self.layer.addSublayer(borderLayer)
            self.borderLayer = borderLayer
        }
    }
    
    public var layoutCache: NSCache<AnyObject, AnyObject>!
    func calculateTextBubbleLayout(preferredMaxLayoutWidth: CGFloat) -> TextBubbleLayoutModel {
        let layoutContext = TextBubbleLayoutModel.LayoutContext(
            text: self.style.genTextAttributes(viewModel: self.textMessageViewModel, text: self.textMessageViewModel.text, isSelected: self.selected)?.string ?? "",
            attributedText: self.style.genTextAttributes(viewModel: self.textMessageViewModel, text: self.textMessageViewModel.text, isSelected: self.selected),
            editedAttributedText: self.style.editedAttributedString(viewModel: self.textMessageViewModel, isSelected: self.selected),
            textInsets: self.style.textInsets(viewModel: self.textMessageViewModel, isSelected: self.selected),
            preferredMaxLayoutWidth: preferredMaxLayoutWidth,
            isIncoming: self.textMessageViewModel.isIncoming
        )

        if let layoutModel = self.layoutCache.object(forKey: layoutContext.hashValue as AnyObject) as? TextBubbleLayoutModel, layoutModel.layoutContext == layoutContext {
            return layoutModel
        }

        let layoutModel = TextBubbleLayoutModel(layoutContext: layoutContext)
        layoutModel.calculateLayout()

        self.layoutCache.setObject(layoutModel, forKey: layoutContext.hashValue as AnyObject)
        return layoutModel
    }
    
}

final class TextBubbleLayoutModel {
    let layoutContext: LayoutContext
    var textFrame: CGRect = CGRect.zero
    var editedFrame: CGRect = CGRect.zero
    var forwardFrame: CGRect = CGRect.zero
    var bubbleFrame: CGRect = CGRect.zero
    var size: CGSize = CGSize.zero

    init(layoutContext: LayoutContext) {
        self.layoutContext = layoutContext
    }

    struct LayoutContext: Equatable, Hashable {
        let text: String
        let attributedText: NSAttributedString?
        let editedAttributedText: NSAttributedString?
        let textInsets: UIEdgeInsets
        let preferredMaxLayoutWidth: CGFloat
        let isIncoming: Bool
    }

    func calculateLayout() {
        let textInsets = self.layoutContext.textInsets
        let textHorizontalInset = textInsets.bma_horziontalInset
        let maxTextWidth = self.layoutContext.preferredMaxLayoutWidth - textHorizontalInset
        guard let attributedText = self.layoutContext.attributedText else { return }
        let textSize = TextBubbleLayoutModel.labelSize(for: attributedText, considering: maxTextWidth)
        if let editedAttribute = self.layoutContext.editedAttributedText {
            self.calculateLayoutWithEditView(editedAttribute: editedAttribute, maxTextWidth: maxTextWidth, textInsets: textInsets, textSize: textSize)
        } else {
            let bubbleSize = textSize.bma_outsetBy(dx: textHorizontalInset, dy: textInsets.bma_verticalInset)
            self.bubbleFrame = CGRect(origin: CGPoint.zero, size: bubbleSize)
            self.textFrame = self.bubbleFrame
            self.editedFrame = .zero
            self.size = bubbleSize
        }
    }
    
    private func calculateLayoutWithEditView(editedAttribute: NSAttributedString, maxTextWidth: CGFloat, textInsets: UIEdgeInsets, textSize: CGSize) {
        let editedSize = TextBubbleLayoutModel.editedSize(for: editedAttribute, considering: maxTextWidth)
        let textBoundSize = textSize.bma_outsetBy(dx: textInsets.bma_horziontalInset, dy: textInsets.bma_verticalInset)
        
        let bubbleSize = CGSize(width: max(textBoundSize.width, editedSize.width + textInsets.bma_horziontalInset), height: textBoundSize.height + editedSize.height + 8)
        self.bubbleFrame = CGRect(origin: CGPoint.zero, size: bubbleSize)
        if self.layoutContext.isIncoming {
            self.textFrame = CGRect(origin: CGPoint.zero, size: textBoundSize)
            editedFrame = CGRect(origin: CGPoint(x: textInsets.left, y: self.textFrame.maxY), size: editedSize)
        } else {
            self.textFrame = CGRect(origin: CGPoint(x: bubbleSize.width - textBoundSize.width, y: 0), size: CGSize(width: bubbleSize.width, height: textBoundSize.height))
            editedFrame = CGRect(origin: CGPoint(x: bubbleSize.width - editedSize.width - textInsets.right, y: self.textFrame.maxY), size: editedSize)
        }
        self.size = bubbleSize
    }
    
    class func labelSize(for attributedText: NSAttributedString, considering maxWidth: CGFloat) -> CGSize {
        let constraintBox = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let rect = attributedText.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral
        return rect.size
    }
    
    class func editedSize(for attributedText: NSAttributedString, considering maxWidth: CGFloat) -> CGSize {
        let heightOfEditView: CGFloat = 16
        let editedIconSize: CGSize = CGSize(width: 12, height: 12)
        let editTextSize = TextBubbleLayoutModel.labelSize(for: attributedText, considering: maxWidth - heightOfEditView)
        let widthOfEditedView = editedIconSize.width + 4 + editTextSize.width
        let editedSize = CGSize(width: widthOfEditedView, height: heightOfEditView)
        return editedSize
    }
    
}

/// UITextView with hacks to avoid selection, loupe, define...
private final class ChatMessageTextView: UITextView {

    override var canBecomeFirstResponder: Bool {
        return false
    }

    // See https://github.com/badoo/Chatto/issues/363
    override var gestureRecognizers: [UIGestureRecognizer]? {
        set {
            super.gestureRecognizers = newValue
        }
        get {
            return super.gestureRecognizers?.filter { gestureRecognizer in
                if #available(iOS 13, *) {
                    return !ChatMessageTextView.notAllowedGestureRecognizerNames.contains(gestureRecognizer.name?.base64String ?? "")
                }
                if #available(iOS 11, *), gestureRecognizer.name?.base64String == SystemGestureRecognizerNames.linkTap.rawValue {
                    return true
                }
                if type(of: gestureRecognizer) == UILongPressGestureRecognizer.self, gestureRecognizer.delaysTouchesEnded {
                    return true
                }
                return false
            }
        }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }

    override var selectedRange: NSRange {
        get {
            return NSRange(location: 0, length: 0)
        }
        set {
            // Part of the heaviest stack trace when scrolling (when updating text)
            // See https://github.com/badoo/Chatto/pull/144
        }
    }

    override var contentOffset: CGPoint {
        get {
            return .zero
        }
        set {
            // Part of the heaviest stack trace when scrolling (when bounds are set)
            // See https://github.com/badoo/Chatto/pull/144
        }
    }

    fileprivate func disableDragInteraction() {
        if #available(iOS 11.0, *) {
            self.textDragInteraction?.isEnabled = false
        }
    }

    fileprivate func disableLargeContentViewer() {
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            self.showsLargeContentViewer = false
        }
        #endif
    }

    private static let notAllowedGestureRecognizerNames: Set<String> = Set([
        SystemGestureRecognizerNames.forcePress.rawValue,
        SystemGestureRecognizerNames.loupe.rawValue
    ])
}

private enum SystemGestureRecognizerNames: String {
    // _UIKeyboardTextSelectionGestureForcePress
    case forcePress = "X1VJS2V5Ym9hcmRUZXh0U2VsZWN0aW9uR2VzdHVyZUZvcmNlUHJlc3M="
    // UITextInteractionNameLoupe
    case loupe = "VUlUZXh0SW50ZXJhY3Rpb25OYW1lTG91cGU="
    // UITextInteractionNameLinkTap
    case linkTap = "VUlUZXh0SW50ZXJhY3Rpb25OYW1lTGlua1RhcA=="
}

private extension String {
    var base64String: String? {
        return self.data(using: .utf8)?.base64EncodedString()
    }
}
