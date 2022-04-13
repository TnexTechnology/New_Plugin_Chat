//
//  ChatUtils.swift
//  tnexchat
//
//  Created by Din Vu Dinh on 05/04/2022.
//

import Foundation

class ChatUtils {
    static func genTextAttributes(viewModel: MessageViewModelProtocol, text: String, messageType: MessageType) -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.1
        let textFontSize: CGFloat = text.isSingleEmoji ? 40.0 : 16.0
        let textFont: UIFont = UIFont(name: "Quicksand-Regular", size: textFontSize) ?? UIFont.systemFont(ofSize: textFontSize)
        let textColor: UIColor = UIColor.white
        return [NSAttributedString.Key.font: textFont, NSAttributedString.Key.foregroundColor: textColor, .paragraphStyle: paragraphStyle, NSAttributedString.Key.kern: -0.46]
    }
    
    static func getAttributeString(text: String, attributes: [NSAttributedString.Key: Any], enabledDetectors: [DetectorType], isIncoming: Bool) -> NSAttributedString {
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: text, attributes: attributes)
//        for detector in enabledDetectors {
//            switch detector {
//            case .mentionRange(let mentionInfo):
//                let attributes = ChatUtils.detectorAttributes(for: detector, isMe: !isIncoming)
//                mentionInfo.forEach { (mention) in
//                    if mention.range.location + mention.range.length <= attributedString.length {
//                        attributedString.addAttributes(attributes, range: mention.range)
//                    } else {
//                        print("invalid mention")
//                    }
//                }
//            case .keySearch(let listRange):
//                let attributes = ChatUtils.detectorAttributes(for: detector, isMe: !isIncoming)
//                listRange.forEach { (range) in
//                    if range.location + range.length <= attributedString.length {
//                        attributedString.addAttributes(attributes, range: range)
//                    } else {
//                        print("invalid listRange")
//                    }
//                }
//
//            default:
//                break
//            }
//        }
        let modifiedText = NSAttributedString(attributedString: attributedString)
        return modifiedText
    }
    
    static func detectorAttributes(for detector: DetectorType, isMe: Bool) -> [NSAttributedString.Key : Any] {
        return [.foregroundColor: UIColor.white, .underlineStyle: NSUnderlineStyle.single.rawValue]
    }
}
