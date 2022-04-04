//
//  AvatarSeenView.swift
//  tnexchat
//
//  Created by Din Vu Dinh on 28/03/2022.
//

import UIKit

class AvatarSeenView: UIView, SeenViewProtocol {

    lazy var imgAvatar: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    let userId: String
    let messageId: String
    
    init(userId: String, messageId: String, frame: CGRect = CGRect.zero) {
        self.userId = userId
        self.messageId = messageId
        super.init(frame: frame)
        commonInit()
    }

    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        userId = ""
        self.messageId = ""
        super.init(coder: aDecoder)
        commonInit()
    }

    //common func to init our view

    private func commonInit() {
        addSubview(imgAvatar)
        imgAvatar.layer.cornerRadius = 8
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imgAvatar.frame = self.bounds
    }
}
