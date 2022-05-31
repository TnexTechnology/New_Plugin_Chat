//
//  ConversationsSection.swift
//  tnexchat
//
//  Created by Din Vu Dinh on 30/05/2022.
//

import UIKit
import RxDataSources

enum ConversationsSection {
    case threadsSection(title: String, items: [Item])
    case empty(title: String, items: [Item])
}

extension ConversationsSection: AnimatableSectionModelType {

    var identity: String {
        switch self {
        case .threadsSection(let title, _):
            return title
        case .empty(let title, _):
            return title
        }
    }

    typealias Identity = String

}

extension ConversationsSection: SectionModelType {

    init(original: ConversationsSection, items: [ConversationSectionItem]) {
        switch original {
        case let .threadsSection(title: title, items: _):
            self = .threadsSection(title: title, items: items)
        case .empty(let title, items: _):
            self = .empty(title: title, items: items)
        }
    }

    typealias Item = ConversationSectionItem

    var items: [ConversationSectionItem] {
        switch self {
        case .threadsSection(title: _, items: let items):
            return items.map { $0 }
        case .empty(title: _, items: let items):
            return items.map { $0 }
        }
    }

    var title: String {
        switch self {
        case .threadsSection:
            return "Chat"
        case .empty:
            return "Empty"
        }
    }
}

enum ConversationSectionItem {
    case threadItem(item: ConversationCellViewModel)
    case empty
}

extension ConversationSectionItem: IdentifiableType, Equatable {

    typealias Identity = String

    var identity: String {
        switch self {
        case .threadItem(let item):
            return item.room?.roomId ?? ""
        case .empty:
            return "Empty"
        }
    }

    static func ==(lhs: ConversationSectionItem, rhs: ConversationSectionItem) -> Bool {
        switch (lhs, rhs) {
        case (.threadItem(let lhsItem), .threadItem(let rhsItem)):
            return lhsItem == rhsItem
        case (.empty, .empty):
            return true
        default:
            return false
        }
    }
}

extension ConversationSectionItem: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(identity)
    }
}
