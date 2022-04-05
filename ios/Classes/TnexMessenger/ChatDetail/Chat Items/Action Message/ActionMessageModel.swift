/*
 The MIT License (MIT)

 Copyright (c) 2015-present Badoo Trading Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

import Foundation
import UIKit
import MatrixSDK

class ActionMessageModel: ChatItemProtocol {
        
    let date: Date
    let uid: String
    let userId: String
    let displayName: String?
    let content: String
    let type: ChatItemType = ActionMessageModel.chatItemType

    static var chatItemType: ChatItemType {
        return "action-cell"
    }
    
    struct User {
        let displayName: String
        let avatarURL: MXURL?
        let membership: String
        let reason: String?
    }

    let current: User
    let previous: User?

    var hasUserInfoDifference: Bool {
        guard let previous = previous else { return false }
        return current.displayName != previous.displayName
            || current.avatarURL?.mxContentURI != previous.avatarURL?.mxContentURI
    }

    let event: MXEvent
    
    init(event: MXEvent) {
        self.event = event
        self.uid = event.eventId
        self.date = event.timestamp
        self.userId = event.sender
        self.content = event.content(valueFor: "membership") ?? ""
        self.displayName = event.content(valueFor: "displayname")

        self.current = User(
            // FIXME: This sometimes fails to show the correct display name
            // although I can clearly see it present in the event details in
            // Riot. Is the event metadata somehow different here?!
            displayName: event.content(valueFor: "displayname") ?? event.sender,
            avatarURL: event.content(valueFor: "avatar_url").flatMap(MXURL.init),
            membership: event.content(valueFor: "membership") ?? "",
            reason: event.content(valueFor: "reason")
        )

        if let prevDisplayname: String = event.prevContent(valueFor: "displayname"),
            let prevMembership: String = event.prevContent(valueFor: "membership"),
            let reason: String? = event.prevContent(valueFor: "reason")
        {
            let prevAvatarURL: MXURL? = event.prevContent(valueFor: "avatar_url").flatMap(MXURL.init)
            self.previous = User(displayName: prevDisplayname, avatarURL: prevAvatarURL, membership: prevMembership, reason: reason)
        } else {
            self.previous = nil
        }
    }
    
}
