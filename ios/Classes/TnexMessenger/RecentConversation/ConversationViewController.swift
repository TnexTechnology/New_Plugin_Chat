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

class ConversationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()
    var dataSource: RxTableViewSectionedAnimatedDataSource<ConversationsSection>!
    var dataSubject: PublishSubject<[ConversationsSection]>!
    var sections: [ConversationsSection] = []
    
    private var rooms: [TnexRoom] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
        setupRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    init(rooms: [TnexRoom]) {
        super.init(nibName: "ConversationViewController", bundle: Bundle.resources)
        self.rooms = rooms
        MatrixManager.shared.startListeningForRoomEvents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configTableView() {
        self.tableView.delegate = self
//        self.tableView.dataSource = self
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
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm E, d MMM y"
        
        cell.timeLabel.text = formatter.string(from: room.summary.lastMessageDate)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(80)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let room = rooms[indexPath.row]
//        let vc = ChatDetailViewController(roomId: room.room.roomId ?? "")
//        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ConversationViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        switch self.dataSource[indexPath] {
        case .threadItem(item: _):
            var actions: [SwipeAction] = []
            actions.append(removeConversationAction())
            actions.append(onOffNoti())
            return actions
        default:
            return nil
        }
    }
    
    func setupRx() {
        let dataSource = self.getDataSource()
        let dataSubject = PublishSubject<[ConversationsSection]>()
        dataSubject.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: self.disposeBag)
        self.dataSubject = dataSubject
        self.dataSource = dataSource
        let conversationItems: [ConversationSectionItem] = rooms.map{ConversationSectionItem.threadItem(item: ConversationCellViewModel(by: $0))}
        sections = [ConversationsSection.threadsSection(title: "", items: conversationItems)]
        self.dataSubject.onNext(sections)
    }

    func getDataSource() -> RxTableViewSectionedAnimatedDataSource<ConversationsSection> {
        let dataSource = RxTableViewSectionedAnimatedDataSource<ConversationsSection>(
            configureCell: { [weak self] (dataSource, tableView, idxPath, _) in
                guard let self = self else { return UITableViewCell() }
                switch dataSource[idxPath] {
                case let .threadItem(item: thread):
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: idxPath) as! ConversationCell
                    cell.viewModel = thread
                    cell.delegate = self
                    return cell
                case .empty:
                    let cell = UITableViewCell()
                    return cell
                }
            }
        )

        dataSource.decideViewTransition = { [unowned self] _, _, _ in
            return .animated
        }
        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .automatic, reloadAnimation: .fade, deleteAnimation: .fade)

        return dataSource
    }
    
    private func removeConversationAction() -> SwipeAction {
        let action = SwipeAction(style: .default, title: nil) { [weak self] _, indexPath in
            print("remove!!!!")
        }
        action.hidesWhenSelected = true
        action.image = UIImage(named: "icon_list_chat_delete", in: Bundle.resources, with: nil)
        return action
    }
    
    private func onOffNoti() -> SwipeAction {
        let action = SwipeAction(style: .default, title: nil) { [weak self] _, indexPath in
            print("onoffnoti!!!!")
        }
        action.hidesWhenSelected = true
        action.image = UIImage(named: "icon_list_chat_noti_disable", in: Bundle.resources, with: nil)
        return action
    }
    
}
