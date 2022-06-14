//
//  ChatStreamHandler.swift
//  Runner
//
//  Created by Din Vu Dinh on 14/06/2022.
//

import Foundation
import Flutter

class ChatStreamHandler: NSObject, FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        events(true) // any generic type or more compex dictionary of [String:Any]
        events(FlutterError(code: "ERROR_CODE",
                             message: "Detailed message",
                             details: nil)) // in case of errors
        events(FlutterEndOfEventStream) // when stream is over
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}
