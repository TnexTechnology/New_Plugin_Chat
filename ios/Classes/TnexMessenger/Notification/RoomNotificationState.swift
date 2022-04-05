//
//  RoomNotificationState.swift
//  tnexchat
//
//  Created by Din Vu Dinh on 05/04/2022.
//

import Foundation

enum RoomNotificationState: Int {
    case all
    case mentionsAndKeywordsOnly
    case mute
}

extension RoomNotificationState: CaseIterable { }

extension RoomNotificationState: Identifiable {
    var id: Int { self.rawValue }
}

extension RoomNotificationState {
    var title: String {
        switch self {
        case .all:
            return "Tất cả"
        case .mentionsAndKeywordsOnly:
            return "Chỉ nhắc đến mình"
        case .mute:
            return "Tắt thông báo"
        }
    }
}
