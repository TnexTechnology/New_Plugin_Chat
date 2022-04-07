//
// The MIT License (MIT)
//
// Copyright (c) 2015-present Badoo Trading Limited.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

class TnexMessageInteractionHandler<Model: TnexMessageModelProtocol, ViewModel: MessageViewModelProtocol>: BaseMessageInteractionHandlerProtocol {
    weak var labelDelegate: MKMessageLabelDelegate?
    weak var chatviewController: ChatDetailViewController?
    private let messagesSelector: MessagesSelectorProtocol
    
    init(chatviewController: ChatDetailViewController?, messagesSelector: MessagesSelectorProtocol) {
        self.messagesSelector = messagesSelector
        self.labelDelegate = messagesSelector.labelDelegate
        self.chatviewController = chatviewController
    }
    
    func userDidTapOnAvatar(message: Model, viewModel: ViewModel, avatarView: UIImageView) {
        print("userDidTapOnAvatar")
        self.chatviewController?.showProfileUser(userId: message.senderId)
    }
    
    func userDidTapOnBubble(message: Model, viewModel: ViewModel, bubbleView: UIView) {
        print("userDidTapOnBubble")
    }
    
    func userDidEndLongPressOnBubble(message: Model, viewModel: ViewModel, bubbleView: UIView, touchPoint: CGPoint) {
        if let textMessage = message as? DemoTextMessageModel, message.type == TnexChatItemType.text.rawValue {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let copyAction = UIAlertAction(title: "Sao chép", style: .default) {[weak self] _ in
                UIPasteboard.general.string = textMessage.text
                self?.chatviewController?.view.makeToast("Đã sao chép nội dung")
            }
            let cancel = UIAlertAction(title: "Thoát", style: .cancel)
            alertController.addAction(copyAction)
            alertController.addAction(cancel)
            self.chatviewController?.present(alertController, animated: true)
        } else {
            if let photoMessage = message as? TnextPhotoMessageModel, message.status == .failed {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let retryAction = UIAlertAction(title: "Gửi lại", style: .default) {[weak self] _ in
                    self?.chatviewController?.dataSource.retryPhotoMessage(message: photoMessage)
                }
                let removeAction = UIAlertAction(title: "Xoá tin nhắn", style: .default) {[weak self] _ in
                    self?.chatviewController?.dataSource.removeMessage(eventId: message.uid)
                }
                let cancel = UIAlertAction(title: "Thoát", style: .cancel)
                alertController.addAction(retryAction)
                alertController.addAction(removeAction)
                alertController.addAction(cancel)
                self.chatviewController?.present(alertController, animated: true)
            }
        }
    }
    
    func userDidTapOnActionView(message: Model, viewModel: ViewModel, action: ActionMessageType, imageView: UIImageView?) {
        print("userDidTapOnActionView")
    }
    
    func userDidTapSingleSeenView(message: Model, viewModel: ViewModel) {
        print("userDidTapSingleSeenView")
    }
    
    func userDidLongpressAvatar(message: Model, viewModel: ViewModel, avatarView: UIImageView, touchPoint: CGPoint) {
        print("userDidLongpressAvatar")
    }

    func userDidTapOnFailIcon(message: Model, viewModel: ViewModel, failIconView: UIView) {
        print(#function)
    }

    func userDidTapOnAvatar(message: Model, viewModel: ViewModel) {
        print(#function)
    }

    func userDidTapOnBubble(message: Model, viewModel: ViewModel) {
        print(#function)
    }
    

    func userDidDoubleTapOnBubble(message: Model, viewModel: ViewModel) {
        print(#function)
    }

    func userDidBeginLongPressOnBubble(message: Model, viewModel: ViewModel) {
        print(#function)
    }

    func userDidEndLongPressOnBubble(message: Model, viewModel: ViewModel) {
        print(#function)
    }

    func userDidSelectMessage(message: Model, viewModel: ViewModel) {
        print(#function)
        self.messagesSelector.selectMessage(message)
        self.chatviewController?.view.endEditing(true)
    }

    func userDidDeselectMessage(message: Model, viewModel: ViewModel) {
        print(#function)
        self.messagesSelector.deselectMessage(message)
    }
}
