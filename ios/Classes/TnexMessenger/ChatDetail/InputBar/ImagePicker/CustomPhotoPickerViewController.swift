//
//  CustomPhotoPickerViewController.swift
//  AFNetworking
//
//  Created by Din Vu Dinh on 24/03/2022.
//

import Foundation
import TLPhotoPicker

class CustomPhotoPickerViewController: TLPhotosPickerViewController {
//    override func makeUI() {
//        super.makeUI()
//        self.customNavItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .stop, target: nil, action: #selector(CustomPhotoPickerViewController.customAction))
//    }
//    @objc private func customAction() {
//        self.delegate?.photoPickerDidCancel()
//        self.dismiss(animated: true) { [weak self] in
//            self?.delegate?.dismissComplete()
//            self?.dismissCompletion?()
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButton.isEnabled = false
    }
    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, didSelectItemAt: indexPath)
        self.doneButton.isEnabled = !self.selectedAssets.isEmpty
    }
}
