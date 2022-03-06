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
        switch message.status {
        case .success:
            break
        case .failed:
            self.updateMessage(message, status: .sending)
            self.fakeMessageStatus(message)
        case .sending:
            switch arc4random_uniform(100) % 5 {
            case 0:
                if arc4random_uniform(100) % 2 == 0 {
                    self.updateMessage(message, status: .failed)
                } else {
                    self.updateMessage(message, status: .success)
                }
            default:
                let delaySeconds: Double = Double(arc4random_uniform(1200)) / 1000.0
                let delayTime = DispatchTime.now() + Double(Int64(delaySeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    self.fakeMessageStatus(message)
                }
            }
        }
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
