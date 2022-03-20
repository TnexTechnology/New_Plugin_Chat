//
//  TnexInputBar.swift
//  Tnex messenger
//
//  Created by Din Vu Dinh on 02/03/2022.
//

import UIKit
import InputBarAccessoryView
import ISEmojiView

@objc open class TnexInputBar: InputBarAccessoryView {
    
    var onClickSendButton: ((_ text: String) -> Void)?
    var photoInputHandler: ((UIImage, PhotosInputViewPhotoSource) -> Void)?
    var emojInputHandler: (() -> Void)?
    var emojis: [EmojiCategory]?
    public var cameraPermissionHandler: (() -> Void)?
    public var photosPermissionHandler: (() -> Void)?
    public weak var presentingController: UIViewController?
    
    lazy var transferButton: InputBarButtonItem = {
        let button = InputBarButtonItem()
        .configure {
            $0.spacing = .none
            $0.contentMode = .scaleAspectFill
            $0.image = UIImage(named: "chat_inpputbar_transfer", in: Bundle.resources, compatibleWith: nil)
            $0.setSize(CGSize(width: 40, height: 40), animated: false)
            $0.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        }
        .onTouchUpInside { [weak self] _ in
            print("Go to bank")
        }
        return button
    }()
    
    lazy var emojiView: EmojiView = {
        let keyboardSettings = KeyboardSettings(bottomType: BottomType.categories)
        keyboardSettings.customEmojis = emojis
        keyboardSettings.countOfRecentsEmojis = 20
        keyboardSettings.updateRecentEmojiImmediately = true
        let emojiView = EmojiView(keyboardSettings: keyboardSettings)
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.delegate = self
        return emojiView
    }()
    
    lazy var photosInputView: PhotosInputView = {
        let photosInputView = PhotosInputView(
            cameraPickerFactory: PhotosInputCameraPickerFactory(presentingViewControllerProvider: { [weak self] in self?.presentingController }),
            liveCameraCellPresenterFactory: LiveCameraCellPresenterFactory()
        )
        photosInputView.delegate = self
        return photosInputView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        self.contentView.backgroundColor = .clear
        backgroundView.backgroundColor = .clear
        let galleryButton = InputBarButtonItem()
        galleryButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
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
            guard let self = self else { return }
            self.tapAlphabetGesture.isEnabled = true
            self.onClickGallery()
        }
        let emojiButton = InputBarButtonItem()
        emojiButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
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
            if let self = self {
                self.tapAlphabetGesture.isEnabled = true
                self.inputTextView.inputView = nil
                self.inputTextView.inputView = self.emojiView
                self.inputTextView.reloadInputViews()
                self.inputTextView.becomeFirstResponder()
            }
        }
        inputTextView.backgroundColor = .clear
        inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        inputTextView.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        inputTextView.layer.borderWidth = 1.0
        inputTextView.layer.cornerRadius = 15.0
        inputTextView.layer.masksToBounds = true
        inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        setLeftStackViewWidthConstant(to: 90, animated: false)
        setStackViewItems([emojiButton, galleryButton], forStack: .left, animated: false)
        
        sendButton.configure {
            $0.setSize(CGSize(width: 52, height: 36), animated: false)
            $0.setImage(UIImage(named: "chat_btn_send", in: Bundle.resources, compatibleWith: nil), for: .normal)
            $0.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
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
        textViewActions()
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
    var tapAlphabetGesture: UITapGestureRecognizer!
    private func textViewActions() {
        inputTextView.placeholder = "Nhập tin nhắn..."
        tapAlphabetGesture = UITapGestureRecognizer(target: self, action: #selector(TnexInputBar.textViewTap))
        inputTextView.addGestureRecognizer(tapAlphabetGesture)
        tapAlphabetGesture.isEnabled = false
//        NotificationCenter.default.addObserver(self, selector: #selector(TnexInputBar.inputTextViewDidEndEditing), name: UITextView.textDidEndEditingNotification, object: inputTextView)
    }
    @objc func textViewTap() {
        tapAlphabetGesture.isEnabled = false
        showKeyboard()
    }

    func showKeyboard() {
        inputTextView.inputView = nil
        inputTextView.reloadInputViews()
        inputTextView.becomeFirstResponder()
    }
    
    private func onClickGallery() {
        PermissionManager.shared.checkPhotoPermission {[weak self] granted in
            if let self = self, granted {
                self.inputTextView.inputView = nil
                self.inputTextView.inputView = self.photosInputView
                self.inputTextView.reloadInputViews()
                self.inputTextView.becomeFirstResponder()
            }
        }
    }
}

extension TnexInputBar: EmojiViewDelegate {
    public func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
        inputTextView.insertText(emoji)
    }
    
    public func emojiViewDidPressChangeKeyboardButton(_ emojiView: EmojiView) {
        inputTextView.inputView = nil
        inputTextView.keyboardType = .default
        inputTextView.reloadInputViews()
    }
    
    public func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {
        inputTextView.deleteBackward()
    }
    
    public func emojiViewDidPressDismissKeyboardButton(_ emojiView: EmojiView) {
        inputTextView.resignFirstResponder()
    }
}

extension TnexInputBar: PhotosInputViewDelegate {
    public func inputView(_ inputView: PhotosInputViewProtocol,
                          didSelectImage image: UIImage,
                          source: PhotosInputViewPhotoSource) {
        self.photoInputHandler?(image, source)
    }

    public func inputViewDidRequestCameraPermission(_ inputView: PhotosInputViewProtocol) {
        self.cameraPermissionHandler?()
    }

    public func inputViewDidRequestPhotoLibraryPermission(_ inputView: PhotosInputViewProtocol) {
        self.photosPermissionHandler?()
    }
}
