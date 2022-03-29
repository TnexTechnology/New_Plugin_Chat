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
        if let room = APIManager.shared.getRooms()?.first(where: {$0.room.roomId == roomId}) {
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
            self.room?.room.getEventReceipts(event.eventId, sorted: true, completion: {[weak self] receipts in
                guard let self = self, receipts.count > 0 else { return }
                self.lastMessageIdPartnerRead = event.eventId
                print(self.getText(event: event))
                self.delegate?.chatDataSourceDidUpdate(self, updateType: .firstLoad)
            })
        }
    }
    
    func handleEvent() {
        APIManager.shared.handleEvent = {[weak self] event, direction, roomState in
            guard let self = self else { return }
            if self.room?.room.roomId == event.roomId, event.eventId != nil && !self.checkExistEvent(eventId: event.eventId) {
                let message = self.builderMessage(from: event)
                self.slidingWindow?.insertItem(message, position: .bottom)
                self.delegate?.chatDataSourceDidUpdate(self)
            }
        }
    }
    
    func checkExistEvent(eventId: String) -> Bool {
        for (_, value) in self.eventDic {
            if value == eventId {
                return true
            }
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
        self.room?.room.liveTimeline {[weak self] eventTimeline in
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
    
    func showHideTyping(isShow: Bool) {
        print("Show before typing status: ....\(isShow)")
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
        APIManager.shared.paginate(room: _room, event: topEvent) {[weak self] in
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
            if let self = self, let event = _event {
                
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
    }

    func addPhotoMessage(_ image: UIImage) {
        self.room?.sendImage(image: image) {[weak self] _event in
            if let self = self, let event = _event {
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
    }
    
    func markReadAll() {
        self.room?.room.summary.markAllAsRead()
    }
    
    func sendTyping() {
        self.room?.room.sendTypingNotification(typing: true, timeout: 3.0, completion: { response in
            print("Send typing....")
        })
    }
    
    func listenTypingNotifications() {
        self.room?.room.listen(toEventsOfTypes: ["m.typing"], onEvent: {[weak self] event, direction, roomState in
            print("Is typing......")
            print(event.sender ?? "hic")
            print(self?.room?.room.typingUsers)
            self?.typingTracker.startShowTypingView()
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
    
    var isShowMessage: Bool {
        if eventId == nil {
            return false
        }
        return self.type != kMXEventTypeStringRoomPowerLevels
        && self.type != kMXEventTypeStringRoomGuestAccess
        && self.type != kMXEventTypeStringRoomHistoryVisibility
        && self.type != kMXEventTypeStringRoomJoinRules
    }
}
