//
//  TnexChatViewController.swift
//  Runner
//
//  Created by MacOS on 14/03/2022.
//

import Foundation
import Flutter
import tnexchat

class TnexChatViewController: ChatDetailViewController {
    var coordinatorDelegate: ChatCoordinatorDelegate?
    private var eventSink: FlutterEventSink?
    var swipeBackGesture: UIPanGestureRecognizer?
    
   var flutterViewController: FlutterViewController!
    
    override func viewDidLoad() {
        self.view.backgroundColor = .clear
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.flutterViewController = appDelegate.flutterVC
        super.viewDidLoad()
        self.swipeBackGesture = addSwipeBackGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.isHidden = false
    }
    
    override func viewWillDisappear (_ animated: Bool) {
        self.view.endEditing(true)
        super.viewWillDisappear(animated)
    }
    
    deinit {
        print("TnexChatViewController deinit")
        removeSwipeBackGesture()
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension TnexChatViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
