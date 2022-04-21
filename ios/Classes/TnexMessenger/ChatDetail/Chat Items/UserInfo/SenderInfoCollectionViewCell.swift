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

import Foundation
import UIKit

class SenderInfoCollectionViewCell: UICollectionViewCell {
    
    private let label: UILabel = UILabel()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        self.label.font = UIFont.systemFont(ofSize: 12)
        self.label.textAlignment = .center
        self.label.textColor = UIColor.fromHex("#808080")
        self.contentView.addSubview(label)
    }
    
    var senderInfoModel: SenderInfoModel? {
        didSet {
//            if let senderInfoModel = self.senderInfoModel {
//                self.label.text = senderInfoModel.displayName
//            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        calculateLayout()
    }
    
    private func calculateLayout() {
        guard let model = self.senderInfoModel else { return }
        if let displayName = model.displayName {
            self.updateUI(displayName: displayName, isIncoming: model.isIncoming)
        } else {
            MatrixManager.shared.getSenderInfo(senderId: model.userId, at: nil) {[weak self] _displayName in
                guard let self = self, let name = _displayName else { return }
                self.updateUI(displayName: name, isIncoming: model.isIncoming)
            }
        }
        
    }
    
    func updateUI(displayName: String, isIncoming: Bool) {
        let messageAttributedText = NSAttributedString(string: displayName)
        let labelSize = SenderInfoCollectionViewCell.labelSize(for: messageAttributedText, considering: self.contentView.bounds.size.width)
        let layoutConstant = BaseMessageCollectionViewCellDefaultStyle.createDefaultLayoutConstants()
        self.label.frame.size = labelSize.bma_outsetBy(dx: 1, dy: 0)
        self.label.center.y = self.contentView.center.y
        if isIncoming == true {
            let leftMargin = layoutConstant.leftMargin + layoutConstant.horizontalInterspacing + 35
            self.label.frame.origin.x = leftMargin
        } else {
            self.label.frame.origin.x = self.contentView.bounds.size.width - labelSize.width - layoutConstant.rightMargin
        }
        self.label.attributedText = messageAttributedText
    }
    
    
    class func labelSize(for attributedText: NSAttributedString?, considering maxWidth: CGFloat) -> CGSize {
        guard let attributed = attributedText else { return CGSize.zero }
        let constraintBox = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let rect = attributed.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral

        return rect.size
    }
    
}
