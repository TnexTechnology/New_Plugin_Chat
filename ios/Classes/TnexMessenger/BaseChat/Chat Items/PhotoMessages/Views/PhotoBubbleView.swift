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
import SDWebImage

public protocol PhotoBubbleViewStyleProtocol: BubbleViewStyleProtocol {
    func bubbleSize(viewModel: PhotoMessageViewModelProtocol) -> CGSize
    func overlayColor(viewModel: PhotoMessageViewModelProtocol) -> UIColor?
    func placeholderBackgroundImage(viewModel: PhotoMessageViewModelProtocol) -> UIImage?
}

open class PhotoBubbleView: UIView, MaximumLayoutWidthSpecificable, BackgroundSizingQueryable {

    public var viewContext: ViewContext = .normal
    public var animationDuration: CFTimeInterval = 0.33
    public var preferredMaxLayoutWidth: CGFloat = 0
    private var maskLayer: CAShapeLayer?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        self.autoresizesSubviews = false
        self.addSubview(self.imageView)
    }

    public private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.autoresizingMask = []
        imageView.clipsToBounds = true
        imageView.autoresizesSubviews = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var overlayView: UIView = {
        let view = UIView()
        return view
    }()

    public var photoMessageViewModel: PhotoMessageViewModelProtocol! {
        didSet {
            self.accessibilityIdentifier = self.photoMessageViewModel.bubbleAccessibilityIdentifier
            self.updateViews()
        }
    }

    public var photoMessageStyle: PhotoBubbleViewStyleProtocol! {
        didSet {
            self.updateViews()
        }
    }

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
            UIView.animate(withDuration: self.animationDuration, animations: updateAndRefreshViews, completion: { (_) -> Void in
                completion?()
            })
        } else {
            updateAndRefreshViews()
        }
    }

    open func updateViews() {
        if self.viewContext == .sizing { return }
        if isUpdating { return }
        guard self.photoMessageViewModel != nil, self.photoMessageStyle != nil else { return }
        self.updateImages()
        self.setNeedsLayout()
    }

    private func updateImages() {
        if let image = self.photoMessageViewModel.mediaItem.image {
            self.imageView.image = image
        } else if let urlString = self.photoMessageViewModel.mediaItem.urlString {
            self.imageView.setThumbMessage(url: urlString)
        } else {
            self.imageView.image = self.photoMessageStyle.placeholderBackgroundImage(viewModel: self.photoMessageViewModel)
        }

        if let overlayColor = self.photoMessageStyle.overlayColor(viewModel: self.photoMessageViewModel) {
            self.overlayView.backgroundColor = overlayColor
            self.overlayView.alpha = 1
            if self.overlayView.superview == nil {
                self.imageView.addSubview(self.overlayView)
            }
        } else {
            self.overlayView.alpha = 0
        }
//        self.imageView.layer.mask = .bma_maskLayer(from: self.photoMessageStyle.maskingImage(viewModel: self.photoMessageViewModel))
    }

    // MARK: Layout

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.calculateTextBubbleLayout(maximumWidth: size.width).size
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        let layout = self.calculateTextBubbleLayout(maximumWidth: self.preferredMaxLayoutWidth)
        self.imageView.bma_rect = layout.photoFrame
        // Disables implicit layer animation
        CATransaction.performWithDisabledActions {
            self.imageView.layer.mask?.frame = self.imageView.layer.bounds
        }
        self.overlayView.bma_rect = self.imageView.bounds
        maskLayerBubble()
    }

    private func maskLayerBubble() {
        self.maskLayer?.removeFromSuperlayer()
        if let layer = photoMessageStyle?.bubbleMaskLayer(viewModel: self.photoMessageViewModel, isSelected: false, frame: self.bounds) {
            self.layer.mask = layer
            self.maskLayer = layer
        }
        
    }
    
    private func calculateTextBubbleLayout(maximumWidth: CGFloat) -> PhotoBubbleLayoutModel {
        let layoutContext = PhotoBubbleLayoutModel.LayoutContext(photoMessageViewModel: self.photoMessageViewModel, style: self.photoMessageStyle, containerWidth: maximumWidth)
        let layoutModel = PhotoBubbleLayoutModel(layoutContext: layoutContext)
        layoutModel.calculateLayout()
        return layoutModel
    }

    open var canCalculateSizeInBackground: Bool {
        return true
    }

}

private class PhotoBubbleLayoutModel {
    var photoFrame: CGRect = .zero
    var size: CGSize = .zero

    struct LayoutContext {
        let photoSize: CGSize
        let preferredMaxLayoutWidth: CGFloat
        let isIncoming: Bool

        init(photoSize: CGSize,
             isIncoming: Bool,
             preferredMaxLayoutWidth width: CGFloat) {
            self.photoSize = photoSize
            self.isIncoming = isIncoming
            self.preferredMaxLayoutWidth = width
        }

        init(photoMessageViewModel model: PhotoMessageViewModelProtocol,
             style: PhotoBubbleViewStyleProtocol,
             containerWidth width: CGFloat) {
            self.init(photoSize: style.bubbleSize(viewModel: model),
                      isIncoming: model.isIncoming,
                      preferredMaxLayoutWidth: width)
        }
    }

    let layoutContext: LayoutContext
    init(layoutContext: LayoutContext) {
        self.layoutContext = layoutContext
    }

    func calculateLayout() {
        let photoSize = self.layoutContext.photoSize
        self.photoFrame = CGRect(origin: .zero, size: photoSize)
        self.size = photoSize
    }
}
