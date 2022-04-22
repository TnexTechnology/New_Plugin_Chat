//
//  TnexChatDataSource.swift
//  Tnex messenger
//
//  Created by Din Vu Dinh on 27/02/2022.
//

import Foundation
import UIKit
import MatrixSDK

open class TnexChatDataSource: ChatDataSourceProtocol {

    let preferredMaxWindowSize = 500
    
    var eventDic: [String: String] = [:]
    private var events: [MXEvent] = []

    var onDidUpdate: (() -> Void)?
    var slidingWindow: SlidingDataSource<ChatItemProtocol>?
    var room: TnexRoom?
    private var memberDic: [String: MXRoomMember] = [:]
    var lastMessageIdPartnerRead: String?
    var isShowTyping: Bool = false
    var partnerId: String?
    var partnerDisplayName: String?
    
    lazy var typingTracker: TypingTracker = {
        let tracker = TypingTracker()
        tracker.typingCallback = { [weak self] in
            self?.sendTyping()
        }
        tracker.showTypingCallback = { [weak self] isShow in
            self?.showHideTyping(isShow: isShow)
        }
        return tracker
    }()

    public init(roomId: String) {
        if let room = MatrixManager.shared.getRooms()?.first(where: {$0.roomId == roomId}) {
            self.room = room
            self.events = room.events().wrapped.filter({$0.isShowMessage})
            self.loadData()
            self.delegate?.chatDataSourceDidUpdate(self, updateType: .firstLoad)
            getInfoRoom()
            handleEvent()
            getMessagePartnerRead()
        }
    }
    
    func getMessagePartnerRead() {
        for event in events {
            self.room?.getEventReceipts(event.eventId, sorted: true, completion: {[weak self] receipts in
                guard let self = self, receipts.count > 0 else { return }
                self.lastMessageIdPartnerRead = event.eventId
                self.delegate?.chatDataSourceDidUpdate(self, updateType: .firstLoad)
            })
        }
    }
    
    func handleEvent() {
        MatrixManager.shared.handleEvent = {[weak self] event, direction, roomState in
            guard let self = self else { return }
            if self.room?.roomId == event.roomId, event.eventId != nil && !self.checkExistEvent(event: event) {
                let message = self.builderMessage(from: event)
                if event.sender != MatrixManager.shared.userId {
                    self.isShowTyping = false
                    if event.type == kMXEventTypeStringRoomMessage {
                        self.lastMessageIdPartnerRead = event.eventId
                    }
                }
                self.slidingWindow?.insertItem(message, position: .bottom)
                
                self.delegate?.chatDataSourceDidUpdate(self)
                if event.sender != MatrixManager.shared.userId {
                    self.room?.sendReadReceipt(eventId: event.eventId)
                }
            }
        }
    }
    
    func checkExistEvent(event: MXEvent) -> Bool {
        if let clientId = event.clientId, self.eventDic[clientId] != nil {
            return true
        }
        return false
    }
    
    func getDisplayName() -> String {
        return self.room?.summary.displayname ?? ""
    }
    
    func getAvatarURL() -> URL? {
        return self.room?.roomAvatarURL
    }
    
    func getInfoRoom() {
        self.room?.liveTimeline {[weak self] eventTimeline in
            guard let self = self else { return }
            if let members = eventTimeline?.state?.members.members {
                for member in members {
                    self.memberDic[member.userId] = member
                    MatrixManager.shared.memberDic[member.userId] = member
                }
            }
            self.loadData()
            if let eventId =  self.events.last?.eventId {
                self.room?.sendReadReceipt(eventId: eventId)
            }
        }
    }
    
    func loadData() {
        var indexMessage: Int = 0
        let messageCount: Int = events.count
        lazy var mes = self.builderMessage(from: events[0])
        self.slidingWindow = SlidingDataSource(count: messageCount, pageSize: messageCount) { [weak self] () -> ChatItemProtocol in
            guard let self = self else { return mes }
            let index = messageCount - 1 - indexMessage
            let event = self.events[index]
            let message = self.builderMessage(from: event)
            if let msg = message as? DemoTextMessageModel, msg.isIncoming, self.lastMessageIdPartnerRead?.isEmpty ?? true {
                self.lastMessageIdPartnerRead = message.uid
            }
            indexMessage += 1
            return message
        }
    }
        
    func showHideTyping(isShow: Bool) {
        guard self.isShowTyping != isShow else { return }
        print("Show typing status: ....\(isShow)")
        self.isShowTyping = isShow
        self.delegate?.chatDataSourceDidUpdate(self, updateType: .normal)
    }

    public var hasMoreNext: Bool {
        return self.slidingWindow?.hasMore() ?? false
    }

    public var hasMorePrevious: Bool {
        return canLoadMore
//        return self.slidingWindow.hasPrevious()
    }

    public var chatItems: [ChatItemProtocol] {
        return self.slidingWindow?.itemsInWindow ?? []
    }

    weak public var delegate: ChatDataSourceDelegateProtocol?

    public func loadNext() {
        self.slidingWindow?.loadNext()
        self.slidingWindow?.adjustWindow(focusPosition: 1, maxWindowSize: self.preferredMaxWindowSize)
        self.delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }

    var canLoadMore: Bool = true
    public func loadPrevious() {
        guard let topEvent = self.events.first, let _room = self.room else { return }
        self.canLoadMore = false
        room?.paginate(event: topEvent) { [weak self] _ in
            guard let self = self else { return }
            let newEvents = _room.events().wrapped.filter({$0.isShowMessage})
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
        self.room?.send(text: text) {[weak self] _event in
            guard let self = self, let event = _event else { return }
            if event.sentState == MXEventSentStateSending {
                let message = self.builderMessage(from: event)
                self.slidingWindow?.insertItem(message, position: .bottom)
                self.delegate?.chatDataSourceDidUpdate(self)
            } else {
                if let client = event.clientId, let uuid = self.eventDic[client] {
                    let message = self.builderMessage(from: event)
                    self.replaceMessage(withUID: uuid, withNewMessage: message)
                }
            }
        }
    }

    func addPhotoMessage(_ image: UIImage) {
        self.room?.sendImage(image: image) {[weak self] _event in
            guard let self = self, let event = _event else { return }
            if event.sentState == MXEventSentStateSending || event.sentState == MXEventSentStateUploading {
                let message = self.builderMessage(from: event)
                self.slidingWindow?.insertItem(message, position: .bottom)
                self.delegate?.chatDataSourceDidUpdate(self)
            } else {
                if let client = event.clientId, let uuid = self.eventDic[client] {
                    let message = self.builderMessage(from: event)
                    self.replaceMessage(withUID: uuid, withNewMessage: message)
                }
            }
        }
    }
    
    func retryPhotoMessage(message: TnextPhotoMessageModel) {
        removeMessage(eventId: message.uid)
        guard let image = message.mediaItem.image else { return }
        self.addPhotoMessage(image)
    }
    
    func markReadAll() {
        self.room?.markAllAsRead()
        if let eventId = self.events.last?.eventId {
            self.room?.sendReadReceipt(eventId: eventId)
        }
        
    }
    
    func sendTyping() {
        self.room?.sendTypingNotification(typing: true, timeout: 3.0, completion: { response in
            print("Send typing....")
        })
    }
    
    func listenTypingNotifications() {
        self.room?.listen(toEventsOfTypes: ["m.typing", "m.receipt"], onEvent: {[weak self] event, direction, roomState in
            guard let self = self else { return }
            switch event.type {
            case "m.typing":
                if let userIds = event.content["user_ids"] as? [String], !userIds.isEmpty && userIds.first != MatrixManager.shared.userId {
                    self.typingTracker.startShowTypingView()
                }
            case "m.receipt":
                for (key, value) in event.content {
                    if let dic = value as? [String: Any], let readInfo = dic["m.read"] as? [String: Any] {
                        if readInfo.keys.first != MatrixManager.shared.userId {
                            self.lastMessageIdPartnerRead = key
                            self.delegate?.chatDataSourceDidUpdate(self, updateType: .firstLoad)
                        }
                        break
                    }
                }
            default: break
            }
        })
    }

    public func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion:(_ didAdjust: Bool) -> Void) {
        guard let slidingWindow = self.slidingWindow else { return }
        let didAdjust = slidingWindow.adjustWindow(focusPosition: focusPosition, maxWindowSize: preferredMaxCount ?? self.preferredMaxWindowSize)
        completion(didAdjust)
    }

    func replaceMessage(withUID uid: String, withNewMessage newMessage: ChatItemProtocol) {
        guard let slidingWindow = self.slidingWindow else { return }
        let didUpdate = slidingWindow.replaceItem(withNewItem: newMessage) { $0.uid == uid }
        guard didUpdate else { return }
        self.delegate?.chatDataSourceDidUpdate(self)
    }
    
    func removeMessage(eventId: String) {
        guard let index = getIndexMessageId(eventId: eventId) else { return }
        events.remove(at: index)
        if let indexItem = self.slidingWindow?.getIndexItem(where: {$0.uid == eventId}) {
            self.removeMessage(at: indexItem)
        }
        room?.removeOutgoingMessage(eventId)

    }
    
    func getIndexMessageId(eventId: String) -> Int? {
        if let index = self.events.firstIndex(where: {$0.eventId == eventId}) {
            return index
        }
        return nil
    }
    
    func removeMessage(at index: Int) {
        self.slidingWindow?.removeItem(at: index)
        self.delegate?.chatDataSourceDidUpdate(self)
    }
    
    deinit {
        print("Deinit TnexChatDataSource")
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
        return content["clientId"] as? String ?? self.eventId ?? nil
    }
    
    var isShowMessage: Bool {
        if eventId == nil {
            return false
        }
        return self.type == kMXEventTypeStringRoomMessage
//        return self.type != kMXEventTypeStringRoomPowerLevels
//        && self.type != kMXEventTypeStringRoomGuestAccess
//        && self.type != kMXEventTypeStringRoomHistoryVisibility
//        && self.type != kMXEventTypeStringRoomJoinRules
    }
}
