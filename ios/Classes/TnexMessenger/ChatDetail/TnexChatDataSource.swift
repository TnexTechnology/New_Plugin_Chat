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

    var onDidUpdate: (() -> Void)?
    var slidingWindow: SlidingDataSource<ChatItemProtocol>!
    var room: TnexRoom!
    private var memberDic: [String: MXRoomMember] = [:]

    init(room: TnexRoom) {
        self.room = room
        var indexMessage: Int = 0
        let messageCount: Int = room.events().wrapped.count
        let mes = self.makePhotoMessage(event: room.events().wrapped[0])
        self.slidingWindow = SlidingDataSource(count: messageCount, pageSize: 20) { [weak self] () -> ChatItemProtocol in
            guard let sSelf = self else { return mes }
            let index = messageCount - 1 - indexMessage
            let event = room.events().wrapped[index]
            let message = event.isMediaAttachment() ? sSelf.makePhotoMessage(event: event) : sSelf.makeTnexMessage(event: event)
            indexMessage += 1
            return message
        }
        getInfoRoom()
        
//        APIManager.shared.handleEvent = {[weak self] event, direction, roomState in
//            guard let sSelf = self else { return }
//            if room.room.roomId == event.roomId, event.eventId != nil {
//                let message = event.isMediaAttachment() ? sSelf.makePhotoMessage(event: event) : sSelf.makeTnexMessage(event: event)
//                sSelf.slidingWindow.insertItem(message, position: .bottom)
//                sSelf.delegate?.chatDataSourceDidUpdate(sSelf)
//            }
//        }
    }

    init(messages: [ChatItemProtocol], pageSize: Int) {
        self.slidingWindow = SlidingDataSource(items: messages, pageSize: pageSize)
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
        let messageCount: Int = room.events().wrapped.count
        let mes = self.makePhotoMessage(event: room.events().wrapped[0])
        self.slidingWindow = SlidingDataSource(count: messageCount, pageSize: 20) { [weak self] () -> ChatItemProtocol in
            guard let sSelf = self else { return mes }
            let index = messageCount - 1 - indexMessage
            let event = sSelf.room.events().wrapped[index]
            let message = event.isMediaAttachment() ? sSelf.makePhotoMessage(event: event) : sSelf.makeTnexMessage(event: event)
            indexMessage += 1
            return message
        }
    }
    
    private func makeTnexMessage(event: MXEvent) -> DemoMessageModelProtocol {
        let isMe = event.sender == APIManager.shared.userId
        let messageModel = self.makeMessageModel(uid: event.eventId, senderId: event.sender, isIncoming: !isMe, type: TextMessageModel<MessageModel>.chatItemType, status: event.status, date: event.timestamp)
        let textMessageModel = DemoTextMessageModel(messageModel: messageModel, text: getText(event: event))
        textMessageModel.clientId = event.clientId
        if let client = event.clientId {
            eventDic[client] = event.eventId
        }
        
        return textMessageModel
    }
    
    private func getText(event: MXEvent) -> String {
        if !event.isEdit() {
            if let newContent = event.content["text"] as? String {
                return newContent.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return (event.content["body"] as? String).map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            } ?? "Tin nhan khong ho tro"
        } else {
            let newContent = event.content["m.new_content"]! as? NSDictionary
            return (newContent?["body"] as? String).map {
                    $0.trimmingCharacters(in: .whitespacesAndNewlines)
                } ?? event.type
            
        }
    }
    
    private func makeMessageModel(uid: String, senderId: String, isIncoming: Bool, type: String, status: MessageStatus, date: Date) -> MessageModel {
        return MessageModel(
            uid: uid,
            senderId: senderId,
            type: type,
            isIncoming: isIncoming,
            date: date,
            status: status,
            canReply: true
        )
    }
    
    func makePhotoMessage(event: MXEvent) -> DemoPhotoMessageModel {
        let isMe = event.sender == APIManager.shared.userId
        var imageSize: CGSize = CGSize(width: 200, height: 200)
        if let info: [String: Any] = event.content(valueFor: "info") {
            if let width = info["w"] as? Double,
                let height = info["h"] as? Double {
                imageSize = CGSize(width: width, height: height)
            }
        }
        let messageModel = self.makeMessageModel(uid: event.eventId, senderId: event.sender, isIncoming: !isMe, type: PhotoMessageModel<MessageModel>.chatItemType, status: event.status, date: event.timestamp)
        let mediaURLs = event.getMediaURLs().compactMap(MXURL.init)
        let urls: [URL] = mediaURLs.compactMap { mediaURL in
            mediaURL.contentURL(on: URL(string: "https://chat-matrix.tnex.com.vn")!)
            }
        let photoItem = TnexMediaItem(imageSize: imageSize, image: nil, urlString: urls.first?.absoluteString)
        let photoMessageModel = DemoPhotoMessageModel(messageModel: messageModel, mediaItem: photoItem)
        photoMessageModel.clientId = event.clientId
        if let client = event.clientId {
            eventDic[client] = event.eventId
        }
        return photoMessageModel
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
        return self.slidingWindow.hasPrevious()
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

    func loadPrevious() {
        self.slidingWindow.loadPrevious()
        self.slidingWindow.adjustWindow(focusPosition: 0, maxWindowSize: self.preferredMaxWindowSize)
        self.delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }

    func addTextMessage(_ text: String) {
        self.room.send(text: text) {[weak self] _event in
            if let self = self, let event = _event {
                
                if event.sentState == MXEventSentStateSending {
                    let message = self.makeTnexMessage(event: event)
                    self.slidingWindow.insertItem(message, position: .bottom)
                    self.delegate?.chatDataSourceDidUpdate(self)
                } else {
                    if let client = event.clientId, let uuid = self.eventDic[client] {
                        let message = self.makeTnexMessage(event: event)
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
