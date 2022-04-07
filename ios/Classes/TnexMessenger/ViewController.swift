//
//  ViewController.swift
//  Tnex messenger
//
//  Created by MacOS on 27/02/2022.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        MatrixManager.shared
        
    }

    @IBAction func login(_ sender: Any) {
        MatrixManager.shared.loginToken {[weak self] isSuccess in
            if isSuccess {
                guard let rooms = MatrixManager.shared.getRooms() else { return }
                let vc = ConversationViewController(rooms: rooms)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

