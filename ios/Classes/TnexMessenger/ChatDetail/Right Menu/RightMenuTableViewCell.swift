//
//  RightMenuTableViewCell.swift
//  tnexchat
//
//  Created by MacOS on 07/03/2022.
//

import UIKit

import UIKit
import DropDown

class RightMenuTableViewCell: DropDownCell {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var lineImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        logoImageView.clipsToBounds = true
        lineImageView.image = UIImage(named: "chat_menu_line", in: Bundle.resources, compatibleWith: nil)
    }
    
}
