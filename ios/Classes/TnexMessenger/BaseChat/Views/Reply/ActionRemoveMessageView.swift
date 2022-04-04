//
//  ActionRemoveMessageView.swift
//  InputBarAccessoryView
//
//  Created by Din Vu Dinh on 10/10/20.
//

import UIKit

open class ActionRemoveMessageView: UIView {
    
    lazy var contentLabel: UILabel = {[unowned self] in
        let label: UILabel = .init()
        label.numberOfLines = 0
        label.font = UIFont.italicSystemFont(ofSize: 13)
        label.textColor = UIColor.fromHex("#808080")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init() {
        super.init(frame: .zero)
        self.addSubview(contentLabel)
        let contentInset = MessageConstants.ActionView.RemoveView.contentInset
        NSLayoutConstraint.activate([
            contentLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: contentInset.left),
            contentLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: contentInset.top),
            contentLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -contentInset.right),
            contentLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -contentInset.bottom)
        ])
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
