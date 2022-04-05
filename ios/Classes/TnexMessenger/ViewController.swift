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
        APIManager.shared
        
    }

    @IBAction func login(_ sender: Any) {
        APIManager.shared.loginToken {[weak self] isSuccess in
            if isSuccess {
                guard let rooms = APIManager.shared.getRooms() else { return }
                let vc = ConversationViewController(rooms: rooms)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

