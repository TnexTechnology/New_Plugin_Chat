//
//  TypingTracker.swift
//  tnexchat
//
//  Created by Din Vu Dinh on 28/03/2022.
//

import Foundation
import UIKit

final class TypingTracker {
    private let timeTyping = 4.0
    private var timerSendTyping: Timer?
    private var timerShowTyping: Timer?
    var showTypingCallback: ((_ isShow: Bool) -> Void)?
    var typingCallback: (() -> Void)?
    
    init() {}
    
    func startTimerSendTyping() {
        if timerSendTyping == nil {
            self.typingCallback?()
            timerSendTyping = Timer.scheduledTimer(timeInterval: timeTyping, target: self, selector: #selector(stopTimerSendTyping), userInfo: nil, repeats: false)
        }
    }

    @objc private func stopTimerSendTyping() {
        if timerSendTyping != nil {
            timerSendTyping?.invalidate()
            timerSendTyping = nil
        }
    }
    
    func startShowTypingView() {
        if timerShowTyping != nil {
            timerShowTyping?.invalidate()
            timerShowTyping = nil
        }
        self.showTypingCallback?(true)
        timerShowTyping = Timer.scheduledTimer(timeInterval: timeTyping, target: self, selector: #selector(hideTypingView), userInfo: nil, repeats: false)
    }

    @objc private func hideTypingView() {
        self.showTypingCallback?(false)
    }
}
