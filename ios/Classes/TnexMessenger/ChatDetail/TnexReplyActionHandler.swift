//
//  TnexReplyActionHandler.swift
//  Tnex messenger
//
//  Created by Din Vu Dinh on 28/02/2022.
//

import UIKit

final class TnexReplyActionHandler: ReplyActionHandler {

    private weak var presentingViewController: UIViewController?

    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }

    func handleReply(for: ChatItemProtocol) {
        let alert = UIAlertController(
            title: "Reply message with swipe",
            message: nil,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "OK", style: .cancel, handler: nil))
        presentingViewController?.present(alert, animated: true, completion: nil)
    }
}

