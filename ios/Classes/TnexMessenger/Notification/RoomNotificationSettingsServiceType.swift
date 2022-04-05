//
//  RoomNotificationSettingsServiceType.swift
//  tnexchat
//
//  Created by Din Vu Dinh on 05/04/2022.
//

import Foundation

typealias UpdateRoomNotificationStateCompletion = () -> Void
typealias RoomNotificationStateCallback = (RoomNotificationState) -> Void

protocol RoomNotificationSettingsServiceType {

    func observeNotificationState(listener: @escaping RoomNotificationStateCallback)
    func update(state: RoomNotificationState, completion: @escaping UpdateRoomNotificationStateCompletion)
    var notificationState: RoomNotificationState { get }
}
