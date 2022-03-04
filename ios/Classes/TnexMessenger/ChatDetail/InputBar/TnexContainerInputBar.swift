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

extension UIView {
    
    func fillSuperview() {
        guard let superview = self.superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
        topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
    }
}
