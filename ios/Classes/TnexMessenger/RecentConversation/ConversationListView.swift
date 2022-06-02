//
//  ConversationListView.swift
//  Runner
//
//  Created by Din Vu Dinh on 01/06/2022.
//

import UIKit
import MatrixSDK
import RxSwift
import RxDataSources
import SwipeCellKit

open class ConversationListView: UIView {

    private var rooms: [TnexRoom] = []
    let disposeBag = DisposeBag()
    var dataSource: RxTableViewSectionedAnimatedDataSource<ConversationsSection>!
    var dataSubject: PublishSubject<[ConversationsSection]>!
    var sections: [ConversationsSection] = []
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        return table
    }()
    
    
    public init(rooms: [TnexRoom]) {
        super.init(frame: .zero)
        self.rooms = rooms
        self.backgroundColor = UIColor.fromHex("#011830")
        setupTableView()
        setupRx()
    }
    
    private func setupTableView() {
        self.addSubview(tableView)
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "ConversationCell", bundle: Bundle.resources), forCellReuseIdentifier: "ConversationCell")
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.tableView.frame = self.bounds
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ConversationListView: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(92)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension ConversationListView: SwipeTableViewCellDelegate {
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .right {
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
        return nil
        
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
                    cell.selectionStyle = .none
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
        action.backgroundColor = UIColor.fromHex("#011830")
        return action
    }
    
    private func onOffNoti() -> SwipeAction {
        let action = SwipeAction(style: .default, title: nil) { [weak self] _, indexPath in
            print("onoffnoti!!!!")
        }
        action.hidesWhenSelected = true
        action.backgroundColor = UIColor.fromHex("#011830")
        action.image = UIImage(named: "icon_list_chat_noti_disable", in: Bundle.resources, with: nil)
        return action
    }
    
}