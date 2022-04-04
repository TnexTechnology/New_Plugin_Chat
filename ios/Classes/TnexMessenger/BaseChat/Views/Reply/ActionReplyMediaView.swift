//
//  ReplyTextView.swift
//  MessageKit
//
//
import UIKit

open class ActionReplyMediaView: UIView {
    
    open lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = MessageConstants.ActionView.ReplyView.mediaRadius
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    open var lottieURL: URL?
    
    lazy var messageLabel: UILabel = {
        let label: UILabel = .init()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.fromHex("#808080")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        self.addSubview(imageView)
        let contentInset = MessageConstants.ActionView.ReplyView.contentMediaInset
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: contentInset.left),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: contentInset.top),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -contentInset.bottom)
        ])
        self.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5),
            messageLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor, constant: 0),
            messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -contentInset.right),
        ])

    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
