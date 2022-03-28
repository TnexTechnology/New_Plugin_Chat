//
//  ActionMessageType.swift
//  Action
//
//  Created by Gapo on 24/06/2021.
//

import Foundation

public enum ActionMessageType {
    case `default`
    case reply(replyMessage: ReplyMessageType)
    case remove(content: String)
    
    static func ==(lhs: ActionMessageType, rhs: ActionMessageType) -> Bool {
        switch (lhs, rhs) {
        case (.reply(let lhsReplyMessage), .reply(let rhsReplyMessage)):
                return lhsReplyMessage.messageId == rhsReplyMessage.messageId
        case (.default, .default):
            return true
        case (.remove(let lhsContent), .remove(let rhsContent)):
            return lhsContent == rhsContent
        default:
            return false
        }
    }
    
    public var shouldShowIcon: Bool {
        switch self {
            case .reply:
                return true
            default:
                return false
        }
    }
}

public extension ActionMessageType {
    var mediaUrl: String? {
        switch self {
        case .reply(let replyMessage):
            return replyMessage.medias?.first
        default:
            return nil
        }
    }
}

public protocol ReplyMessageType {

    /// The sender of the message.
    var senderId: String { get }

    /// The unique identifier for the message.
    var messageId: String { get }
    
    /// The date the message was sent.
    var sentDate: Date { get }
//
//    /// The kind of message and its underlying kind.
//    var kind: MKMessageKind { get }
    
    /// The cotent the message was sent.
    var content: String { get }
    
    var type: ChatItemType { get }
    
    var thumb: UIImage? { get }
    
    /// The media (photo, video, sticker,...) in the reply message .
    var medias: [String]? { get }
    
}
