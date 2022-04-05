//
//  DemoChatMessageFactory.swift
//  Tnex messenger
//
//  Created by Din Vu Dinh on 27/02/2022.
//

import Foundation
import UIKit

extension TextMessageModel {
    static var chatItemType: ChatItemType {
        return "text"
    }
}

extension PhotoMessageModel {
    static var chatItemType: ChatItemType {
        return "photo"
    }
}

extension ChatItemType {
    static var compoundItemType = "compound"
    static var compoundItemType2 = "compound2"
}
