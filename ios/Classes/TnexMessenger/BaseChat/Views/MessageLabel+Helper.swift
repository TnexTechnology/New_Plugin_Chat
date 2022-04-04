//
//  MessageLabel+Helper.swift
//  MessageKit
//
//  Created by toandk on 5/10/21.
//

import Foundation

extension MessageLabel {
    
    static func generateAttributedString(_ newText: NSAttributedString, enabledDetectors: [DetectorType], messageAttributes: MessageAttributes, rangesForDetectors: [DetectorType: [(NSRange, MessageTextCheckingType)]], shouldParse: Bool = true) -> (NSAttributedString, [DetectorType: [(NSRange, MessageTextCheckingType)]]) {
        let style = paragraphStyle(for: newText)
        let range = NSRange(location: 0, length: newText.length)
        
        let mutableText = NSMutableAttributedString(attributedString: newText)
        mutableText.addAttribute(.paragraphStyle, value: style, range: range)
        
        var rangesForDetectors = rangesForDetectors
        if shouldParse {
            rangesForDetectors.removeAll()
            let results = parse(text: mutableText, enabledDetectors: enabledDetectors)
            rangesForDetectors = MessageLabel.setRangesForDetectors(in: results, ranges: rangesForDetectors, text: newText.string)
           
            var listMentionRanges: [NSRange] = []
            //Mention Config
            if let mention = enabledDetectors.filter({ $0.isMention }).first{
                if case DetectorType.mentionRange(let mentionInfo) = mention {
                    var ranges = rangesForDetectors[mention] ?? []
                    mentionInfo.forEach { (men) in
                        if men.range.location + men.range.length <= mutableText.length {
                            let tuple: (NSRange, MessageTextCheckingType) = (men.range, .mentionRange(mentionInfo: men))
                            listMentionRanges.append(men.range)
                            ranges.append(tuple)
                        }
                    }
                    rangesForDetectors.updateValue(ranges, forKey: mention)
                }
            }
            //Key search
            if let keySearch = enabledDetectors.filter({ $0.isKeySearch }).first{
                if case DetectorType.keySearch(let listRanges) = keySearch {
                    var ranges = rangesForDetectors[keySearch] ?? []
                    listRanges.forEach { (range) in
                        if range.location + range.length <= mutableText.length && !MessageLabel.checkRangeInRanges(rangeCheck: range, listRanges: listMentionRanges) {
                            let tuple: (NSRange, MessageTextCheckingType) = (range, .keySearch(range: range))
                            ranges.append(tuple)
                        }
                    }
                    rangesForDetectors.updateValue(ranges, forKey: keySearch)
                }
            }
            
        }
                
        for (detector, rangeTuples) in rangesForDetectors {
            if enabledDetectors.contains(detector) {
                let attributes = messageAttributes.detectorAttributes(for: detector)
                rangeTuples.forEach { (range, _) in
                    mutableText.addAttributes(attributes, range: range)
                }
            }
        }

        let modifiedText = NSAttributedString(attributedString: mutableText)
        return (modifiedText, rangesForDetectors)
    }
    
    static func checkRangeInRanges(rangeCheck: NSRange, listRanges: [NSRange]) -> Bool {
        for range in listRanges {
            if rangeCheck.location >= range.location && rangeCheck.location <= range.location + range.length {
                return true
            }
        }
        return false
    }
    static func paragraphStyle(for text: NSAttributedString, lineBreakMode: NSLineBreakMode = .byWordWrapping, textAlignment: NSTextAlignment = .left) -> NSParagraphStyle {
        guard text.length > 0 else { return NSParagraphStyle() }
        
        var range = NSRange(location: 0, length: text.length)
        let existingStyle = text.attribute(.paragraphStyle, at: 0, effectiveRange: &range) as? NSMutableParagraphStyle
        let style = existingStyle ?? NSMutableParagraphStyle()
        
        style.lineBreakMode = lineBreakMode
        style.alignment = textAlignment
        
        return style
    }
    
    static func parse(text: NSAttributedString, enabledDetectors: [DetectorType]) -> [NSTextCheckingResult] {
        guard enabledDetectors.isEmpty == false else { return [] }
        let range = NSRange(location: 0, length: text.length)
        var matches = [NSTextCheckingResult]()

        // Get matches of all .custom DetectorType and add it to matches array
        let regexs = enabledDetectors
            .filter { $0.isCustom }
            .map { parseForMatches(with: $0, in: text, for: range) }
            .joined()
        matches.append(contentsOf: regexs)
        // Get all Checking Types of detectors, except for .custom because they contain their own regex
        let detectorCheckingTypes = enabledDetectors
            .filter { (!$0.isCustom && !$0.isMention) }
            .reduce(0) { $0 | $1.textCheckingType.rawValue }
        if detectorCheckingTypes > 0, let detector = try? NSDataDetector(types: detectorCheckingTypes) {
            let detectorMatches = detector.matches(in: text.string, options: [], range: range)
            matches.append(contentsOf: detectorMatches)
        }

        guard enabledDetectors.contains(.url) else {
            return matches
        }

        // Enumerate NSAttributedString NSLinks and append ranges
        var results: [NSTextCheckingResult] = matches

        text.enumerateAttribute(NSAttributedString.Key.link, in: range, options: []) { value, range, _ in
            guard let url = value as? URL else {
                if let urlString = value as? String, let newUrl = URL(string: urlString) {
                    let result = NSTextCheckingResult.linkCheckingResult(range: range, url: newUrl)
                    results.append(result)
                }
                return
                
            }
            let result = NSTextCheckingResult.linkCheckingResult(range: range, url: url)
            results.append(result)
        }

        return results
    }

    private static func parseForMatches(with detector: DetectorType, in text: NSAttributedString, for range: NSRange) -> [NSTextCheckingResult] {
        switch detector {
        case .custom(let regex):
            return regex.matches(in: text.string, options: [], range: range)
        default:
            fatalError("You must pass a .custom DetectorType")
        }
    }
    
    private static func setRangesForDetectors(in checkingResults: [NSTextCheckingResult], ranges: [DetectorType: [(NSRange, MessageTextCheckingType)]], text: String?) -> [DetectorType: [(NSRange, MessageTextCheckingType)]] {
        guard checkingResults.isEmpty == false else { return ranges }
        var rangesForDetectors = ranges
        
        for result in checkingResults {

            switch result.resultType {
            case .address:
                var ranges = rangesForDetectors[.address] ?? []
                let tuple: (NSRange, MessageTextCheckingType) = (result.range, .addressComponents(result.addressComponents))
                ranges.append(tuple)
                rangesForDetectors.updateValue(ranges, forKey: .address)
            case .date:
                var ranges = rangesForDetectors[.date] ?? []
                let tuple: (NSRange, MessageTextCheckingType) = (result.range, .date(result.date))
                ranges.append(tuple)
                rangesForDetectors.updateValue(ranges, forKey: .date)
            case .phoneNumber:
                var ranges = rangesForDetectors[.phoneNumber] ?? []
                let tuple: (NSRange, MessageTextCheckingType) = (result.range, .phoneNumber(result.phoneNumber))
                ranges.append(tuple)
                rangesForDetectors.updateValue(ranges, forKey: .phoneNumber)
            case .link:
                var ranges = rangesForDetectors[.url] ?? []
                let tuple: (NSRange, MessageTextCheckingType) = (result.range, .link(result.url))
                ranges.append(tuple)
                rangesForDetectors.updateValue(ranges, forKey: .url)
            case .transitInformation:
                var ranges = rangesForDetectors[.transitInformation] ?? []
                let tuple: (NSRange, MessageTextCheckingType) = (result.range, .transitInfoComponents(result.components))
                ranges.append(tuple)
                rangesForDetectors.updateValue(ranges, forKey: .transitInformation)
            case .regularExpression:
                guard let text = text, let regex = result.regularExpression, let range = Range(result.range, in: text) else { return rangesForDetectors }
                let detector = DetectorType.custom(regex)
                var ranges = rangesForDetectors[detector] ?? []
                let tuple: (NSRange, MessageTextCheckingType) = (result.range, .custom(pattern: regex.pattern, match: String(text[range])))
                ranges.append(tuple)
                rangesForDetectors.updateValue(ranges, forKey: detector)
            default:
                fatalError("Received an unrecognized NSTextCheckingResult.CheckingType")
            }
        }
        return rangesForDetectors
    }
}
