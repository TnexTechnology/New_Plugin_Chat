//
//  ConversationCellViewModel.swift
//  tnexchat
//
//  Created by Din Vu Dinh on 30/05/2022.
//

import UIKit
import RxSwift
import RxRelay
import MatrixSDK

class ConversationCellViewModel: NSObject {
    var room: TnexRoom!
    let rxAvatar        = BehaviorRelay<String>(value: "")
    let rxDisplayName   = BehaviorRelay<String?>(value: nil)
    let rxLastMessage   = BehaviorRelay<String?>(value: nil)
    let rxUnreadCount   = BehaviorRelay<String?>(value: nil)
    let rxIsUnread      = BehaviorRelay<Bool>(value: false)
    let rxIsLinkDepartment = BehaviorRelay<Bool>(value: false)
    let rxHasMention    = BehaviorRelay<Bool>(value: false)
    let rxTime          = BehaviorRelay<String?>(value: nil)
    let rxNotify        = BehaviorRelay<Bool>(value: true)
 
    var disposeBag: DisposeBag? = DisposeBag()
    var isReacted = false
    
    convenience init(by room: TnexRoom) {
        self.init()
        self.room = room
        react()
    }
 
    var displayName: String {
        return room.summary.displayname
    }
 
    func react() {
        let lastEvent = room.getLastEvent()
        let senderId = lastEvent?.sender ?? ""
        if senderId == MatrixManager.shared.userId {
            self.rxLastMessage.accept("Bạn: \(self.room.lastMessage)")
        } else {
            MatrixManager.shared.getSenderInfo(senderId: senderId, at: self.room.getRoom()) { [weak self] displayName in
                guard let self = self else { return }
                if let displayName = displayName {
                    self.rxLastMessage.accept("\(displayName): \(self.room.lastMessage)")
                } else {
                    self.rxLastMessage.accept(self.room.lastMessage)
                }
            }
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm E, d MMM y"
        let timeString = formatter.string(from: room.summary.lastMessageDate)
        rxTime.accept(timeString)
        getDisplayname()
        isReacted = true
        
    }
    
    func reactIfNeeded() {
        guard isReacted == false else { return }
        react()
    }
    
    func getDisplayname() {
        let displayname = self.room.summary.displayname ?? ""
        if room.isDirect {
            rxDisplayName.accept(displayname + "OK")
            return
        }
        if displayname.contains(CUSTOMER_SUPPORT_MATRIX_USER_ID) {
            rxDisplayName.accept(CUSTOMER_SUPPORT_MATRIX_USER_NAME)
            return
        }
        self.room.getState {[weak self] state in
            guard let self = self, let state = state else { return }
            let partnerName = state.members.members.first(where: {$0.userId != MatrixManager.shared.userId})?.displayname ?? "Nhóm chat"
            self.rxDisplayName.accept(partnerName)

        }
    }
    
}
 
extension ConversationCellViewModel {
 
    static func ==(lhs: ConversationCellViewModel, rhs: ConversationCellViewModel) -> Bool {
        return lhs.room.roomId == rhs.room.roomId
    }
 
    override func isEqual(_ object: Any?) -> Bool {
        guard let vm = object as? ConversationCellViewModel else { return false }
        //Chec lai cho nay
        return room.roomId == vm.room.roomId
    }
}
