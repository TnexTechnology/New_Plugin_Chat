//
//  RightMenuItem.swift
//  tnexchat
//
//  Created by MacOS on 08/03/2022.
//

import Foundation
import UIKit

public enum RightMenuItem {
    case add
    case profile
    case member
    case mute
    case unmute
    case remove
    case leave
    
    var title: String {
        switch self {
        case .add:
            return "Thêm"
        case .profile:
            return "Xem hồ sơ"
        case .member:
            return "Thành viên"
        case .mute:
            return "Tắt thông báo"
        case .unmute:
            return "Bật thông báo"
        case .remove:
            return "Xoá tin nhắn"
        case .leave:
            return "Rời nhóm"
        }
    }
    
    var image: UIImage? {
        let imageName: String
        switch self {
        case .add:
            imageName = "chat_menu_header_add"
        case .profile:
            imageName = "chat_menu_header_profile"
        case .member:
            imageName = "chat_menu_header_member"
        case .mute:
            imageName = "chat_menu_header_silent"
        case .unmute:
            imageName = "chat_menu_header_silent"
        case .remove:
            imageName = "chat_menu_header_trash"
        case .leave:
            imageName = "chat_menu_header_leave"
        }
        return UIImage(named: imageName, in: Bundle.resources, compatibleWith: nil)
    }
    
}
