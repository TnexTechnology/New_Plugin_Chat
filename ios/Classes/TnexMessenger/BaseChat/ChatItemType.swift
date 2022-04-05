//
//  ChatItemType.swift
//  tnexchat
//
//  Created by MacOS on 05/03/2022.
//

import Foundation

public enum TnexChatItemType: String {
    case text = "text"
    case image = "image"
    case custom = "custom"
    case error = "error" //Message thieu du lieu, tranh show len UI Khong mong muon
}
