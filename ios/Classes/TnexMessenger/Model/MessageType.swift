//
//  MessageType.swift
//  tnexchat
//
//  Created by Din Vu Dinh on 23/03/2022.
//

import Foundation
import MatrixSDK

enum MessageType {
    case text
    case image
    
    var key: String {
        switch self {
        case .text: return kMXMessageTypeText
        case .image: return kMXMessageTypeImage
        }
    }
    
}
