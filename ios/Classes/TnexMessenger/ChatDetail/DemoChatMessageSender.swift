//
//  DemoChatMessageSender.swift
//  Tnex messenger
//
//  Created by Din Vu Dinh on 27/02/2022.
//

import Foundation
import UIKit

public protocol TnexMessageModelProtocol: MessageModelProtocol, ContentEquatableChatItemProtocol {
    var status: MessageStatus { get set }
    var clientId: String? { get }
    var senderName: String? { get }
    var senderAvatarUrl: String { get }
}

public extension TnexMessageModelProtocol {
    var senderAvatarUrl: String {
        return senderId.getAvatarUrl()
    }
    
}

//extension TnexMessageModelProtocol where Self: BaseMessageModel<TnexMessageModel> {
//    public var clientId: String? {
//        return messageModel.event.clientId
//    }
//    
//    public var senderName: String? {
//        return messageModel.event.content(valueFor: "displayname")
//    }
//}

public class DemoChatMessageSender {

    public var onMessageChanged: ((_ message: TnexMessageModelProtocol) -> Void)?

    public func sendMessages(_ messages: [TnexMessageModelProtocol]) {
        for message in messages {
            self.fakeMessageStatus(message)
        }
    }

    public func sendMessage(_ message: TnexMessageModelProtocol) {
        self.fakeMessageStatus(message)
    }

    private func fakeMessageStatus(_ message: TnexMessageModelProtocol) {
        //
    }

    func updateMessage(_ message: TnexMessageModelProtocol, status: MessageStatus) {
        if message.status != status {
            message.status = status
            self.notifyMessageChanged(message)
        }
    }

    private func notifyMessageChanged(_ message: TnexMessageModelProtocol) {
        self.onMessageChanged?(message)
    }
}
