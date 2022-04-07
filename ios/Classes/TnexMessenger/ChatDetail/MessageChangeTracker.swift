//
//  MessageChangeTracker.swift
//  tnexchat
//
//  Created by Din Vu Dinh on 07/04/2022.
//

import Foundation

protocol MessageChangeProtocol {
    var scrollBottomButton: UIButton { get }
    func showScrollButton()
    func hideScrollButton()
}

class MessageChangeTracker: MessageChangeProtocol {
    private var parentView: UIView
    var onClickScrollToBottom: (() -> Void)?
    private weak var chatContainerVC: ChatDetailViewController?
    internal lazy var scrollBottomButton: UIButton = {
        let button = UIButton.newAutoLayout()
        button.addTarget(self, action: #selector(MessageChangeTracker.focusScrollToBottom), for: .touchUpInside)
        button.setImage(UIImage(named: "chat-scroll-bottom", in: Bundle.resources, compatibleWith: nil), for: .normal)
        button.autoSetDimension(.height, toSize: 36)
        button.autoSetDimension(.width, toSize: 36)
        button.isHidden = true
        return button
    }()
    
    @objc private func focusScrollToBottom() {
        self.onClickScrollToBottom?()
    }
    
    var inputBarContainer: UIView?
    var bottomConstraintScrollButton: NSLayoutConstraint?
    
    init(viewController: UIViewController, inputBarContainer: UIView?) {
        self.inputBarContainer = inputBarContainer
        if let vc = viewController as? ChatDetailViewController {
            self.chatContainerVC = vc
        }
        let view = viewController.view!
        self.parentView = view
        self.addScrollBottomButton(parentView: view)
    }
    
    private func addScrollBottomButton(parentView: UIView) {
        guard let inputBarContainer = inputBarContainer else {
            return
        }
        parentView.insertSubview(scrollBottomButton, belowSubview: inputBarContainer)
        scrollBottomButton.translatesAutoresizingMaskIntoConstraints = false
        bottomConstraintScrollButton = scrollBottomButton.bottomAnchor.constraint(equalTo: inputBarContainer.topAnchor, constant: 46)
        let trailing = scrollBottomButton.trailingAnchor.constraint(equalTo: inputBarContainer.trailingAnchor, constant: -12)
        let width = scrollBottomButton.widthAnchor.constraint(equalToConstant: 36)
        let height = scrollBottomButton.heightAnchor.constraint(equalToConstant: 36)
        NSLayoutConstraint.activate([bottomConstraintScrollButton!, trailing, width, height])
        
    }
    
    deinit {
        print("Deinit MessageChangeTracker")
    }
}

extension MessageChangeTracker {
   
    func showScrollButton() {
        guard self.scrollBottomButton.isHidden else { return }
        self.scrollBottomButton.isHidden = false
        self.bottomConstraintScrollButton?.constant = -12
        UIView.animate(withDuration: 0.3) {
            self.parentView.layoutIfNeeded()
        }
    }
    
    func hideScrollButton() {
        guard !self.scrollBottomButton.isHidden else { return }
        self.bottomConstraintScrollButton?.constant = 36
        self.scrollBottomButton.isHidden = true
    }
}
