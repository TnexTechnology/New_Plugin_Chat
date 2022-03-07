//
//  TnexMessageModel.swift
//  tnexchat
//
//  Created by MacOS on 06/03/2022.
//

import Foundation
import MatrixSDK

public class TnexMessageModel: MessageModelProtocol {
    public let uid: String
    public var senderId: String
    public var isIncoming: Bool
    public var date: Date
    public var status: MessageStatus = .success
    public var canReply: Bool = true
    public var type: String
    public let event: MXEvent
    
    public init(event: MXEvent) {
        self.event = event
        self.senderId = event.sender ?? ""
        let isMe = event.sender == APIManager.shared.userId
        self.isIncoming = !isMe
        self.date = event.timestamp
        self.status = event.status
        self.canReply = true
        self.type = event.type
        self.uid = event.eventId
    }
}
