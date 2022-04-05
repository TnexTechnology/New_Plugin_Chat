//
//  ConfirmLeavingViewController.swift
//  tnexchat
//
//  Created by Din Vu Dinh on 04/04/2022.
//

import UIKit
import FittedSheets

typealias RemoveConversationCallback = () -> Void

class ConfirmLeavingViewController: UIViewController {
    
    var removeConversationCallback: RemoveConversationCallback?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func removeConversation(_ sender: Any) {
        self.removeConversationCallback?()
        self.dismiss(animated: true)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true)
    }

    deinit {
        print("Deinit ConfirmLeavingViewController")
    }
}

extension ConfirmLeavingViewController {
    class func showPopupConfirmLeaving(from viewController: UIViewController, removeConversationCallback: RemoveConversationCallback?) {
        let vc = ConfirmLeavingViewController(nibName: "ConfirmLeavingViewController", bundle: Bundle.resources)
        vc.removeConversationCallback = removeConversationCallback
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        let heightScreen = screenWidth*1080/1042 + 20
        let sheetController = SheetViewController(
            controller: vc,
            sizes: [.fixed(heightScreen)])
        sheetController.adjustForBottomSafeArea = false
        sheetController.blurBottomSafeArea = false
        sheetController.pullBarView.isHidden = true
        sheetController.view.backgroundColor = .clear
        viewController.present(sheetController, animated: false, completion: nil)
    }
}
