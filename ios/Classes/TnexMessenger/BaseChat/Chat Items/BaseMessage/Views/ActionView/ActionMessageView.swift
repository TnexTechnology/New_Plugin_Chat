//
//  ActionMessageView.swift
//  MessageKit
//
//  Created by Gapo on 27/06/2021.
//

import UIKit

open class ActionMessageView: UIView {
    
    open var imageView: UIImageView? {
        if let img = self.actionReplyMediaView?.imageView {
            return img
        }
        return nil
    }
    
    open var actionRemoveMessageView: ActionRemoveMessageView?
    open var actionReplyTextView: ActionReplyTextView?
    open var actionReplyMediaView: ActionReplyMediaView?

    init(action: ActionMessageType) {
        super.init(frame: .zero)
    }
    
    func applyUI(isOutgoingMessage: Bool, action: ActionMessageType, attributedText: NSAttributedString?){
        switch action {
        case .reply(let replyMessage):
            self.setupContent(message: replyMessage, attributedText: attributedText)
        case .remove(let content):
            self.addActionRemoveMessageView(attributedText: attributedText)
        default:
            break
        }

    }
    
    func addActionRemoveMessageView(attributedText: NSAttributedString?){
        self.actionRemoveMessageView = ActionRemoveMessageView()
        self.actionRemoveMessageView?.contentLabel.attributedText = attributedText
        self.addActionView(view: self.actionRemoveMessageView!, bottomPadding: MessageConstants.ActionView.RemoveView.bottomPadding)
    }
   
    func addActionReplyTextView(attributedText: NSAttributedString?){
        self.actionReplyTextView?.contentLabel.attributedText = attributedText
        self.actionReplyTextView = ActionReplyTextView()
        self.actionReplyTextView?.contentLabel.attributedText = attributedText
        self.addActionView(view: self.actionReplyTextView!, bottomPadding: MessageConstants.ActionView.ReplyView.bottomPadding)
    }
    
    func addActionReplyMediaView(attributedText: NSAttributedString?, medias: [String]){
        self.actionReplyMediaView = ActionReplyMediaView()
        self.actionReplyMediaView?.messageLabel.attributedText = attributedText
        self.addActionView(view: self.actionReplyMediaView!, bottomPadding: MessageConstants.ActionView.ReplyView.bottomPadding)
    }
    
    func addActionReplyMediaView(attributedText: NSAttributedString?, image: UIImage){
        self.actionReplyMediaView = ActionReplyMediaView()
        self.actionReplyMediaView?.messageLabel.attributedText = attributedText
        self.addActionView(view: self.actionReplyMediaView!, bottomPadding: MessageConstants.ActionView.ReplyView.bottomPadding)
        self.actionReplyMediaView?.imageView.image = image
    }
    
    private func addActionView(view: UIView, bottomPadding: CGFloat = 0){
        self.subviews.forEach({$0.removeFromSuperview()})
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottomPadding)
        ])
    }
    
    private func setupContent(message: ReplyMessageType, attributedText: NSAttributedString?){
        if let medias = message.medias {
            self.addActionReplyMediaView(attributedText: attributedText, medias: medias)
        } else if let thumb = message.thumb {
            self.addActionReplyMediaView(attributedText: attributedText, image: thumb)
        } else {
            self.addActionReplyTextView(attributedText: attributedText)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clearData() {
        actionRemoveMessageView?.removeFromSuperview()
        actionReplyTextView?.removeFromSuperview()
        actionReplyMediaView?.removeFromSuperview()
    }

}

