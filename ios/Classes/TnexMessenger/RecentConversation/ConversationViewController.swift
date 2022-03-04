//
//  ConversationViewController.swift
//  Tnex messenger
//
//  Created by Din Vu Dinh on 27/02/2022.
//

import UIKit
import MatrixSDK

class ConversationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var rooms: [TnexRoom] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configTableView()
    }

    init(rooms: [TnexRoom]) {
        super.init(nibName: "ConversationViewController", bundle: Bundle.resources)
        self.rooms = rooms
        APIManager.shared.startListeningForRoomEvents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "ConversationCell", bundle: Bundle.resources), forCellReuseIdentifier: "ConversationCell")
    }

}


extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        let room = rooms[indexPath.row]
        let lastMessage = room.lastMessage
        cell.titleLabel.text = room.summary.displayname
        cell.contentLabel.text = lastMessage
        if let avatar = room.roomAvatarURL {
            cell.avatarImageVIew.sd_setImage(with: avatar)
        }
        let formatter4 = DateFormatter()
        formatter4.dateFormat = "HH:mm E, d MMM y"
        
        cell.timeLabel.text = formatter4.string(from: room.summary.lastMessageDate)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(80)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = rooms[indexPath.row]
        let dataSource = TnexChatDataSource(room: room)
        let vc = ChatDetailViewController()
        vc.dataSource = dataSource
//        let vc = ChatDetailTableViewController()
//        vc.events = room.events()
        self.navigationController?.pushViewController(vc, animated: true)
        
//        self.getRoom(room: room)
    }
    
    func getRoom(room: TnexRoom) {
        room.room.liveTimeline { timeline in
            if let user = timeline?.state?.members.members.first {
                let mxUser: MXUser = room.room.mxSession.user(withUserId: user.userId)
                print(mxUser.displayname)
                print(mxUser.currentlyActive)
                print(mxUser.lastActiveAgo)
                let time = mxUser.lastActiveAgo / 1000
                print(time/60)
            }
            print(timeline)
            print(timeline?.state?.members.members.first?.displayname)
//            print(timeline?.room.events().wrapped.count)
        }
    }
}
