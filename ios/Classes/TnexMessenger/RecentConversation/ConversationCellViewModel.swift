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
        rxDisplayName.accept(room.summary.displayname)
        rxLastMessage.accept(room.lastMessage)
        isReacted = true
        
    }
    
    func reactIfNeeded() {
        guard isReacted == false else { return }
        react()
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
