//
//  ListChatFlutterMethodChannel.swift
//  Runner
//
//  Created by Din Vu Dinh on 02/06/2022.
//

import UIKit
import Flutter
import tnexchat
import MatrixSDK

enum MethodCode {
    case rooms
    case sender
    case members
    case lastMessage
    
    var methodId: String {
        switch self {
        case .rooms:
            return "rooms"
        case .sender:
            return "sender"
        case .lastMessage:
            return "lastMessage"
        case .members:
            return "members"
        }
    }
}

final class ListChatFlutterHandler {
        
    init(appDelegate: AppDelegate) {
        let credentials: MXCredentials = MXCredentials(homeServer: "https://chat-matrix.tnex.com.vn", userId: "@7181fb55-bba8-483f-adde-c5c1f4452852:chat-matrix.tnex.com.vn", accessToken: "MDAyNWxvY2F0aW9uIGNoYXQtbWF0cml4LnRuZXguY29tLnZuCjAwMTNpZGVudGlmaWVyIGtleQowMDEwY2lkIGdlbiA9IDEKMDA1MGNpZCB1c2VyX2lkID0gQDcxODFmYjU1LWJiYTgtNDgzZi1hZGRlLWM1YzFmNDQ1Mjg1MjpjaGF0LW1hdHJpeC50bmV4LmNvbS52bgowMDE2Y2lkIHR5cGUgPSBhY2Nlc3MKMDAyMWNpZCBub25jZSA9IHE7U2ZMRGcxd3M9Mm00dCYKMDAyZnNpZ25hdHVyZSArvUahqvnk2QhJl9Vs3gds4Vze18mbinHERTIWLzs7RAo")
        credentials.identityServer = "https://vector.im"
        MatrixManager.shared.sync(credentials: credentials) {
            print("login oke")
        }
        
    }
    
    
    
    
}
