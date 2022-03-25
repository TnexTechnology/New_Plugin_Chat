//
//  DownloadManager.swift
//  tnexchat
//
//  Created by Din Vu Dinh on 25/03/2022.
//

import Foundation
import Photos

class DownloadManager: NSObject {
    static let shared = DownloadManager()
    
    func saveImageToLibrary(image: UIImage, completion: @escaping(_ isSucceed: Bool) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 1) else { return }
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: PHAssetResourceType.photo, data: imageData, options: nil)
        }) { (_, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
            } else {
                DispatchQueue.main.async {
                    completion(true)
                }
            }
        }
    }
}
