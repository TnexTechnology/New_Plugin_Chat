//
//  ChatDetailViewController.swift
//  Tnex messenger
//
//  Created by Din Vu Dinh on 27/02/2022.
//

import UIKit
import PureLayout
import MatrixSDK
import InputBarAccessoryView
import FittedSheets

open class ChatDetailViewController: BaseChatViewController {
    var shouldUseAlternativePresenter: Bool = false

    var messageSender: DemoChatMessageSender!
    let messagesSelector = BaseMessagesSelector()
    private let roomId: String
    public var dataSource: TnexChatDataSource! {
        didSet {
            self.chatDataSource = self.dataSource
        }
    }

    lazy var headerBar: ChatHeaderView = {
        let view = ChatHeaderView.newAutoLayout()
        view.onClickBack = {[weak self] in
            self?.actionBack()
        }
        view.onClickShowprofile = {[weak self] userId in
            self?.showProfileUser(userId: userId)
        }
        view.onClickLeaving = {[weak self] in
            self?.showPopupConfirmLeaving()
        }
        view.onClickMute = {[weak self] in
            self?.muteConversation()
        }
        return view
    }()
    
    @objc open func actionBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    public init(roomId: String) {
        self.roomId = roomId
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        self.dataSource = TnexChatDataSource(roomId: roomId)
        self.messagesSelector.labelDelegate = self
        super.viewDidLoad()
        DispatchQueue.main.async {[weak self] in
            self?.addHeaderView()
        }
        self.cellPanGestureHandlerConfig.allowReplyRevealing = true
        self.messagesSelector.delegate = self
        self.chatItemsDecorator = TnexChatItemsDecorator(messagesSelector: self.messagesSelector, chatDataSource: dataSource)
        self.replyActionHandler = TnexReplyActionHandler(presentingViewController: self)
        self.messagesCollectionView.backgroundColor = UIColor(red: 0.008, green: 0.0, blue: 0.212, alpha: 1)
        self.changeCollectionViewTopMarginTo(-ChatHeaderView.headerBarHeight/2, duration: 0.3)
        addBackgroundInputBar()
    }
    
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.dataSource.markReadAll()
    }
    
    private func addBackgroundInputBar() {
        let backgroundInputView = InputBarBackgroundView()
        backgroundInputView.backgroundColor = .clear
        backgroundInputView.clipsToBounds = true
        self.view.insertSubview(backgroundInputView, belowSubview: inputBarContainer)
        backgroundInputView.translatesAutoresizingMaskIntoConstraints = false
        backgroundInputView.leftAnchor.constraint(equalTo: inputBarContainer.leftAnchor, constant: 0).isActive = true
        backgroundInputView.rightAnchor.constraint(equalTo: inputBarContainer.rightAnchor, constant: 0).isActive = true
        backgroundInputView.bottomAnchor.constraint(equalTo: inputContentContainer.bottomAnchor, constant: 0).isActive = true
        backgroundInputView.topAnchor.constraint(equalTo: inputBarContainer.topAnchor, constant: -5).isActive = true
        inputContentContainer.backgroundColor = .clear
        inputBarContainer.backgroundColor = .clear
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        dataSource.listenTypingNotifications()
    }

    private func addHeaderView() {
        view.addSubview(headerBar)
        headerBar.autoPinEdge(toSuperviewEdge: .top)
        headerBar.autoPinEdge(toSuperviewSafeArea: .left)
        headerBar.autoPinEdge(toSuperviewSafeArea: .right)
        let topPadding: CGFloat = self.view.safeAreaInsets.top

//        let topPadding: CGFloat = UIApplication.key?.safeAreaInsets.top ?? 20
        self.headerBar.autoSetDimension(.height, toSize: ChatHeaderView.headerBarHeight + topPadding)
        self.headerBar.infoView.displayNameLabel.text = self.dataSource.getDisplayName()
//        self.headerBar.avatarView.imageView.sd_setImage(with: self.dataSource.getAvatarURL())
        dataSource.room?.room.liveTimeline({[weak self] timeline in
            if let self = self, let timeline = timeline {
                if let partnerUser = timeline.state?.members.members.first(where: {$0.userId != APIManager.shared.userId}) {
                    self.dataSource.partnerId = partnerUser.userId
                    self.dataSource.partnerDisplayName = partnerUser.displayname
                    self.headerBar.updateUser(member: partnerUser)
                    if let mxUser = self.dataSource.room?.room.mxSession.user(withUserId: partnerUser.userId) {
                        self.headerBar.updateStatusUser(user: mxUser)
                    }
                }
            }
        })
    }

    var chatInputPresenter: AnyObject!
    open override func createChatInputView() -> UIView {
        let chatInputView = TnexContainerInputBar.loadNib()
        chatInputView.backgroundColor = .clear
        let inputbar = TnexInputBar()
        inputbar.delegate = self
        inputbar.presentingController = self
        chatInputView.addSubview(inputbar)
        inputbar.fillSuperview()
        inputbar.backgroundColor = .clear
        inputbar.onClickSendButton = {[weak self] text in
            inputbar.inputTextView.text = ""
            self?.dataSource.addTextMessage(text)
        }
        inputbar.photoInputHandler = { [weak self] image in
            self?.dataSource.addPhotoMessage(image)
        }
        return chatInputView
    }
    
    open override func createPresenterBuilders() -> [ChatItemType: [ChatItemPresenterBuilderProtocol]] {

        let textMessagePresenter = TextMessagePresenterBuilder(
            viewModelBuilder: self.createTextMessageViewModelBuilder(),
            interactionHandler: TnexMessageInteractionHandler(chatviewController: self, messagesSelector: self.messagesSelector)
        )
        textMessagePresenter.baseMessageStyle = BaseMessageCollectionViewCellAvatarStyle()
        let photoMessagePresenter = createPhotoMessagePresenterBuilders()
//        let photoMessagePresenter = PhotoMessagePresenterBuilder(
//            viewModelBuilder: DemoPhotoMessageViewModelBuilder(),
//            interactionHandler: DemoMessageInteractionHandler(messageSender: self.messageSender, messagesSelector: self.messagesSelector)
//        )
//        photoMessagePresenter.baseCellStyle = BaseMessageCollectionViewCellAvatarStyle()

        return [
            DemoTextMessageModel.chatItemType: [textMessagePresenter],
            TnextPhotoMessageModel.chatItemType: [photoMessagePresenter],
            SendingStatusModel.chatItemType: [SendingStatusPresenterBuilder()],
            DaySeparatorModel.chatItemType: [DaySeparatorPresenterBuilder()],
            TimeSeparatorModel.chatItemType: [TimeSeparatorPresenterBuilder()],
            SenderInfoModel.chatItemType: [SenderInfoPresenterBuilder()],
            ActionMessageModel.chatItemType: [ActionMessagePresenterBuilder()],
            TypingModel.chatItemType: [TypingPresenterBuilder()]
        ]
    }

    func createPhotoMessagePresenterBuilders() -> ChatItemPresenterBuilderProtocol {
        let photoMessagePresenter = PhotoMessagePresenterBuilder(
            viewModelBuilder: DemoPhotoMessageViewModelBuilder(),
            interactionHandler: TnexPhotoMessageInteractionHandler(chatviewController: self, messagesSelector: self.messagesSelector)
        )
        photoMessagePresenter.baseCellStyle = BaseMessageCollectionViewCellAvatarStyle()
        return photoMessagePresenter
    }
    
    func createTextMessageViewModelBuilder() -> DemoTextMessageViewModelBuilder {
        return DemoTextMessageViewModelBuilder()
    }

    func createChatInputItems() -> [ChatInputItemProtocol] {
        var items = [ChatInputItemProtocol]()
        items.append(self.createTextInputItem())
        items.append(self.createPhotoInputItem())
        return items
    }

    private func createTextInputItem() -> TextChatInputItem {
        let item = TextChatInputItem()
        item.textInputHandler = { [weak self] text in
            self?.dataSource.addTextMessage(text)
        }
        return item
    }

    private func createPhotoInputItem() -> PhotosChatInputItem {
        let item = PhotosChatInputItem(presentingController: self)
        item.photoInputHandler = { [weak self] image, _ in
            self?.dataSource.addPhotoMessage(image)
        }
        return item
    }

}

extension ChatDetailViewController: MessagesSelectorDelegate {
    public func messagesSelector(_ messagesSelector: MessagesSelectorProtocol, didSelectMessage: MessageModelProtocol) {
        self.enqueueModelUpdate(updateType: .normal)
    }

    public func messagesSelector(_ messagesSelector: MessagesSelectorProtocol, didDeselectMessage: MessageModelProtocol) {
        self.enqueueModelUpdate(updateType: .normal)
    }
}


extension ChatDetailViewController: InputBarAccessoryViewDelegate {
    public func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    }
    
    public func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if !text.isEmpty {
            self.dataSource.typingTracker.startTimerSendTyping()
        }
        
    }
}

extension ChatDetailViewController {
    func showProfileUser(userId: String) {
        self.navigationController?.popViewController(animated: true)
        NetworkManager.shared.showProfile(userId: userId)
    }
    
    func showPopupConfirmLeaving() {
        ConfirmLeavingViewController.showPopupConfirmLeaving(from: self) {[weak self] in
            self?.dataSource.room?.room.leave(completion: { response in
                switch response {
                case .success:
                    print("Xoa cuoc hoi thoai thanh cong")
                case .failure(let error):
                    print("Xoa cuoc hoi thoai that bai \(error.localizedDescription)")
                }
                self?.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    func muteConversation() {
        guard let room = self.dataSource.room?.room else { return }
        let notificationService = MXRoomNotificationSettingsService(room: room)
        notificationService.update(state: .mute) {
            print("update thanh cong")
        }
        
    }
   
}
