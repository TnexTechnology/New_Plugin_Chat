//
//  PermissionManager.swift
//  tnexchat
//
//  Created by MacOS on 18/03/2022.
//

import Foundation
import UIKit
import Photos

public class PermissionManager {

    public static let shared = PermissionManager()

    var cameraPermission: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }

    public func requestCamera(_ handler: @escaping (_ granted: Bool) -> Void) {
        switch cameraPermission {
        case .authorized:
            handler(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] (granted) in
                if granted {
                    handler(true)
                } else {
                    handler(false)
                    self?.openSetting()
                }
            }
        case .restricted:
            handler(false)
            self.openSetting()
        case .denied:
            handler(false)
            self.openSetting()
        @unknown default:
            break
        }
    }

    private func openSetting() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Bật camera", message: nil, preferredStyle: .alert)
            let allowAction = UIAlertAction(title: "Goto setting", style: .default) { (_: UIAlertAction) in
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                }
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(allowAction)
            UIViewController.topController()?.present(alertController, animated: true, completion: nil)
        }
    }

    public func checkPhotoPermission(_ handler: @escaping (_ granted: Bool) -> Void) {
        func hasPhotoPermission() -> Bool {
            return PHPhotoLibrary.authorizationStatus() == .authorized
        }
        
        func needsToRequestPhotoPermission() -> Bool {
            return PHPhotoLibrary.authorizationStatus() == .notDetermined
        }
        
        hasPhotoPermission() ? handler(true) : (needsToRequestPhotoPermission() ?
            PHPhotoLibrary.requestAuthorization({ status in
                DispatchQueue.main.async(execute: { () in
                    hasPhotoPermission() ? handler(true) : handler(false)
                })
            }) : handler(false))
    }
}

extension UIViewController {

   class func topController() -> UIViewController? {
        if var topController = UIApplication.key?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }

}
