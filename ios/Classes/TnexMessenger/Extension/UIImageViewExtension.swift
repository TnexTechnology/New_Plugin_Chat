//
//  UIImageViewExtension.swift
//  Tnex messenger
//
//  Created by Din Vu Dinh on 28/02/2022.
//

import Foundation
import SDWebImage

extension UIImageView {
    
    func setThumbMessage(url: String?) {
        if self.image != nil {
            self.contentMode = .scaleAspectFill
        } else {
            self.contentMode = .center
        }
        self.sd_cancelCurrentImageLoad()
        let placeholderImage: UIImage? = self.image
        self.sd_setImage(with: URL(string: url ?? ""), placeholderImage: placeholderImage, options: .continueInBackground) { (image, error, cacheType, resultURL) in
            if let coverImage = image {
                self.contentMode = .scaleAspectFill
                self.image = coverImage
            }
        }
    }
}
