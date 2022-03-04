//
//  Configuration.swift
//  Tnex messenger
//
//  Created by MacOS on 27/02/2022.
//

import Foundation
import MatrixSDK

class Configuration {
    static func setupMatrixSDKSettings() {
        let sdkOptions = MXSDKOptions.sharedInstance()

//        sdkOptions.applicationGroupIdentifier = ""

        // Enable e2e encryption for newly created MXSession
        sdkOptions.enableCryptoWhenStartingMXSession = true
        sdkOptions.computeE2ERoomSummaryTrust = true

        // Use UIKit BackgroundTask for handling background tasks in the SDK
//        sdkOptions.backgroundModeHandler = MXUIKitBackgroundModeHandler()
    }
}

