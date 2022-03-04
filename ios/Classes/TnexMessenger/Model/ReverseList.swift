//
//  ReverseList.swift
//  Tnex messenger
//
//  Created by Din Vu Dinh on 27/02/2022.
//

import UIKit


struct ReverseList<Element, Content> {
    private let items: [Element]
    private let reverseItemOrder: Bool
    private let viewForItem: (Element) -> Content

    var hasReachedTop: Bool

    init(_ items: [Element], reverseItemOrder: Bool = true, viewForItem: @escaping (Element) -> Content) {
        self.items = items
        self.reverseItemOrder = reverseItemOrder
        self.hasReachedTop = true
        self.viewForItem = viewForItem
    }

    
}
