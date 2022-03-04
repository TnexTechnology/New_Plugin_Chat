//
//  TnexInputBar.swift
//  Tnex messenger
//
//  Created by Din Vu Dinh on 02/03/2022.
//

import UIKit
import InputBarAccessoryView

class TnexInputBar: InputBarAccessoryView {
    
    var onClickSendButton: ((_ text: String) -> Void)?
    var photoInputHandler: ((UIImage, PhotosInputViewPhotoSource) -> Void)?
    var emojInputHandler: (() -> Void)?
    
    lazy var transferButton: InputBarButtonItem = {
        let button = InputBarButtonItem()
        .configure {
            $0.spacing = .none
            $0.contentMode = .scaleAspectFill
            $0.image = UIImage(named: "chat_inpputbar_transfer", in: Bundle.resources, compatibleWith: nil)
            $0.setSize(CGSize(width: 40, height: 40), animated: false)
        }
        .onTouchUpInside { [weak self] _ in
            print("Go to bank")
        }
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        self.contentView.backgroundColor = .clear
        backgroundView.backgroundColor = .clear
        let galleryButton = InputBarButtonItem()
        galleryButton.onKeyboardSwipeGesture { item, gesture in
            if gesture.direction == .left {
                item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 0, animated: true)
            } else if gesture.direction == .right {
                item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 36, animated: true)
            }
        }
        galleryButton.setSize(CGSize(width: 40, height: 40), animated: false)
        galleryButton.setImage(UIImage(named: "chat_inputbar_gallerry", in: Bundle.resources, compatibleWith: nil), for: .normal)
        galleryButton.imageView?.contentMode = .scaleAspectFit
        galleryButton.onTouchUpInside { [weak self] _ in
            print("Go to bank")
        }
        let emojiButton = InputBarButtonItem()
        emojiButton.onKeyboardSwipeGesture { item, gesture in
            if gesture.direction == .left {
                item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 0, animated: true)
            } else if gesture.direction == .right {
                item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 36, animated: true)
            }
        }
        emojiButton.setSize(CGSize(width: 40, height: 40), animated: false)
        emojiButton.setImage(UIImage(named: "chat_inputbar_emoji", in: Bundle.resources, compatibleWith: nil), for: .normal)
        emojiButton.imageView?.contentMode = .scaleAspectFit
        emojiButton.onTouchUpInside { [weak self] _ in
            print("Go to emoji")
        }
        inputTextView.backgroundColor = .clear
        inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        inputTextView.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        inputTextView.layer.borderWidth = 0.5
        inputTextView.layer.cornerRadius = 16.0
        inputTextView.layer.masksToBounds = true
        inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        setLeftStackViewWidthConstant(to: 94, animated: false)
        setStackViewItems([emojiButton, galleryButton], forStack: .left, animated: false)
        
        sendButton.configure {
            $0.setSize(CGSize(width: 52, height: 36), animated: false)
            $0.setImage(UIImage(named: "chat_avatar_default", in: Bundle.resources, compatibleWith: nil), for: .normal)
            $0.setTitle(nil, for: .normal)
        }.onEnabled { [weak self] (_) in
            self?.switchSend(show: false, animated: true)
        }.onDisabled { [weak self] (_) in
            self?.switchSend(show: true, animated: true)
        }.onTouchUpInside { [weak self] _ in
            self?.onClickSendButton?(self?.inputTextView.text ?? "")
        }
        inputTextView.placeholder = "Nhập tin nhắn..."
        separatorLine.backgroundColor = .clear
        switchSend(animated: false)
    }
    
    var isCollapsed: Bool = true
    var isQuickSend: Bool = false
    func switchSend(show: Bool = true, animated: Bool = true) {
        if isQuickSend == show {
            return
        }
        isQuickSend = show
        self.setupRightStackView(show: show, collapsed: isCollapsed, animated: animated)
    }
    
    private func setupRightStackView(show: Bool = true, collapsed: Bool, animated: Bool = true) {
        var rightButtons: [InputBarButtonItem] = []//[self.stickerItem.inputBarButtonItem]
        if show {
            rightButtons.append(transferButton)
        } else {
            rightButtons.append(sendButton)
        }
        var listRightItems: [InputBarButtonItem] = []
        var rightStackExpandWidth: CGFloat = 0
        for i in 0..<rightButtons.count {
            let button = rightButtons[i]
            listRightItems.append(button)
            rightStackExpandWidth += button.intrinsicContentSize.width
        }
        setStackViewItems(listRightItems, forStack: .right, animated: animated)
        setRightStackViewWidthConstant(to: rightStackExpandWidth, animated: animated)
    }
}
