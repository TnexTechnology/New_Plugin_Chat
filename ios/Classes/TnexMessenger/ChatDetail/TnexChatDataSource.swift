//
//  TnexChatDataSource.swift
//  Tnex messenger
//
//  Created by Din Vu Dinh on 27/02/2022.
//

import Foundation
import UIKit
import MatrixSDK

class TnexChatDataSource: ChatDataSourceProtocol {

    let preferredMaxWindowSize = 500
    
    var eventDic: [String: String] = [:]
    private var events: [MXEvent] = []

    var onDidUpdate: (() -> Void)?
    var slidingWindow: SlidingDataSource<ChatItemProtocol>!
    var room: TnexRoom!
    private var memberDic: [String: MXRoomMember] = [:]

    init(room: TnexRoom) {
        self.room = room
        self.events = room.events().wrapped
        loadData()
        getInfoRoom()
        handleEvent()
        
    }
    
    func handleEvent() {
        APIManager.shared.handleEvent = {[weak self] event, direction, roomState in
            guard let self = self else { return }
            if self.room.room.roomId == event.roomId, event.eventId != nil {
                let message = self.builderMessage(from: event)
                self.slidingWindow.insertItem(message, position: .bottom)
                self.delegate?.chatDataSourceDidUpdate(self)
            }
        }
    }
    
    func getDisplayName() -> String {
        return self.room.summary.displayname
    }
    
    func getAvatarURL() -> URL? {
        return self.room.roomAvatarURL
    }
    
    func getInfoRoom() {
        self.room.room.liveTimeline {[weak self] eventTimeline in
            guard let self = self else { return }
            if let members = eventTimeline?.state?.members.members {
                for member in members {
                    self.memberDic[member.userId] = member
                    APIManager.shared.memberDic[member.userId] = member
                }
            }
            self.loadData()
        }
    }
    
    
    func loadData() {
        var indexMessage: Int = 0
        let messageCount: Int = events.count
        let mes = self.builderMessage(from: events[0])
        self.slidingWindow = SlidingDataSource(count: messageCount, pageSize: messageCount) { [weak self] () -> ChatItemProtocol in
            guard let self = self else { return mes }
            let index = messageCount - 1 - indexMessage
            let event = self.events[index]
            let message = self.builderMessage(from: event)
            indexMessage += 1
            return message
        }
    }
    
    
    
    lazy var messageSender: DemoChatMessageSender = {
        let sender = DemoChatMessageSender()
        sender.onMessageChanged = { [weak self] (message) in
            guard let sSelf = self else { return }
            sSelf.delegate?.chatDataSourceDidUpdate(sSelf)
        }
        return sender
    }()

    var hasMoreNext: Bool {
        return self.slidingWindow.hasMore()
    }

    var hasMorePrevious: Bool {
        return canLoadMore
//        return self.slidingWindow.hasPrevious()
    }

    var chatItems: [ChatItemProtocol] {
        return self.slidingWindow.itemsInWindow
    }

    weak var delegate: ChatDataSourceDelegateProtocol?

    func loadNext() {
        self.slidingWindow.loadNext()
        self.slidingWindow.adjustWindow(focusPosition: 1, maxWindowSize: self.preferredMaxWindowSize)
        self.delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }

    var canLoadMore: Bool = true
    func loadPrevious() {
//        self.slidingWindow.loadPrevious()
//        self.slidingWindow.adjustWindow(focusPosition: 0, maxWindowSize: self.preferredMaxWindowSize)
//        self.delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
        guard let topEvent = self.events.first else { return }
        self.canLoadMore = false
        APIManager.shared.paginate(room: self.room, event: topEvent) {[weak self] in
            guard let self = self else { return }
            let newEvents = self.room.events().wrapped
            if self.events.count < newEvents.count {
                self.canLoadMore = true
                self.events = newEvents
                self.loadData()
                self.delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
            } else {
                self.canLoadMore = false
            }
            
        }
    }

    func addTextMessage(_ text: String) {
        self.room.send(text: text) {[weak self] _event in
            if let self = self, let event = _event {
                
                if event.sentState == MXEventSentStateSending {
                    let message = self.builderMessage(from: event)
                    self.slidingWindow.insertItem(message, position: .bottom)
                    self.delegate?.chatDataSourceDidUpdate(self)
                } else {
                    if let client = event.clientId, let uuid = self.eventDic[client] {
                        let message = self.builderMessage(from: event)
                        self.replaceMessage(withUID: uuid, withNewMessage: message)
                    }
                    
                }
                
                
            }
        }
//        let message = DemoChatMessageFactory.makeTextMessage(uid, text: text, isIncoming: false)
        
        
    }

    func addPhotoMessage(_ image: UIImage) {
        self.room.sendImage(image: image)
//        let uid = "\(self.nextMessageId)"
//        self.nextMessageId += 1
//        let message = DemoChatMessageFactory.makePhotoMessage(uid, image: image, size: image.size, isIncoming: false)
//        self.messageSender.sendMessage(message)
//        self.slidingWindow.insertItem(message, position: .bottom)
//        self.delegate?.chatDataSourceDidUpdate(self)
    }

    func removeRandomMessage() {
        self.slidingWindow.removeRandomItem()
        self.delegate?.chatDataSourceDidUpdate(self)
    }

    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion:(_ didAdjust: Bool) -> Void) {
        let didAdjust = self.slidingWindow.adjustWindow(focusPosition: focusPosition, maxWindowSize: preferredMaxCount ?? self.preferredMaxWindowSize)
        completion(didAdjust)
    }

    func replaceMessage(withUID uid: String, withNewMessage newMessage: ChatItemProtocol) {
        let didUpdate = self.slidingWindow.replaceItem(withNewItem: newMessage) { $0.uid == uid }
        guard didUpdate else { return }
        self.delegate?.chatDataSourceDidUpdate(self)
    }
}

extension MXEvent {
    var status: MessageStatus {
        switch self.sentState {
        case MXEventSentStateSent:
            return .success
        case MXEventSentStateSending:
            return .sending
        case MXEventSentStateFailed:
            return .failed
        default:
            return .failed
        }
    }
    
    var clientId: String? {
        return content["clientId"] as? String
    }
}
