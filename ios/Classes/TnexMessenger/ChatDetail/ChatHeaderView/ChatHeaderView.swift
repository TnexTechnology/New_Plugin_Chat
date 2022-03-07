//
//  ChatHeaderView.swift
//  Tnex messenger
//
//  Created by Din Vu Dinh on 28/02/2022.
//

import Foundation
import UIKit
import PureLayout
import MatrixSDK
import DropDown

class ChatHeaderView: UIView {
    
    let menuDropDown = DropDown()
    
    static let headerBarHeight: CGFloat = 81
    
    private lazy var headerLine: UIView = {
        let line = UIView.newAutoLayout()
        line.autoSetDimension(.height, toSize: 1.0)
        line.backgroundColor = UIColor(hexString: "#F5F5F5")
        line.isHidden = true
        return line
    }()
    
    private lazy var imageView: UIImageView = {
        let imgView = UIImageView.newAutoLayout()
        let image = UIImage(named: "chat_header_banner", in: Bundle.resources, compatibleWith: nil)
        imgView.image = image
        return imgView
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(ChatHeaderView.actionBack), for: .touchUpInside)
        let image = UIImage(named: "chat_button_back", in: Bundle.resources, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.autoSetDimension(.width, toSize: 44)
        button.backgroundColor = UIColor.clear
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return button
    }()
    @objc private func actionBack() {
        self.onClickBack?()
    }
    
    lazy var menuRightButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(ChatHeaderView.showMenu), for: .touchUpInside)
        let image = UIImage(named: "chat_button_menu_right", in: Bundle.resources, compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.autoSetDimension(.width, toSize: 44)
        button.backgroundColor = UIColor.clear
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return button
    }()
    @objc private func showMenu() {
        print("Show menu")
        menuDropDown.show()
    }
    
    var onClickBack: (() -> Void)?
        
    lazy var leftItems: UIStackView = {
        let stackView = UIStackView.newAutoLayout()
        return stackView
    }()

    lazy var rightItems: UIStackView = {
        let stackView = UIStackView.newAutoLayout()
        return stackView
    }()
    
    private let headerView: UIView = {
        let stv = UIView.newAutoLayout()
        stv.autoSetDimension(.height, toSize: 44)
        return stv
    }()
    
    lazy var infoView: HeaderUserInfoView = {
        let line = HeaderUserInfoView.newAutoLayout()
        return line
    }()
    
    lazy var avatarView: UserAvatarView = {
        let view = UserAvatarView.newAutoLayout()
        view.autoSetDimension(.height, toSize: 44)
        view.autoSetDimension(.width, toSize: 44)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imageView)
        imageView.autoPinEdge(toSuperviewEdge: .right)
        imageView.autoPinEdge(toSuperviewEdge: .top)
        imageView.autoPinEdge(toSuperviewEdge: .bottom)
        imageView.autoPinEdge(toSuperviewEdge: .left)
        self.addSubview(headerView)
        headerView.autoPinEdge(toSuperviewEdge: .right, withInset: 12)
        headerView.autoPinEdge(toSuperviewSafeArea: .top)
        headerView.autoPinEdge(toSuperviewEdge: .left, withInset: 12)
        self.addSubview(headerLine)
        headerLine.autoPinEdge(toSuperviewEdge: .bottom)
        headerLine.autoPinEdge(toSuperviewEdge: .leading)
        headerLine.autoPinEdge(toSuperviewEdge: .trailing)
        self.addSubview(infoView)
        infoView.autoPinEdge(toSuperviewEdge: .right)
        infoView.autoPinEdge(toSuperviewEdge: .left)
        infoView.autoPinEdge(.top, to: .bottom, of: headerView, withOffset: 0)
        infoView.autoPinEdge(.bottom, to: .top, of: headerLine, withOffset: 0)
        addHeaderView()
        self.addStackItems()
        setupDropDown()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupDropDown() {
        let appearance = DropDown.appearance()
        
        appearance.cellHeight = 60
        appearance.backgroundColor = UIColor.clear
        appearance.selectionBackgroundColor = UIColor.clear
//        appearance.separatorColor = UIColor(white: 0.7, alpha: 0.8)
        appearance.cornerRadius = 10
        appearance.shadowColor = UIColor.fromHex("#020036")
        appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 15
        appearance.animationduration = 0.25
        appearance.textColor = .darkGray
//        appearance.textFont = UIFont(name: "Georgia", size: 14)

        if #available(iOS 11.0, *) {
            appearance.setupMaskedCorners([.layerMaxXMaxYCorner, .layerMinXMaxYCorner])
        }
        let listImageName: [String] = ["chat_menu_header_profile", "chat_menu_header_silent", "chat_menu_header_trash"]
        menuDropDown.cellNib = UINib(nibName: "RightMenuTableViewCell", bundle: Bundle.resources)
        menuDropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? RightMenuTableViewCell else { return }
            // Setup your custom UI components
            cell.logoImageView.image = UIImage(named: listImageName[index], in: Bundle.resources, compatibleWith: nil)
        }
        menuDropDown.anchorView = menuRightButton
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        menuDropDown.bottomOffset = CGPoint(x: 0, y: 60)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        menuDropDown.dataSource = [
            "Hồ sơ cá nhân",
            "Im lặng",
            "Xoá cuộc hội thoại"
        ]
        
        // Action triggered on selection
            menuDropDown.selectionAction = { [weak self] (index, item) in
            print("dfsdfds")
        }

    }
    
    private func addHeaderView() {
        self.headerView.addSubview(avatarView)
        avatarView.autoAlignAxis(toSuperviewAxis: .vertical)
        avatarView.autoAlignAxis(toSuperviewAxis: .horizontal)
        self.headerView.addSubview(leftItems)
        leftItems.autoPinEdge(toSuperviewEdge: .bottom)
        leftItems.autoPinEdge(toSuperviewEdge: .leading)
        leftItems.autoPinEdge(toSuperviewEdge: .top)
        leftItems.autoPinEdge(.trailing, to: .leading, of: avatarView, withOffset: 0, relation: .lessThanOrEqual)
        self.headerView.addSubview(rightItems)
        rightItems.autoPinEdge(toSuperviewEdge: .bottom)
        rightItems.autoPinEdge(toSuperviewEdge: .trailing)
        rightItems.autoPinEdge(toSuperviewEdge: .top)
        leftItems.autoPinEdge(.leading, to: .trailing, of: avatarView, withOffset: 0, relation: .lessThanOrEqual)
    }
    
    private func addStackItems() {
        self.leftItems.addArrangedSubview(self.backButton)
        self.rightItems.addArrangedSubview(self.menuRightButton)
    }
    
    func updateUser(user: MXUser) {
        self.infoView.displayNameLabel.text = user.displayname
        self.avatarView.statusView.isHidden = !user.currentlyActive
        if user.currentlyActive {
            self.infoView.statusLabel.text = "Đang hoạt động"
        } else {
            let second = user.lastActiveAgo / 1000
            self.infoView.statusLabel.text = Int(second).toTimeActive()
        }
        if let url = URL(string: user.avatarUrl) {
            self.avatarView.imageView.sd_setImage(with: url)
        }
        
    }
}
