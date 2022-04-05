//
//  MessageViewModelProtocol.swift
//  Tnex messenger
//
//  Created by Din Vu Dinh on 27/02/2022.
//

import MatrixSDK

protocol MessageViewModelProtocol1 {
    var id: String { get }
    var text: String { get }
    var sender: String { get }
    var sentState: MXEventSentState { get }
    var showSender: Bool { get }
    var timestamp: String { get }

}

extension MessageViewModelProtocol1 {
    var isEmoji: Bool {
        (text.count <= 3) && text.containsOnlyEmoji
    }
}

struct MessageViewModel1: MessageViewModelProtocol1 {
    enum Error: Swift.Error {
        case invalidEventType(MXEventType)

        var localizedDescription: String {
            switch self {
            case .invalidEventType(let type):
                return "Expected message event, found \(type)"
            }
        }
    }

    var id: String {
        event.eventId
    }

    var text: String {
        if !event.isEdit() {
            return (event.content["body"] as? String).map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            } ?? "Error: expected string body"
        } else {
            let newContent = event.content["m.new_content"]! as? NSDictionary
            return (newContent?["body"] as? String).map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            } ?? "Error: expected string body"
        }
    }

    var sender: String {
        event.sender
    }

    var sentState: MXEventSentState {
        event.sentState
    }

    var showSender: Bool

    var timestamp: String {
        "Formatter.string(for: event.timestamp, timeStyle: .short)"
    }


    private let event: MXEvent

    public init(event: MXEvent, showSender: Bool) {
//        try Self.validate(event: event)

        self.event = event
        self.showSender = showSender
    }

    private static func validate(event: MXEvent) throws {
        // NOTE: For as long as https://github.com/matrix-org/matrix-ios-sdk/pull/843
        // remains unresolved keep in mind that
        // `.keyVerificationStart`, `.keyVerificationAccept`, `.keyVerificationKey`,
        // `.keyVerificationMac`, `.keyVerificationCancel` & `.reaction`
        // may get wrongly recognized as `.custom(…)`, instead.
        // FIXME: Remove comment when linked bug fix has been merged.
        let eventType = MXEventType(identifier: event.type)
        guard eventType == .roomMessage else {
            throw Error.invalidEventType(eventType)
        }
    }
}


extension String {
    var isSingleEmoji: Bool {
        return count == 1 && containsEmoji
    }

    var containsEmoji: Bool {
        return contains { $0.isEmoji }
    }

    var containsOnlyEmoji: Bool {
        return !isEmpty && !contains { !$0.isEmoji }
    }

    var emojiString: String {
        return emojis.map { String($0) }.reduce("", +)
    }

    var emojis: [Character] {
        return filter { $0.isEmoji }
    }

    var emojiScalars: [UnicodeScalar] {
        return filter { $0.isEmoji }.flatMap { $0.unicodeScalars }
    }
}

extension Character {
    /// A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        guard let firstProperties = unicodeScalars.first?.properties else {
            return false
        }
        return unicodeScalars.count == 1 &&
            (firstProperties.isEmojiPresentation ||
                firstProperties.generalCategory == .otherSymbol)
    }

    /// Checks if the scalars will be merged into an emoji
    var isCombinedIntoEmoji: Bool {
        return unicodeScalars.count > 1 &&
            unicodeScalars.contains { $0.properties.isJoinControl || $0.properties.isVariationSelector }
    }

    var isEmoji: Bool {
        return isSimpleEmoji || isCombinedIntoEmoji
    }
}
