//
//  TnexRoom.swift
//  Tnex messenger
//
//  Created by MacOS on 27/02/2022.
//

import Foundation
import MatrixSDK

let CUSTOMER_SUPPORT_MATRIX_USER_ID =
    "fb61917e-e6c8-40b4-9304-6ecc74c5fe74"
let CUSTOMER_SUPPORT_MATRIX_USER_NAME = "Supporter"


public struct RoomItem: Codable, Hashable {
    public static func == (lhs: RoomItem, rhs: RoomItem) -> Bool {
        return lhs.displayName == rhs.displayName &&
          lhs.roomId == rhs.roomId
    }

    public let roomId: String
    public let displayName: String
    public let messageDate: UInt64

    public init(room: MXRoom) {
        self.roomId = room.summary.roomId
        self.displayName = room.summary.displayname ?? ""
        self.messageDate = room.summary.lastMessage.originServerTs
    }
}

public class TnexRoom {
    
    private var room: MXRoom
    public var summary: TnexRoomSummary
    var listenReferenceRoom: Any?
    
    public var roomAvatarUrl: String? {
        guard let client = MatrixManager.shared.mxRestClient,
              let homeserver = URL(string: client.homeserver),
              let avatar = room.summary.avatar else { return nil }
        return MXURL(mxContentURI: avatar)?.contentURL(on: homeserver)?.absoluteString ?? self.getAvatarUrl()
    }
    
    internal var eventCache: [MXEvent] = []

    public var isDirect: Bool {
        room.isDirect
    }
    
    public var roomId: String {
        return self.room.roomId
    }

    public var lastMessage: String {
        if summary.membership == .invite {
            let inviteEvent = eventCache.last {
                $0.type == kMXEventTypeStringRoomMember && $0.stateKey == room.mxSession.myUserId
            }
            guard let sender = inviteEvent?.sender else { return "" }
            return "Invitation from: \(sender)"
        }

        let lastMessageEvent = getLastEvent()
        if lastMessageEvent?.isMediaAttachment() == true {
            return "đã gửi một tấm hình"
        }
        if lastMessageEvent?.isEdit() ?? false {
            let newContent = lastMessageEvent?.content["m.new_content"]! as? NSDictionary
            return newContent?["body"] as? String ?? ""
        } else {
            return lastMessageEvent?.content["body"] as? String ?? ""
        }
    }
    
    public func getLastEvent() -> MXEvent? {
        return eventCache.last {
            $0.type == kMXEventTypeStringRoomMessage
        }
    }

    public init(_ room: MXRoom) {
        self.room = room
        self.summary = TnexRoomSummary(room.summary)
        let enumerator = room.enumeratorForStoredMessages//WithType(in: Self.displayedMessageTypes)
        let currentBatch = enumerator?.nextEventsBatch(200, threadId: nil) ?? []
        print("Got \(currentBatch.count) events.")
        self.eventCache.append(contentsOf: currentBatch)
    }

    public func add(event: MXEvent, direction: MXTimelineDirection, roomState: MXRoomState?) {
        switch direction {
        case .backwards:
            self.eventCache.insert(event, at: 0)
        case .forwards:
            self.eventCache.append(event)
        @unknown default:
            assertionFailure("Unknown direction value")
        }
    }

    public func events() -> EventCollection {
        return EventCollection(eventCache + room.outgoingMessages())
    }

    // MARK: Sending Events

    public func send(text: String, completion: @escaping(_ event: MXEvent?) -> Void) {
        guard !text.isEmpty else { return }
        let messageContent: [String: Any] = [MessageConstants.messageBodyKey: text, MessageConstants.messageTypeKey: MessageType.text.key, "clientId": UUID().uuidString]
        self.sendMessage(content: messageContent, completion: completion)
    }
    
    public func sendMessage(content: [String: Any], completion: @escaping(_ event: MXEvent?) -> Void) {
        var localEcho: MXEvent? = nil {
            didSet {
                completion(localEcho)
            }
        }
        room.sendMessage(withContent: content, localEcho: &localEcho) { response in
            print("Da gui tin nhan")
            switch response {
            case .success:
                localEcho?.sentState = MXEventSentStateSent
                completion(localEcho)
            case .failure:
                localEcho?.sentState = MXEventSentStateFailed
                completion(localEcho)
            }
        }
    }

    public func edit(text: String, eventId: String) {
        guard !text.isEmpty else { return }

//        var localEcho: MXEvent? = nil
//        // swiftlint:disable:next force_try
//        let content = try! EditEvent(eventId: eventId, text: text).encodeContent()
//        // TODO: Use localEcho to show sent message until it actually comes back
//        room.sendMessage(withContent: content, localEcho: &localEcho) { _ in }
    }

    public func sendImageTest(image: UIImage, completion: @escaping(_ event: MXEvent?) -> Void) {
//        NetworkManager.shared.createImageContent(image: image) {[weak self] content in
//            guard let content = content, let self = self else {
//                return
//            }
//            self.sendMessage(content: content, completion: completion)
//        }
        var localEcho: MXEvent? = nil {
            didSet {
                completion(localEcho)
            }
        }
        guard let imageData = image.jpegData(compressionQuality: 1) else { return }
        let uploader = MXMediaManager.prepareUploader(withMatrixSession: room.mxSession, initialRange: 0, andRange: 1.0)
        let fakeMediaURI = uploader?.uploadId
        let cacheFilePath: String = MXMediaManager.cachePath(forMatrixContentURI: fakeMediaURI!, andType: "image/jpeg", inFolder: room.roomId)
        MXMediaManager.writeMediaData(imageData, toFilePath: cacheFilePath)
        
        room.sendImage(
            data: imageData,
            size: image.size,
            mimeType: "image/jpeg",
            thumbnail: image,
            blurhash: nil,
            localEcho: &localEcho
        ) { response in
            switch response {
            case .failure(let error):
                print("Loi khong gui duoc: \(error.localizedDescription)")
                localEcho?.sentState = MXEventSentStateFailed
                completion(localEcho)
            case .success(let eventId):
                print("eventId: \(eventId ?? "")")
                localEcho?.sentState = MXEventSentStateSent
                completion(localEcho)
            }
        }
    }
    
    public func sendImage(image: UIImage, completion: @escaping(_ event: MXEvent?) -> Void) {
        let imageSize = image.size
        let quality: CGFloat = imageSize.width < 500 ? 1.0 : 0.5
        guard let imageData = image.jpegData(compressionQuality: quality) else {
            completion(nil)
            return
        }
        self.storageImage(data: imageData)
        NetworkManager.shared.uploadImageChat(imageData: imageData) {[weak self] url in
            guard let self = self, let url = url else {
                completion(nil)
                return
            }
            let messageContent = self.createMediaMessageContent(url: url, imageSize: imageSize, fileSize: imageData.count)
            self.sendMessage(content: messageContent, completion: completion)
        }
    }
    
    public func removeOutgoingMessage(_ eventId: String) {
        room.removeOutgoingMessage(eventId)
    }
    
    private func createMediaMessageContent(url: String, imageSize: CGSize, fileSize: Int) -> [String: Any] {
        var messageContent: [String: Any] = [MessageConstants.messageBodyKey: url, MessageConstants.messageTypeKey: MessageType.image.key, "clientId": UUID().uuidString]
        messageContent["format"] = "org.matrix.custom.html"
        messageContent["filename"] = url
        messageContent["url"] = url
        let info: [String: Any] = ["mimetype": "image/png", "size": fileSize, "w": imageSize.width, "h": imageSize.height]
        messageContent["info"] = info
        return messageContent
    }
    
    private func storageImage(data: Data) {
        let uploader = MXMediaManager.prepareUploader(withMatrixSession: room.mxSession, initialRange: 0, andRange: 1.0)
        let fakeMediaURI = uploader?.uploadId
        let cacheFilePath: String = MXMediaManager.cachePath(forMatrixContentURI: fakeMediaURI!, andType: "image/jpeg", inFolder: room.roomId)
        MXMediaManager.writeMediaData(data, toFilePath: cacheFilePath)
    }

    public func markAllAsRead() {
        room.summary.markAllAsRead()
        MatrixManager.shared.rxEvent.accept((self.eventCache.last!, self, MXTimelineDirection(rawValue: 1)!, nil))
    }

    @nonobjc @discardableResult func sendTypingNotification(typing: Bool, timeout: TimeInterval?, completion: @escaping (_ response: MXResponse<Void>) -> Void) -> MXHTTPOperation {
        self.room.sendTypingNotification(typing: typing, timeout: timeout, completion: completion)
    }
    
    func listen(toEventsOfTypes: [String], onEvent: @escaping MXOnRoomEvent) {
        self.room.listen(toEventsOfTypes: toEventsOfTypes, onEvent: onEvent)
    }
    
    func getEventReceipts(_ eventId: String, sorted: Bool, completion: @escaping([MXReceiptData]) -> Void) {
        self.room.getEventReceipts(eventId, sorted: sorted, completion: completion)
    }
    
    func liveTimeline(_ completion: @escaping(MXEventTimeline?) -> Void) {
        room.liveTimeline(completion)
    }
    
    func sendReadReceipt(eventId: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {[weak self] in
            guard let self = self else { return }
            self.room.mxSession.matrixRestClient.sendReadReceipt(toRoom: self.roomId, forEvent: eventId) { response in
                print("Send read receipt: \(eventId)")
                print(response)
            }
        }
        
    }
    
    func setPartialTextMessage(text: String) {
        self.room.partialTextMessage = text
    }
    
    deinit {
        listenReferenceRoom = nil
    }
}

//Extension Setting room
extension TnexRoom {
    func leave(completion: @escaping(MXResponse<Void>) -> Void) {
        room.leave(completion: completion)
    }
    
    func muteConversation() {
        let notificationService = MXRoomNotificationSettingsService(room: room)
        notificationService.update(state: .mute) {
            print("update thanh cong")
        }
        
    }
}

//Get value
extension TnexRoom {
    
    func getPartialTextMessage() -> String {
        return self.room.partialTextMessage ?? ""
    }
    
    func getUserInfo(from userId: String) -> MXUser? {
        return room.mxSession.user(withUserId: userId)
    }
    
    func toRoomItem() -> RoomItem {
        RoomItem(room: room)
    }
    
    public func getRoom() -> MXRoom {
        return room
    }
    
    func paginate(event: MXEvent, completion: @escaping((MXResponse<Void>) -> Void)) {
        guard let timeline = room.timeline(onEvent: event.eventId) else { return }
        listenReferenceRoom = timeline.listenToEvents {[weak self] event, direction, roomState in
            guard let self = self else { return }
            if direction == .backwards {
                self.add(event: event, direction: direction, roomState: roomState)
            }
        }
        timeline.resetPaginationAroundInitialEvent(withLimit: 40, completion: completion)
    }
    
    public func getState(completion: @escaping(MXRoomState?) -> Void){
        self.room.state(completion)
    }
}

public extension TnexRoom {
    func toDic() -> NSMutableDictionary {
        return ["displayname": self.summary.displayname ?? "Unknown",
                "avatar": self.roomAvatarUrl ?? "",
                "lastMessage": self.lastMessage,
                "id": self.roomId,
                "unreadCount": self.summary.notificationCount,
                "timeCreated": self.getLastEvent()?.originServerTs ?? UInt64(Date().timeIntervalSince1970)
        ]
    }
    
    private func getAvatarUrl() -> String? {
        if let avatarUrl = MatrixManager.shared.dicRoomAvatar[roomId] {
            //Avatar direct chat la avatar partner
            return avatarUrl
        } else if let avatarUrl = self.room.directUserId, !avatarUrl.isEmpty {
            //Avatar direct chat la avatar partner
            MatrixManager.shared.dicRoomAvatar[roomId] = avatarUrl
            return avatarUrl
        }
        return nil
    }
}
