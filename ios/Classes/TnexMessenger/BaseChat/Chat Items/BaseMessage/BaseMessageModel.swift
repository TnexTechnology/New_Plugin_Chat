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

public enum MessageStatus {
    case failed
    case sending
    case success
    case uploading
    case normal
}

public protocol MessageModelProtocol: ChatItemProtocol {
    var senderId: String { get }
    var isIncoming: Bool { get }
    var date: Date { get }
    var status: MessageStatus { get }
    var canReply: Bool { get }
    var seenInfo: [String] { get }
    var messageAction: ActionMessageType { get }
}

extension MessageModelProtocol {
    public var canReply: Bool { false }
}

public protocol DecoratedMessageModelProtocol: MessageModelProtocol {
    var messageModel: MessageModelProtocol { get }
}

public extension DecoratedMessageModelProtocol {
    var uid: String {
        return self.messageModel.uid
    }

    var senderId: String {
        return self.messageModel.senderId
    }

    var type: String {
        return self.messageModel.type
    }

    var isIncoming: Bool {
        return self.messageModel.isIncoming
    }

    var date: Date {
        return self.messageModel.date
    }

    var status: MessageStatus {
        return self.messageModel.status
    }
    
    var seenInfo: [String] {
        return self.messageModel.seenInfo
    }
}

open class BaseMessageModel<MessageModelT: MessageModelProtocol>: DecoratedMessageModelProtocol, ContentEquatableChatItemProtocol {
    
    public var messageModel: MessageModelProtocol {
        return self._messageModel
    }
    public let _messageModel: MessageModelT // Can't make messageModel: MessageModelT: https://gist.github.com/diegosanchezr/5a66c7af862e1117b556
    public var canReply: Bool { self.messageModel.canReply }
    public var seenInfo: [String] { self.messageModel.seenInfo }
    public var messageAction: ActionMessageType { self.messageModel.messageAction }
    
    public init(messageModel: MessageModelT) {
        self._messageModel = messageModel
    }
    public func hasSameContent(as anotherItem: ChatItemProtocol) -> Bool {
        guard let item = anotherItem as? MessageModelProtocol else { return false }
        return self.uid == anotherItem.uid
            && self.status == item.status
    }
}
