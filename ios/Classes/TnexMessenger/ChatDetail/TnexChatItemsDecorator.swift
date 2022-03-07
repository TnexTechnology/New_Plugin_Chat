//
//  TnexChatItemsDecorator.swift
//  Tnex messenger
//
//  Created by Din Vu Dinh on 27/02/2022.
//

import Foundation
import UIKit

final class TnexChatItemsDecorator: ChatItemsDecoratorProtocol {
    private struct Constants {
        static let shortSeparation: CGFloat = 3
        static let normalSeparation: CGFloat = 3
        static let timeIntervalThresholdToIncreaseSeparation: TimeInterval = 600
    }
    private let limitBetweenMessages: Double = 600
    private let messagesSelector: MessagesSelectorProtocol
    init(messagesSelector: MessagesSelectorProtocol) {
        self.messagesSelector = messagesSelector
    }

    func decorateItems(_ chatItems: [ChatItemProtocol]) -> [DecoratedChatItem] {
        var decoratedChatItems = [DecoratedChatItem]()
        var dateTimeStamp: TimeSeparatorModel? = nil
        let calendar = Calendar.current
        for (index, chatItem) in chatItems.enumerated() {
            let next: ChatItemProtocol? = (index + 1 < chatItems.count) ? chatItems[index + 1] : nil
            let prev: ChatItemProtocol? = (index > 0) ? chatItems[index - 1] : nil

            var isSelected = false
            var isShowingSelectionIndicator = false
            var isTheBeginBlockChat = false
            var isTheEndBlockChat = false
            var isShowSenderInfo: Bool = false
            var isExpandCell = false

            if let currentMessage = chatItem as? TnexMessageModelProtocol {
                isTheBeginBlockChat = self.checkIsTheBeginBlockChat(currentMessage, prevMessage: prev as? MessageModelProtocol)
                isTheEndBlockChat = self.checkIsTheEndBlockChat(currentMessage, nextMessage: next as? MessageModelProtocol)
                
                isShowSenderInfo = self.checkShowDisplayName(currentMessage, isIncoming: currentMessage.isIncoming, isTheFirstBlockChat: isTheBeginBlockChat)
                isExpandCell = false
                if isExpandCell {
//                    self.showSeenInfoIfNeed(&seenInfoModel, at: currentMessage, isTheFirstMessageToDay: isTheFirstMessageToDay)
                }
                if checkIsShowDaySperator(currentMessage, prevMessage: prev as? MessageModelProtocol, calendar: calendar) {
                    let dayStamp = DecoratedChatItem(chatItem: DaySeparatorModel(uid: "\(currentMessage.uid)-day-separator", date: currentMessage.date), decorationAttributes: nil)
                    decoratedChatItems.append(dayStamp)
                }
                if self.checkIsShowTime(currentMessage, prevMessage: prev as? MessageModelProtocol) {
                    dateTimeStamp = TimeSeparatorModel(uid: "\(currentMessage.uid)-time-separator", date: currentMessage.date, isIncoming: currentMessage.isIncoming, status: currentMessage.status)
                }
                if isShowSenderInfo {
                    self.showSenderInfoIfNeed(&decoratedChatItems, at: currentMessage)
                }
                isSelected = self.messagesSelector.isMessageSelected(currentMessage)
                isShowingSelectionIndicator = self.messagesSelector.isActive && self.messagesSelector.canSelectMessage(currentMessage)
            }

            let messageDecorationAttributes = BaseMessageDecorationAttributes(
                canShowFailedIcon: true,
                isTheBeginBlockChat: isTheBeginBlockChat,
                isTheEndBlockChat: isTheEndBlockChat,
                isShowingAvatar: isTheEndBlockChat,
                isShowingSelectionIndicator: isShowingSelectionIndicator,
                isSelected: isSelected,
                isExpandCell: isExpandCell
            )
            let bottomMargin = self.separationAfterItem(chatItem, next: next)
            decoratedChatItems.append(
                DecoratedChatItem(
                    chatItem: chatItem,
                    decorationAttributes: ChatItemDecorationAttributes(bottomMargin: bottomMargin, messageDecorationAttributes: messageDecorationAttributes)
                )
            )
            if let daySperator = dateTimeStamp {
                let dateTimeStamp = DecoratedChatItem(chatItem: daySperator, decorationAttributes: nil)
                decoratedChatItems.append(dateTimeStamp)
            }
            
        }
        return decoratedChatItems
    }

    private func separationAfterItem(_ current: ChatItemProtocol?, next: ChatItemProtocol?) -> CGFloat {
        guard let nexItem = next else { return 0 }
        guard let currentMessage = current as? MessageModelProtocol else { return Constants.normalSeparation }
        guard let nextMessage = nexItem as? MessageModelProtocol else { return Constants.normalSeparation }

        if self.showsStatusForMessage(currentMessage) {
            return 0
        } else if currentMessage.senderId != nextMessage.senderId {
            return Constants.normalSeparation
        } else if nextMessage.date.timeIntervalSince(currentMessage.date) > Constants.timeIntervalThresholdToIncreaseSeparation {
            return Constants.normalSeparation
        } else {
            return Constants.shortSeparation
        }
    }

    private func showsStatusForMessage(_ message: MessageModelProtocol) -> Bool {
        return message.status == .failed || message.status == .sending
    }
    
    private func checkIsTheBeginBlockChat(_ currentMessage: MessageModelProtocol, prevMessage: MessageModelProtocol?) -> Bool {
        guard let prevMessage = prevMessage else { return true }
        if currentMessage.senderId != prevMessage.senderId {
            return true
        }
        let time: TimeInterval = currentMessage.date.timeIntervalSince1970
        let previousTime: TimeInterval = prevMessage.date.timeIntervalSince1970
        return time - previousTime > limitBetweenMessages
        
    }
    
    private func checkIsTheEndBlockChat(_ currentMessage: MessageModelProtocol, nextMessage: MessageModelProtocol?) -> Bool {
        guard let nextMessage = nextMessage else {
            return true
        }
        if currentMessage.senderId != nextMessage.senderId {
            return true
        }
        let time: TimeInterval = currentMessage.date.timeIntervalSince1970
        let nextTime: TimeInterval = nextMessage.date.timeIntervalSince1970
        return nextTime - time > limitBetweenMessages
    }

    private func checkIsShowTime(_ currentMessage: MessageModelProtocol, prevMessage: MessageModelProtocol?) -> Bool {
        //Tin nhan dau tien trong ngay
//        if self.viewModel.expandMessageId == currentMessage.msgId {
//            return true
//        }
        guard let prevMessage = prevMessage else { return true }
        let time: TimeInterval = currentMessage.date.timeIntervalSince1970
        let previousTime: TimeInterval = prevMessage.date.timeIntervalSince1970
        return time - previousTime > limitBetweenMessages
    }
    
    private func checkIsShowDaySperator(_ currentMessage: MessageModelProtocol, prevMessage: MessageModelProtocol?, calendar: Calendar = Calendar.current) -> Bool {
        guard let prevMessage = prevMessage else { return true }
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: currentMessage.date)
        let otherComponents = calendar.dateComponents([.year, .month, .day], from: prevMessage.date)
        return currentComponents.day != otherComponents.day || currentComponents.month != otherComponents.month || currentComponents.year != otherComponents.year
    }
    
    func showSenderInfoIfNeed(_ decoratedChatItems: inout [DecoratedChatItem], at messageModelProtocol: TnexMessageModelProtocol) {
        let senderInfoModel = SenderInfoModel(displayName: messageModelProtocol.senderName, userId: messageModelProtocol.senderId, uid: "\(messageModelProtocol.senderId)-\(messageModelProtocol.uid)", isIncoming: messageModelProtocol.isIncoming)
        let senderInfo = DecoratedChatItem(chatItem: senderInfoModel, decorationAttributes: nil)
        decoratedChatItems.append(senderInfo)
    }
    
    private func checkShowDisplayName(_ message: MessageModelProtocol, isIncoming: Bool, isTheFirstBlockChat: Bool) -> Bool {
        if !isIncoming {
            return false
        }
        if isTheFirstBlockChat {
            return true
        }
        return false
    }
    
}
