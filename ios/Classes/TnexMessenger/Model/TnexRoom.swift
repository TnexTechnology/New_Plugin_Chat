//
//  TnexRoom.swift
//  Tnex messenger
//
//  Created by MacOS on 27/02/2022.
//

import Foundation
import MatrixSDK

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
    public var room: MXRoom

    public var summary: TnexRoomSummary
    
    public var roomAvatarURL: URL? {
        guard let client = APIManager.shared.mxRestClient,
              let homeserver = URL(string: client.homeserver),
              let avatar = room.summary.avatar else { return nil }
        return MXURL(mxContentURI: avatar)?.contentURL(on: homeserver)
    }

    internal var eventCache: [MXEvent] = []

    public var isDirect: Bool {
        room.isDirect
    }

    public var lastMessage: String {
        if summary.membership == .invite {
            let inviteEvent = eventCache.last {
                $0.type == kMXEventTypeStringRoomMember && $0.stateKey == room.mxSession.myUserId
            }
            guard let sender = inviteEvent?.sender else { return "" }
            return "Invitation from: \(sender)"
        }

        let lastMessageEvent = eventCache.last {
            $0.type == kMXEventTypeStringRoomMessage
        }
        if lastMessageEvent?.isEdit() ?? false {
            let newContent = lastMessageEvent?.content["m.new_content"]! as? NSDictionary
            return newContent?["body"] as? String ?? ""
        } else {
            return lastMessageEvent?.content["body"] as? String ?? ""
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
        let messageContent: [String: Any] = [MessageContants.messageBodyKey: text, MessageContants.messageTypeKey: MessageType.text.key, "clientId": UUID().uuidString]
        self.sendMessage(content: messageContent, completion: completion)
    }
    
    public func sendMessage(content: [String: Any], completion: @escaping(_ event: MXEvent?) -> Void) {
        var localEcho: MXEvent? = nil {
            didSet {
                completion(localEcho)
            }
        }
        room.sendMessage(withContent: content, localEcho: &localEcho) { fdsfds in
            print("Da gui tin nhan")
            localEcho?.sentState = MXEventSentStateSent
            completion(localEcho)
        }
//        room.sendTextMessage(text, localEcho: &localEcho) { fdsfds in
//            print("Da gui tin nhan\(fdsfds.value)")
//            localEcho?.sentState = MXEventSentStateSent
//            completion(localEcho)
//        }
    }


    public func react(toEventId eventId: String, emoji: String) {
        // swiftlint:disable:next force_try
//        let content = try! ReactionEvent(eventId: eventId, key: emoji).encodeContent()
//
//        objectWillChange.send()             // room.outgoingMessages() will change
//        var localEcho: MXEvent? = nil
//        room.sendEvent(.reaction, content: content, localEcho: &localEcho) { _ in
//            self.objectWillChange.send()    // localEcho.sentState has(!) changed
//        }
    }

    public func edit(text: String, eventId: String) {
        guard !text.isEmpty else { return }

//        var localEcho: MXEvent? = nil
//        // swiftlint:disable:next force_try
//        let content = try! EditEvent(eventId: eventId, text: text).encodeContent()
//        // TODO: Use localEcho to show sent message until it actually comes back
//        room.sendMessage(withContent: content, localEcho: &localEcho) { _ in }
    }

    public func redact(eventId: String, reason: String?) {
        room.redactEvent(eventId, reason: reason) { _ in }
    }

    public func sendImage(image: UIImage, completion: @escaping(_ event: MXEvent?) -> Void) {
        NetworkManager.shared.createImageContent(image: image) {[weak self] content in
            guard let content = content, let self = self else {
                return
            }
            self.sendMessage(content: content, completion: completion)
        }
    }
    
    public func markAllAsRead() {
        room.markAllAsRead()
    }

//    public func removeOutgoingMessage(_ event: MXEvent) {
//        objectWillChange.send()             // room.outgoingMessages() will change
//        room.removeOutgoingMessage(event.eventId)
//    }
}

//extension TnexRoom: Identifiable {
//    public var id: Identifier {
//        room.roomId
//    }
//}

//extension UXImage {
//    public enum JPEGQuality: CGFloat {
//        case lowest  = 0
//        case low     = 0.25
//        case medium  = 0.5
//        case high    = 0.75
//        case highest = 1
//    }
//
//    public func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
//        #if os(macOS)
//            return tiffRepresentation(using  : .jpeg,
//                                      factor : Float(jpegQuality.rawValue))
//        #else
//            return jpegData(compressionQuality: jpegQuality.rawValue)
//        #endif
//    }
//}
