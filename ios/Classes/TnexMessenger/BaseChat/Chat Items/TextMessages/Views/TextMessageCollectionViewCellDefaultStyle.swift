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

open class TextMessageCollectionViewCellDefaultStyle: TextMessageCollectionViewCellStyleProtocol {
    
    typealias Class = TextMessageCollectionViewCellDefaultStyle

    public struct TextStyle {
        public let font: () -> UIFont
        public let incomingColor: () -> UIColor
        public let outgoingColor: () -> UIColor
        public let incomingInsets: UIEdgeInsets
        public let outgoingInsets: UIEdgeInsets
        public init(
            font: @autoclosure @escaping () -> UIFont,
            incomingColor: @autoclosure @escaping () -> UIColor,
            outgoingColor: @autoclosure @escaping () -> UIColor,
            incomingInsets: UIEdgeInsets,
            outgoingInsets: UIEdgeInsets) {
                self.font = font
                self.incomingColor = incomingColor
                self.outgoingColor = outgoingColor
                self.incomingInsets = incomingInsets
                self.outgoingInsets = outgoingInsets
        }
    }

    public let textStyle: TextStyle
    public let baseStyle: BaseMessageCollectionViewCellDefaultStyle
    public init (
        textStyle: TextStyle = TextMessageCollectionViewCellDefaultStyle.createDefaultTextStyle(),
        baseStyle: BaseMessageCollectionViewCellDefaultStyle = BaseMessageCollectionViewCellDefaultStyle()) {
            self.textStyle = textStyle
            self.baseStyle = baseStyle
    }

    lazy var font: UIFont = self.textStyle.font()
    lazy var incomingColor: UIColor = self.textStyle.incomingColor()
    lazy var outgoingColor: UIColor = self.textStyle.outgoingColor()

    open func textFont(viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIFont {
        if viewModel.text.containsOnlyEmoji {
            return UIFont.systemFont(ofSize: 42)
        }
        return self.font
    }

    open func textColor(viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIColor {
        return viewModel.isIncoming ? self.incomingColor : self.outgoingColor
    }

    open func textInsets(viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIEdgeInsets {
        return viewModel.isIncoming ? self.textStyle.incomingInsets : self.textStyle.outgoingInsets
    }

    open func bubbleMaskLayer(viewModel: MessageViewModelProtocol, isSelected: Bool, frame: CGRect) -> CAShapeLayer? {
        guard frame.size != CGSize.zero else { return nil }
        let roundRect = CGRect(origin: CGPoint.zero, size: frame.size)
        let path = UIBezierPath(
            shouldRoundRect: roundRect,
            topLeftRadius: 8,
            topRightRadius: 8,
            bottomLeftRadius: 8,
            bottomRightRadius: 8
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        return mask
    }
    
    open func bubbleBackgroundColor(viewModel: MessageViewModelProtocol, isSelected: Bool) -> UIColor? {
        if (viewModel as? TextMessageViewModelProtocol)?.text.containsOnlyEmoji == true {
            return UIColor.clear
        }
        let color = viewModel.isIncoming ? self.baseStyle.baseColorIncoming : self.baseStyle.baseColorOutgoing
        switch viewModel.status {
        case .success:
            return color
        case .failed, .sending:
            return color.bma_blendWithColor(UIColor.white.withAlphaComponent(0.70))
        }
    }
}

public extension TextMessageCollectionViewCellDefaultStyle { // Default values

    static func createDefaultTextStyle() -> TextStyle {
        return TextStyle(
            font: UIFont.systemFont(ofSize: 16),
            incomingColor: UIColor.white,
            outgoingColor: UIColor.white,
            incomingInsets: UIEdgeInsets(top: 10, left: 19, bottom: 10, right: 15),
            outgoingInsets: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 19)
        )
    }
}
