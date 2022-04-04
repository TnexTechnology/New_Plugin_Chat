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

class TimeSeparatorCollectionViewCell: UICollectionViewCell {

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

    var timeSeparatorModel: TimeSeparatorModel? {
        didSet {
            if let timeSeparatorModel = self.timeSeparatorModel {
                if oldValue?.sentDate != timeSeparatorModel.sentDate {
                    self.setTextOnLabel(timeSeparatorModel.sentDate)
                }
            }
            
        }
    }

    private func setTextOnLabel(_ date: Date) {
        self.label.attributedText = self.genMessageTimestampLabelAttributedText(sentDate: date)
        self.setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        calculateLayout()
    }
    
    private func calculateLayout() {
        guard let model = self.timeSeparatorModel else { return }
        let messageAttributedText = genMessageTimestampLabelAttributedText(sentDate: model.sentDate)
        let labelSize = SenderInfoCollectionViewCell.labelSize(for: messageAttributedText, considering: self.contentView.bounds.size.width)
        let layoutConstant = BaseMessageCollectionViewCellDefaultStyle.createDefaultLayoutConstants()
        self.label.frame.size = labelSize
        self.label.center.y = self.contentView.center.y
        if model.isIncoming == true {
            let leftMargin = layoutConstant.leftMargin + layoutConstant.horizontalInterspacing + 30
            self.label.frame.origin.x = leftMargin
        } else {
            self.label.frame.origin.x = self.contentView.bounds.size.width - labelSize.width - layoutConstant.rightMargin
        }
        if  self.label.attributedText != messageAttributedText {
            self.label.attributedText = messageAttributedText
        }
    }
    
    private func genMessageTimestampLabelAttributedText(sentDate: Date) -> NSAttributedString {
        let time: Int = Int(Date().timeIntervalSince1970 - sentDate.timeIntervalSince1970)
        let dateString: String = time.toTimeActive()
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        return NSAttributedString(string: "\(dateString)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.fromHex("#808080"), NSAttributedString.Key.paragraphStyle: style])
    }

    deinit {
        print("TimeSeparatorCollectionViewCell deinit")
    }
}
