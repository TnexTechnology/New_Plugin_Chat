/*
 MIT License

 Copyright (c) 2017-2019 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit

open class MessageAttributes {
    var addressAttributes: [NSAttributedString.Key: Any] = MessageLabel.defaultAttributes

    var dateAttributes: [NSAttributedString.Key: Any] = MessageLabel.defaultAttributes

    var phoneNumberAttributes: [NSAttributedString.Key: Any] = MessageLabel.defaultAttributes

    var urlAttributes: [NSAttributedString.Key: Any] = MessageLabel.defaultAttributes
    
    var transitInformationAttributes: [NSAttributedString.Key: Any] = MessageLabel.defaultAttributes
    
    var hashtagAttributes: [NSAttributedString.Key: Any] = MessageLabel.defaultAttributes
    
    var mentionAttributes: [NSAttributedString.Key: Any] = MessageLabel.defaultAttributes
    
    var keySearchAttributes: [NSAttributedString.Key: Any] = MessageLabel.defaultAttributes

    var customAttributes: [NSRegularExpression: [NSAttributedString.Key: Any]] = [:]
    
    public func setAttributes(_ attributes: [NSAttributedString.Key: Any], detector: DetectorType) {
        switch detector {
        case .phoneNumber:
            phoneNumberAttributes = attributes
        case .address:
            addressAttributes = attributes
        case .date:
            dateAttributes = attributes
        case .url:
            urlAttributes = attributes
        case .transitInformation:
            transitInformationAttributes = attributes
        case .mentionRange:
            mentionAttributes = attributes
        case .hashtag:
            hashtagAttributes = attributes
        case .custom(let regex):
            customAttributes[regex] = attributes
        case .keySearch(let listRange):
            keySearchAttributes = attributes
        }
    }
    
    func detectorAttributes(for detectorType: DetectorType) -> [NSAttributedString.Key: Any] {
        switch detectorType {
        case .address:
            return addressAttributes
        case .date:
            return dateAttributes
        case .phoneNumber:
            return phoneNumberAttributes
        case .url:
            return urlAttributes
        case .transitInformation:
            return transitInformationAttributes
        case .mentionRange:
            return mentionAttributes
        case .hashtag:
            return hashtagAttributes
        case .keySearch:
            return keySearchAttributes
        case .custom(let regex):
            return customAttributes[regex] ?? MessageLabel.defaultAttributes
        }
    }
    
    func detectorAttributes(for checkingResultType: NSTextCheckingResult.CheckingType) -> [NSAttributedString.Key: Any] {
        switch checkingResultType {
        case .address:
            return addressAttributes
        case .date:
            return dateAttributes
        case .phoneNumber:
            return phoneNumberAttributes
        case .link:
            return urlAttributes
        case .transitInformation:
            return transitInformationAttributes
        default:
            return [:]
        }
    }
}

open class MessageLabel: UILabel {

    // MARK: - Private Properties

    private lazy var layoutManager: NSLayoutManager = {
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(self.textContainer)
        return layoutManager
    }()

    private lazy var textContainer: NSTextContainer = {
        let textContainer = NSTextContainer()
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.size = self.bounds.size
        return textContainer
    }()

    private lazy var textStorage: NSTextStorage = {
        let textStorage = NSTextStorage()
        textStorage.addLayoutManager(self.layoutManager)
        return textStorage
    }()

    internal lazy var rangesForDetectors: [DetectorType: [(NSRange, MessageTextCheckingType)]] = [:]
    
    private var isConfiguring: Bool = false

    // MARK: - Public Properties

    open weak var delegate: MKMessageLabelDelegate?

    open var enabledDetectors: [DetectorType] = [] {
        didSet {
            setTextStorage(attributedText, shouldParse: true)
        }
    }

    open override var attributedText: NSAttributedString? {
        didSet {
            setTextStorage(attributedText, shouldParse: true)
        }
    }

    open override var text: String? {
        didSet {
            setTextStorage(attributedText, shouldParse: true)
        }
    }

    open override var font: UIFont! {
        didSet {
            setTextStorage(attributedText, shouldParse: false)
        }
    }

    open override var textColor: UIColor! {
        didSet {
            setTextStorage(attributedText, shouldParse: false)
        }
    }

    open override var lineBreakMode: NSLineBreakMode {
        didSet {
            textContainer.lineBreakMode = lineBreakMode
            if !isConfiguring { setNeedsDisplay() }
        }
    }

    open override var numberOfLines: Int {
        didSet {
            textContainer.maximumNumberOfLines = numberOfLines
            if !isConfiguring { setNeedsDisplay() }
        }
    }

    open override var textAlignment: NSTextAlignment {
        didSet {
            setTextStorage(attributedText, shouldParse: false)
        }
    }

    open var textInsets: UIEdgeInsets = .zero {
        didSet {
            if !isConfiguring { setNeedsDisplay() }
        }
    }

    open override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += textInsets.horizontal
        size.height += textInsets.vertical
        return size
    }
    
    internal var messageLabelFont: UIFont?

    private var attributesNeedUpdate = false

    public static var defaultAttributes: [NSAttributedString.Key: Any] = {
        return [
            NSAttributedString.Key.foregroundColor: UIColor.darkText,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.underlineColor: UIColor.darkText
        ]
    }()

    open internal(set) var messageAttributes: MessageAttributes = MessageAttributes()

    public func setAttributes(_ attributes: [NSAttributedString.Key: Any], detector: DetectorType) {
        messageAttributes.setAttributes(attributes, detector: detector)
        if isConfiguring {
            attributesNeedUpdate = true
        } else {
            updateAttributes(for: [detector])
        }
    }

    // MARK: - Initializers

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    // MARK: - Open Methods

    open override func drawText(in rect: CGRect) {

        let insetRect = rect.inset(by: textInsets)
        textContainer.size = CGSize(width: insetRect.width, height: rect.height)

        let origin = insetRect.origin
        let range = layoutManager.glyphRange(for: textContainer)

        layoutManager.drawBackground(forGlyphRange: range, at: origin)
        layoutManager.drawGlyphs(forGlyphRange: range, at: origin)
    }

    // MARK: - Public Methods
    
    public func configure(block: () -> Void) {
        isConfiguring = true
        block()
        if attributesNeedUpdate {
            updateAttributes(for: enabledDetectors)
        }
        attributesNeedUpdate = false
        isConfiguring = false
        setNeedsDisplay()
    }
    
    public var modifiedText: NSAttributedString = NSAttributedString(string: "")

    // MARK: - Private Methods

    private func setTextStorage(_ newText: NSAttributedString?, shouldParse: Bool) {

        guard let newText = newText, newText.length > 0 else {
            textStorage.setAttributedString(NSAttributedString())
            setNeedsDisplay()
            return
        }
        let (modifiedText, ranges) = MessageLabel.generateAttributedString(newText, enabledDetectors: enabledDetectors, messageAttributes: messageAttributes, rangesForDetectors: rangesForDetectors, shouldParse: shouldParse)
        
        self.rangesForDetectors = ranges
        textStorage.setAttributedString(modifiedText)
        self.modifiedText = modifiedText
        if !isConfiguring { setNeedsDisplay() }

    }

    private func updateAttributes(for detectors: [DetectorType]) {

        guard let attributedText = attributedText, attributedText.length > 0 else { return }
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)

        for detector in detectors {
            guard let rangeTuples = rangesForDetectors[detector] else { continue }
            for (range, _)  in rangeTuples {
                // This will enable us to attribute it with our own styles, since `UILabel` does not provide link attribute overrides like `UITextView` does
                if detector.textCheckingType == .link {
                    mutableAttributedString.removeAttribute(NSAttributedString.Key.link, range: range)
                }

                let attributes = detectorAttributes(for: detector)
                mutableAttributedString.addAttributes(attributes, range: range)
            }

            let updatedString = NSAttributedString(attributedString: mutableAttributedString)
            textStorage.setAttributedString(updatedString)
        }
    }

    private func detectorAttributes(for detectorType: DetectorType) -> [NSAttributedString.Key: Any] {
        return messageAttributes.detectorAttributes(for: detectorType)
    }

    private func detectorAttributes(for checkingResultType: NSTextCheckingResult.CheckingType) -> [NSAttributedString.Key: Any] {
        return messageAttributes.detectorAttributes(for: checkingResultType)
    }
    
    private func setupView() {
        numberOfLines = 0
        lineBreakMode = .byWordWrapping
    }

    // MARK: - Parsing Text
    
    func getElements(from text: String, with pattern: String, range: NSRange) -> [NSTextCheckingResult]{
        guard let elementRegex = regularExpression(for: pattern) else { return [] }
        return elementRegex.matches(in: text, options: [], range: range)
    }
    
    private var cachedRegularExpressions: [String : NSRegularExpression] = [:]
    private func regularExpression(for pattern: String) -> NSRegularExpression? {
        if let regex = cachedRegularExpressions[pattern] {
            return regex
        } else if let createdRegex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
            cachedRegularExpressions[pattern] = createdRegex
            return createdRegex
        } else {
            return nil
        }
    }

    // MARK: - Gesture Handling

    private func stringIndex(at location: CGPoint) -> Int? {
        guard textStorage.length > 0 else { return nil }

        var location = location

        location.x -= textInsets.left
        location.y -= textInsets.top

        let index = layoutManager.glyphIndex(for: location, in: textContainer)

        let lineRect = layoutManager.lineFragmentUsedRect(forGlyphAt: index, effectiveRange: nil)
        
        var characterIndex: Int?
        
        if lineRect.contains(location) {
            characterIndex = layoutManager.characterIndexForGlyph(at: index)
        }
        
        return characterIndex

    }
    
    typealias SelectedLink = (range: NSRange, type: MessageTextCheckingType)
    var activeLink: SelectedLink? {
        didSet {
            self.didSetActiveLink(activeLink: activeLink, oldValue: oldValue)
        }
    }
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        activeLink = nil
    }
    
    private func didSetActiveLink(activeLink: SelectedLink?, oldValue: SelectedLink?) {
        guard modifiedText.length > 0 else { return }
        guard let range = activeLink?.range ?? oldValue?.range, let fsd = activeLink?.type ?? oldValue?.type else { return }
        var hightlightAttribute = messageAttributes.urlAttributes
        hightlightAttribute[NSAttributedString.Key.foregroundColor] = UIColor.fromHex("#30A960")
        let isActive: Bool = activeLink != nil
        let avtiveAttribute: [NSAttributedString.Key : Any] = isActive ? hightlightAttribute : messageAttributes.urlAttributes
        let mutableAttributedString = NSMutableAttributedString(attributedString: modifiedText)
        mutableAttributedString.addAttributes(avtiveAttribute, range: range)
        let updatedString = NSAttributedString(attributedString: mutableAttributedString)
        textStorage.setAttributedString(updatedString)
        setNeedsDisplay()
    }

  open func handleGesture(_ touchLocation: CGPoint) -> Bool {

        guard let index = stringIndex(at: touchLocation) else { return false }

        for (detectorType, ranges) in rangesForDetectors {
            for (range, value) in ranges {
                if range.contains(index) {
//                    if case .link = value {
//                        self.activeLink = (range, value)
//                    }
                    handleGesture(for: detectorType, value: value)
                    return true
                }
            }
        }
        return false
    }
    
    // swiftlint:disable cyclomatic_complexity
    private func handleGesture(for detectorType: DetectorType, value: MessageTextCheckingType) {
        
        switch value {
        case let .mentionRange(mention):
            guard let text = text else {return}
            let substring = (text as NSString).substring(with: mention.range)
            handleMention(substring, target: mention.target)
        case let .addressComponents(addressComponents):
            var transformedAddressComponents = [String: String]()
            guard let addressComponents = addressComponents else { return }
            addressComponents.forEach { (key, value) in
                transformedAddressComponents[key.rawValue] = value
            }
            handleAddress(transformedAddressComponents)
        case let .phoneNumber(phoneNumber):
            guard let phoneNumber = phoneNumber else { return }
            handlePhoneNumber(phoneNumber)
        case let .date(date):
            guard let date = date else { return }
            handleDate(date)
        case let .link(url):
            guard let url = url else { return }
            handleURL(url)
        case let .transitInfoComponents(transitInformation):
            var transformedTransitInformation = [String: String]()
            guard let transitInformation = transitInformation else { return }
            transitInformation.forEach { (key, value) in
                transformedTransitInformation[key.rawValue] = value
            }
            handleTransitInformation(transformedTransitInformation)
        case let .custom(pattern, match):
            guard let match = match else { return }
            switch detectorType {
            case .hashtag:
                handleHashtag(match)
//            case .mention:
//                handleMention(match)
            default:
                handleCustom(pattern, match: match)
            }
        case let .keySearch:
            break
            
        }
    }
    // swiftlint:enable cyclomatic_complexity
    
    private func handleAddress(_ addressComponents: [String: String]) {
        delegate?.didSelectAddress(addressComponents)
    }
    
    private func handleDate(_ date: Date) {
        delegate?.didSelectDate(date)
    }
    
    private func handleURL(_ url: URL) {
        delegate?.didSelectURL(url)
    }
    
    private func handlePhoneNumber(_ phoneNumber: String) {
        delegate?.didSelectPhoneNumber(phoneNumber)
    }
    
    private func handleTransitInformation(_ components: [String: String]) {
        delegate?.didSelectTransitInformation(components)
    }

    private func handleHashtag(_ hashtag: String) {
        delegate?.didSelectHashtag(hashtag)
    }

    private func handleMention(_ mention: String, target: String) {
        delegate?.didSelectMention(mention, target: target)
    }

    private func handleCustom(_ pattern: String, match: String) {
        delegate?.didSelectCustom(pattern, match: match)
    }

}

internal enum MessageTextCheckingType {
    case addressComponents([NSTextCheckingKey: String]?)
    case date(Date?)
    case phoneNumber(String?)
    case link(URL?)
    case transitInfoComponents([NSTextCheckingKey: String]?)
    case custom(pattern: String, match: String?)
    case mentionRange(mentionInfo: MentionInfo)
    case keySearch(range: NSRange)
}
