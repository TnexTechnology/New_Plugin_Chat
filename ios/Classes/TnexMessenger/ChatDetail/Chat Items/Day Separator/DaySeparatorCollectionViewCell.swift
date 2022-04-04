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

class DaySeparatorCollectionViewCell: UICollectionViewCell {

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

    var daySeparatorModel: DaySeparatorModel? {
        didSet {
            if let daySeparatorModel = self.daySeparatorModel {
                if oldValue?.sentDate != daySeparatorModel.sentDate {
                    self.setTextOnLabel(daySeparatorModel.sentDate)
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
        self.label.bounds.size = self.label.sizeThatFits(self.contentView.bounds.size)
        self.label.center.x = self.contentView.center.x
        self.label.frame.origin.y = 0
    }
    
    private func genMessageTimestampLabelAttributedText(sentDate: Date) -> NSAttributedString {
        var dateString: String = sentDate.convertDateToDayString()
        if Calendar.current.isDateInToday(sentDate) {
            dateString = "Hôm nay"
        }
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.fromHex("#808080"), NSAttributedString.Key.paragraphStyle: style])
    }

    deinit {
        print("TimeSeparatorCollectionViewCell deinit")
    }
}

extension Date {
    func convertDateToDayString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "vi_VN") as Locale
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: self)
    }
}
