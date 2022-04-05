//
//  HeaderUserInfoView.swift
//  Tnex messenger
//
//  Created by Din Vu Dinh on 28/02/2022.
//

import Foundation
import UIKit

class HeaderUserInfoView: UIView {
    
    let displayNameLabel: UILabel = {
        let label = UILabel.newAutoLayout()
        label.textColor = UIColor.fromHex("14C8FA")
        label.autoSetDimension(.height, toSize: 20)
        label.font = UIFont(name: "Quicksand-Medium", size: 16)
        label.textAlignment = .center
        return label
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel.newAutoLayout()
        label.textColor = UIColor.fromHex("61DB99")
        label.textAlignment = .center
        label.font = UIFont(name: "Quicksand-Regular", size: 14)
        label.autoSetDimension(.height, toSize: 16)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.addSubview(displayNameLabel)
        displayNameLabel.autoPinEdge(toSuperviewEdge: .right)
        displayNameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 5)
        displayNameLabel.autoPinEdge(toSuperviewEdge: .left)
        self.addSubview(statusLabel)
        statusLabel.autoPinEdge(toSuperviewEdge: .right)
        statusLabel.autoPinEdge(toSuperviewEdge: .left)
        statusLabel.autoPinEdge(.top, to: .bottom, of: displayNameLabel, withOffset: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
