//
//  ConversationViewController.swift
//  Tnex messenger
//
//  Created by Din Vu Dinh on 27/02/2022.
//

import UIKit
import MatrixSDK
import RxSwift
import RxDataSources
import SwipeCellKit

open class ConversationViewController: UIViewController {
    
    private var rooms: [TnexRoom] = []
    private var conversationListView: ConversationListView!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.fromHex("#011830")
        conversationListView = ConversationListView(rooms: rooms)
        view.addSubview(conversationListView)
        conversationListView.fillSuperview()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @IBAction func reload(_ sender: Any) {
        print("reload!!!!!")
//        self.dataSubject.onNext(self.sections)
    }
    public init(rooms: [TnexRoom]) {
        super.init(nibName: nil, bundle: nil)
        self.rooms = rooms
        MatrixManager.shared.startListeningForRoomEvents()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
