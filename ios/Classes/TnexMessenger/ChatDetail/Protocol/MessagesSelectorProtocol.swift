//
//  MessagesSelectorProtocol.swift
//  Tnex messenger
//
//  Created by Din Vu Dinh on 27/02/2022.
//

import Foundation
import UIKit

public protocol MessagesSelectorDelegate: AnyObject {
    func messagesSelector(_ messagesSelector: MessagesSelectorProtocol, didSelectMessage: MessageModelProtocol)
    func messagesSelector(_ messagesSelector: MessagesSelectorProtocol, didDeselectMessage: MessageModelProtocol)
}

public protocol MessagesSelectorProtocol: AnyObject {
    var delegate: MessagesSelectorDelegate? { get set }
    var isActive: Bool { get set }
    func canSelectMessage(_ message: MessageModelProtocol) -> Bool
    func isMessageSelected(_ message: MessageModelProtocol) -> Bool
    func selectMessage(_ message: MessageModelProtocol)
    func deselectMessage(_ message: MessageModelProtocol)
    func selectedMessages() -> [MessageModelProtocol]
}
