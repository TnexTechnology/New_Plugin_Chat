//
//  ChatDetailViewController.swift
//  Tnex messenger
//
//  Created by Din Vu Dinh on 27/02/2022.
//

import UIKit
import PureLayout
import MatrixSDK

class ChatDetailViewController: BaseChatViewController {
    var shouldUseAlternativePresenter: Bool = false

    var messageSender: DemoChatMessageSender!
    let messagesSelector = BaseMessagesSelector()

    var dataSource: TnexChatDataSource! {
        didSet {
            self.chatDataSource = self.dataSource
            self.messageSender = self.dataSource.messageSender
        }
    }

    lazy var headerBar: ChatHeaderView = {
        let view = ChatHeaderView.newAutoLayout()
        view.onClickBack = {[weak self] in
            self?.actionBack()
        }
        return view
    }()
    
    @objc private func actionBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {[weak self] in
            self?.addHeaderView()
        }
        self.cellPanGestureHandlerConfig.allowReplyRevealing = true
        self.messagesSelector.delegate = self
        self.chatItemsDecorator = TnexChatItemsDecorator(messagesSelector: self.messagesSelector)
        self.replyActionHandler = TnexReplyActionHandler(presentingViewController: self)
        self.collectionView?.backgroundColor = UIColor(red: 0.008, green: 0.0, blue: 0.212, alpha: 1)
//        self.changeCollectionViewTopMarginTo(-ChatHeaderView.headerBarHeight, duration: 0.3)
        addBackgroundInputBar()
        
        
    }
    
    private func addBackgroundInputBar() {
        let backgroundInputView = InputBarBackgroundView()
        backgroundInputView.backgroundColor = .clear
        backgroundInputView.clipsToBounds = true
        self.view.insertSubview(backgroundInputView, belowSubview: inputBarContainer)
        backgroundInputView.translatesAutoresizingMaskIntoConstraints = false
        backgroundInputView.leftAnchor.constraint(equalTo: inputBarContainer.leftAnchor, constant: 0).isActive = true
        backgroundInputView.rightAnchor.constraint(equalTo: inputBarContainer.rightAnchor, constant: 0).isActive = true
        backgroundInputView.bottomAnchor.constraint(equalTo: inputBarContainer.bottomAnchor, constant: 0).isActive = true
        backgroundInputView.topAnchor.constraint(equalTo: inputBarContainer.topAnchor, constant: -5).isActive = true
        inputContentContainer.backgroundColor = .clear
        inputBarContainer.backgroundColor = .clear
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: false)
//    }
    
    private func addHeaderView() {
        view.addSubview(headerBar)
        headerBar.autoPinEdge(toSuperviewEdge: .top)
        headerBar.autoPinEdge(toSuperviewSafeArea: .left)
        headerBar.autoPinEdge(toSuperviewSafeArea: .right)
        let topPadding: CGFloat = self.view.safeAreaInsets.top

//        let topPadding: CGFloat = UIApplication.key?.safeAreaInsets.top ?? 20
        self.headerBar.autoSetDimension(.height, toSize: ChatHeaderView.headerBarHeight + topPadding)
        self.headerBar.infoView.displayNameLabel.text = self.dataSource.getDisplayName()
        self.headerBar.avatarView.imageView.sd_setImage(with: self.dataSource.getAvatarURL())
        dataSource.room?.room.liveTimeline({[weak self] timeline in
            if let self = self, let timeline = timeline {
                if let partnerUser = timeline.state?.members.members.first(where: {$0.userId != APIManager.shared.userId}), let mxUser = self.dataSource.room.room.mxSession.user(withUserId: partnerUser.userId) {
                    self.headerBar.updateUser(user: mxUser)
                }
            }
        })
    }

    var chatInputPresenter: AnyObject!
    override func createChatInputView() -> UIView {
        let chatInputView = TnexContainerInputBar.loadNib()
        chatInputView.backgroundColor = .clear
        let inputbar = TnexInputBar()
        chatInputView.addSubview(inputbar)
        inputbar.fillSuperview()
        inputbar.backgroundColor = .clear
        inputbar.onClickSendButton = {[weak self] text in
            self?.dataSource.addTextMessage(text)
        }
        return chatInputView
    }
    

    override func createPresenterBuilders() -> [ChatItemType: [ChatItemPresenterBuilderProtocol]] {

        let textMessagePresenter = TextMessagePresenterBuilder(
            viewModelBuilder: self.createTextMessageViewModelBuilder(),
            interactionHandler: DemoMessageInteractionHandler(messageSender: self.messageSender, messagesSelector: self.messagesSelector)
        )
        textMessagePresenter.baseMessageStyle = BaseMessageCollectionViewCellAvatarStyle()

        let photoMessagePresenter = PhotoMessagePresenterBuilder(
            viewModelBuilder: DemoPhotoMessageViewModelBuilder(),
            interactionHandler: DemoMessageInteractionHandler(messageSender: self.messageSender, messagesSelector: self.messagesSelector)
        )
        photoMessagePresenter.baseCellStyle = BaseMessageCollectionViewCellAvatarStyle()

        return [
            DemoTextMessageModel.chatItemType: [textMessagePresenter],
            DemoPhotoMessageModel.chatItemType: [photoMessagePresenter],
            SendingStatusModel.chatItemType: [SendingStatusPresenterBuilder()],
            DaySeparatorModel.chatItemType: [DaySeparatorPresenterBuilder()],
            TimeSeparatorModel.chatItemType: [TimeSeparatorPresenterBuilder()],
            SenderInfoModel.chatItemType: [SenderInfoPresenterBuilder()]
        ]
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
    func messagesSelector(_ messagesSelector: MessagesSelectorProtocol, didSelectMessage: MessageModelProtocol) {
        self.enqueueModelUpdate(updateType: .normal)
    }

    func messagesSelector(_ messagesSelector: MessagesSelectorProtocol, didDeselectMessage: MessageModelProtocol) {
        self.enqueueModelUpdate(updateType: .normal)
    }
}
