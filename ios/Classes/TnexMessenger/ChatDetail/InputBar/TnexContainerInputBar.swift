//
//  TnexContainerInputBar.swift
//  Tnex messenger
//
//  Created by Din Vu Dinh on 02/03/2022.
//

import Foundation
import UIKit

class TnexContainerInputBar: UIView {
    class open func loadNib() -> TnexContainerInputBar {
        let view = Bundle(for: self).loadNibNamed(self.nibName(), owner: nil, options: nil)!.first as! TnexContainerInputBar
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = CGRect.zero
        return view
    }
    
    class func nibName() -> String {
        return "TnexContainerInputBar"
    }
}
